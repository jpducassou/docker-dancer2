#!/bin/bash

docker run -it --rm \
	-e "https_proxy=${https_proxy}" \
	-e "http_proxy=${http_proxy}"   \
  docker-dancer2 /bin/bash

