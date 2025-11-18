#!/bin/sh

set -e

COMPOSE_FOLDERS="services/* cloudflared"

if [ -z "$1" ]; then
  echo "Usage: $0 {up|down}"
  exit 1
fi

if [ "$1" = "up" ]; then
  docker network create homeserver-net

  for folder in $(echo $COMPOSE_FOLDERS | tac -s ' '); do
    if [ -d "$folder" ]; then
      (cd "$folder" && docker compose up --detach)
    fi
  done

elif [ "$1" = "down" ]; then
  for folder in $(echo $COMPOSE_FOLDERS | tac -s ' '); do
    if [ -d "$folder" ]; then
      (cd "$folder" && docker compose down)
    fi
  done

  docker network remove homeserver-net
else
  echo "Usage: $0 {up|down}"
  exit 1
fi
