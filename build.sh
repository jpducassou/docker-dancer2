#!/bin/bash

# --build-arg https_proxy="${https_proxy}" \
# --build-arg http_proxy="${http_proxy}"   \

docker build --rm \
	$@ \
	-t docker-dancer2 .

