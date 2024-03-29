#! /bin/bash

echo "Searching for default login in moonlight logs"
docker logs moonlight | grep "Default login"