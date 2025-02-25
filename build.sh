#!/usr/bin/env bash

VERSION=$1
DEV=$2

if [ -z "${VERSION}" ] 
then
 exit "build.sh <version>"
fi

if [[ -z "${DEV}" || "${DEV}" != "dev" ]]
then 
    DEV_BUILD=0
    FULL_TAG=${VERSION}
    SHORT_TAG=$(echo $VERSION |cut -f1,2 -d '.')
    echo "Building prod"
else
    DEV_BUILD=1
    FULL_TAG="dev-${VERSION}"
    SHORT_TAG="dev-$(echo $VERSION |cut -f1,2 -d '.')"
    echo "Building dev"
fi

docker build --no-cache --build-arg VERSION=$VERSION -t kerwood/unraid-tailscale:${FULL_TAG} .

ret=$?
if [ $ret -ne 0 ]; then
	echo "Build failed"
	exit 1;
fi

docker tag kerwood/unraid-tailscale:${FULL_TAG} kerwood/unraid-tailscale:${SHORT_TAG}

if [ $DEV_BUILD != 1 ];
then
   docker tag kerwood/unraid-tailscale:${FULL_TAG} kerwood/unraid-tailscale:latest
else
    docker push kerwood/unraid-tailscale:${FULL_TAG}
    docker push kerwood/unraid-tailscale:${SHORT_TAG}
fi

