#! /bin/bash

CHANNEL=$1
DATABASE=$2

if [ "$DATABASE" = "internal" ]; then
    SSL=$3
    APP_URL=$4
    HTTP_PORT=$5
    HTTPS_PORT=$6
else
    DB_HOST=$3
    DB_PORT=$4
    DB_USERNAME=$5
    DB_PASSWORD=$6
    DB_DATABASE=$7
    SSL=$8
    APP_URL=$9
    HTTP_PORT=${10}
    HTTPS_PORT=${11}
fi

echo "Updating system"
apt update
apt upgrade -y

echo "Downloading dependencies"

echo "- Ensuring docker"
if ! command -v docker &>/dev/null; then
    curl -sSL https://get.docker.com/ | CHANNEL=stable bash
fi

if [ "$CHANNEL" = "custom" ]; then
    echo "- Ensuring node"
    if ! command -v node &>/dev/null; then
        apt install ca-certificates curl gnupg -y
        mkdir -p /etc/apt/keyrings
        curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
    
        NODE_MAJOR=20
        echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list
        apt update
        apt install nodejs -y
    fi

    echo "- Ensuring sass"
    if ! command -v sass &>/dev/null; then
        npm install -g sass
    fi
fi

if [ "$SSL" = "true" ]; then
    echo "- Ensuring certbot"
    
    if ! command -v certbot &>/dev/null; then
        apt install python3-certbot -y
    fi
fi

if [ "$DATABASE" = "internal" ]; then
    echo "Setting up internal database"
    MYSQL_PASSWORD=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 32 ; echo '')

    if ! docker volume inspect moonlight_db &>/dev/null; then
        echo "Creating docker volume 'moonlight_db'"
        docker volume create moonlight_db
    fi

    if ! docker container inspect moonlight_db &>/dev/null; then
        echo "Creating docker container 'moonlight_db'"
        docker run -d --restart=always --add-host=host.docker.internal:host-gateway --publish 0.0.0.0:3307:3306 --name moonlight_db -v moonlight_db:/var/lib/mysql -e MYSQL_ROOT_PASSWORD=$MYSQL_PASSWORD -e MYSQL_DATABASE=moonlight -e MYSQL_USER=moonlight -e MYSQL_PASSWORD=$MYSQL_PASSWORD mysql:latest
    fi
fi

if ! docker volume inspect moonlight &>/dev/null; then
    echo "Creating docker volume 'moonlight'"
    docker volume create moonlight
fi

CONFIG_FILE="/var/lib/docker/volumes/moonlight/_data/configs/core.json"

if ! test -f "$CONFIG_FILE"; then
    echo "Basic configuration file is missing, setting up default config"
    
    mkdir -p /var/lib/docker/volumes/moonlight/_data/configs
    wget -qO $CONFIG_FILE https://get-moonlight.app/moonlight/files/config.json
    
    sed -i "s#APP_URL/$APP_URL#g" $CONFIG_FILE
    
    if [ "$DATABASE" = "internal" ]; then
        sed -i "s/DB_HOST/host.docker.internal/g" $CONFIG_FILE
        sed -i "s/DB_PORT/3307/g" $CONFIG_FILE
        sed -i "s/DB_USERNAME/moonlight/g" $CONFIG_FILE
        sed -i "s~DB_PASSWORD~$MYSQL_PASSWORD~g" $CONFIG_FILE
        sed -i "s/DB_DATABASE/moonlight/g" $CONFIG_FILE
    else
        sed -i "s/DB_HOST/$DB_HOST/g" $CONFIG_FILE
        sed -i "s/DB_PORT/$DB_PORT/g" $CONFIG_FILE
        sed -i "s/DB_USERNAME/$DB_USERNAME/g" $CONFIG_FILE
        sed -i "s/DB_PASSWORD/$DB_PASSWORD/g" $CONFIG_FILE
        sed -i "s/DB_DATABASE/$DB_DATABASE/g" $CONFIG_FILE
    fi
fi

if [ "$CHANNEL" = "custom" ]; then
    echo "Selected channel 'custom'"
    echo ""
    echo "Building moonlight:"
    
    echo "- Installing dependencies"
    apt install git -y
    
    echo "- Cloning moonlight source code"
    mkdir -p /tmp/mlbuild
    rm -r /tmp/mlbuild/*
    git clone https://github.com/Moonlight-Panel/Moonlight /tmp/mlbuild --branch v2

    echo "Building moonlight from source"
    (cd /tmp/mlbuild; cd Moonlight/Styles; bash build.bat; cd ../..; docker build -t moonlightpanel/moonlight:custom -f Moonlight/Dockerfile .)

    echo "Removing source from tmp directory"
    rm -r /tmp/mlbuild
fi

if docker container inspect moonlight &>/dev/null; then
    echo "Removing moonlight container"
    docker stop moonlight &>/dev/null
    docker rm moonlight
fi

docker run -d -p $HTTP_PORT:80 -p $HTTPS_PORT:443 --add-host=host.docker.internal:host-gateway -v moonlight:/app/storage --name moonlight --restart=always moonlightpanel/moonlight:$CHANNEL

echo -e "\n\n"
echo "Done! Moonlight should be available now using $APP_URL"
echo -e "\n"
echo "You can get your default login credetails by running the following command:"
echo "'mlcli moonlight login'"
echo -e "\n"
echo "If you need any help, feel free to reach out over discord"
echo "https://discord.gg/TJaspT7A8p"
echo -e "\n\n"