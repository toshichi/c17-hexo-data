.PHONY: clean gen push

version = v0.1

all: gen

# generate blog files
gen: build
	docker run --rm -v ${PWD}/public:/usr/src/app/blog/public -v ${PWD}/data:/usr/src/app/data coder17/hexo:latest

push: build
	docker run --rm -v ${PWD}/data:/usr/src/app/data coder17/hexo:latest push

# build docker image
build:
	docker build -t coder17/hexo:latest -t coder17/hexo:$(version) ./docker

clean:
	docker image rm coder17/hexo:latest
	docker image rm coder17/hexo:$(version)
	rm -rf ./public
