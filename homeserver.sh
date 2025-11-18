#!/bin/sh

set -e


if [ -z "$1" ]; then
  echo "Usage: $0 {up|down}"
  exit 1
fi

for should_decrypt_file in $(cat .gitattributes | cut -d' ' -f1 | xargs); do
  if cat "$should_decrypt_file" | grep -q "^GITCRYPT"; then
    if [ -z key ]; then
      git-crypt unlock ./key
    else
      echo "Should decrypt a file using git-crypt but no key provided as 'key' file at repo root"
      exit 2
    fi
  fi
done

COMPOSE_FOLDERS="services/* cloudflared"

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
