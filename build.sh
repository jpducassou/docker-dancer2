#!/bin/bash

docker build --rm \
	--build-arg https_proxy="${https_proxy}" \
	--build-arg http_proxy="${http_proxy}"   \
	--build-arg UID=$(id -u) \
	$@ \
	-t docker-dancer2 .

