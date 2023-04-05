#!/usr/bin/env bash

#   -------------------------------------------------------------
#   Nasqueron Dev Workspace
#   - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#   Author:         Sébastien Santoro aka Dereckson
#   Project:        Nasqueron
#   Created:        2022-01-16
#   Description:    Wrapper to launch a dev environment
#                   as a Docker container
#   License:        Trivial work, not eligible to copyright
#                   If copyright eligible, BSD-2-Clause
#   Image:          nasqueron/dev-workspace-<flavour>
#   -------------------------------------------------------------

set -e

#   -------------------------------------------------------------
#   Parse arguments
#   - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

if [ $# -lt 2 ]; then
    echo "Usage: $(basename "$0") <flavour> <command>" >&2
    exit 1
fi

FLAVOUR=$1
shift

BASE_IMAGE=nasqueron/dev-workspace-$FLAVOUR

if [ -t 0 ]; then
	# If a stdin entry is available
	# launch the container in the
	# interactive mode
	FLAGS=-it
fi

UPDATE_MODE=0

if [ "$1" = "shell" ]; then
	# Launch commands in the container bash shell
	COMMAND=bash
elif [ "$1" = "update" ]; then
	UPDATE_MODE=1
else
	COMMAND=$1
fi
shift

#   -------------------------------------------------------------
#   Build image
#   - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

build_user_image () {
	BUILD_DIR=$(mktemp -d -t dev-workspace-build-XXXXXXXXXX)
	pushd "$BUILD_DIR" > /dev/null || exit 1
	>&2 echo "🔨 Building user-specific image $IMAGE for $USER"
	echo "FROM $BASE_IMAGE" > Dockerfile
	echo "RUN groupadd -r $USER -g $GID && mkdir /home/$USER && useradd -u $UID -r -g $USER -d /home/$USER -s /bin/bash $USER && cp /root/.bashrc /home/$USER/ && chown -R $USER:$USER /home/$USER && ln -s /opt/config/gitconfig /home/$USER/.gitconfig && ln -s /opt/config/arcrc /home/$USER/.arcrc" >> Dockerfile
	docker build -t "$IMAGE" .
	popd > /dev/null
	rm -rf "$BUILD_DIR"
}

test -v $UID && UID=$(id -u)
test -v $GID && GID=$(id -g)

if [ $UPDATE_MODE -eq 1 ]; then
	docker pull $BASE_IMAGE

	# Rebuild user image
	IMAGE=$BASE_IMAGE:$UID-$GID
	test $UID -eq 0 || build_user_image

	exit
fi

if [ $UID -eq 0 ]; then
	IMAGE=$BASE_IMAGE
	CONTAINER_USER_HOME=/root
else
	IMAGE=$BASE_IMAGE:$UID-$GID
	test ! -z $(docker images -q "$IMAGE") || build_user_image
	CONTAINER_USER_HOME="/home/$USER"
fi

#   -------------------------------------------------------------
#   Run container
#   - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Recycle SSH configuration for arc container when it's available
if [ -d ~/.arc/ssh ]; then
	VOLUME_SSH="-v $HOME/.arc/ssh:$CONTAINER_USER_HOME/.ssh"
else
	VOLUME_SSH=""
fi

docker run $FLAGS --rm --user $UID:$GID -v ~/.arc:/opt/config -v "$PWD:/opt/workspace" $VOLUME_SSH $IMAGE $COMMAND "$@"
