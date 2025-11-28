#!/bin/sh

set -e


if [ -z "$1" ]; then
  echo "Usage: $0 {up|down}"
  exit 1
fi

for should_decrypt_file in $(cat .gitattributes | cut -d' ' -f1 | xargs); do
  if cat "$should_decrypt_file" | grep -q "^GITCRYPT"; then
    if [ -f key ]; then
      git-crypt unlock ./key
    else
      echo "Should decrypt a file using git-crypt but no key provided as 'key' file at repo root"
      exit 2
    fi
  fi
done

SERVICES_FOLDER="services/*"
DELAYED="services/nginx-reverse-proxy cloudflared"

up() {
  (cd "$1" && docker compose up --detach)
}

down() {
  (cd "$1" && docker compose down)
}

if [ "$1" = "up" ]; then

  docker network create open-homeserver-net
  docker network create closed-homeserver-net

  for folder in services/*; do
    if [ "$folder" = "services/nginx-reverse-proxy" ]; then
      continue
    elif [ -d "$folder" ]; then
      up $folder
    fi
  done

  for folder in $(echo $DELAYED | tac -r -s ' ' | tac); do
    up $folder
  done

elif [ "$1" = "down" ]; then

  for folder in $(echo $DELAYED | tac -s ' '); do
    down $folder
  done

  for folder in services/*; do
    if [ "$folder" = "services/nginx-reverse-proxy" ]; then
      continue
    elif [ -d "$folder" ]; then
      down $folder
    fi
  done

  docker network remove closed-homeserver-net
  docker network remove open-homeserver-net
else
  echo "Usage: $0 {up|down}"
  exit 1
fi
