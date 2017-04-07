IMAGE_NAME=staticfloat/llvm_jl
# If you need to use LLDB, add --privileged
DOCKER_OPTS=--privileged

build:
	docker build -t $(IMAGE_NAME) .

push:
	docker build --squash -t $(IMAGE_NAME) . && \
	docker push $(IMAGE_NAME)

pull:
	docker pull $(IMAGE_NAME)

shell:
	docker run -ti $(DOCKER_OPTS) $(IMAGE_NAME) /bin/bash

run:
	docker run -ti $(DOCKER_OPTS) $(IMAGE_NAME)
