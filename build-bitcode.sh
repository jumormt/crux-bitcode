#!/bin/sh

# Spin up a container.
id=`docker run --rm --detach -it mbarbar/crux-bitcode:10.0.1.11 bash`
# Short ID, for more wieldy filenames.
sid=`echo $id | head -c 10`

# Copy over user config.
docker cp pkgmk.conf $id:/etc/pkgmk.conf
docker cp pkgs.txt $id:/etc/pkgs.txt
docker cp ports/. $id:/usr/ports/

if docker exec "$id" build-bitcode; then
  docker exec "$id" mv "bitcode" "bitcode-$sid"
  docker exec "$id" zip -r "bitcode-$sid.zip" "bitcode-$sid"
  docker cp "$id:/root/bitcode-$sid.zip" "bitcode-$sid.zip"

  docker exec "$id" mv "source" "source-$sid"
  docker exec "$id" zip -r "source-$sid.zip" "source-$sid"
  docker cp "$id:/root/source-$sid.zip" "source-$sid.zip"

  echo "BITCODE: bitcode-$sid.zip"
  echo "SOURCE: source-$sid.zip"
else
  echo "^ fatal error" 1>&2
fi

docker stop "$id" > /dev/null
