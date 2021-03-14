FROM node:lts-alpine
LABEL maintainer="chen17@coder17.com"

RUN apk --update --no-cache add git less openssh make && rm -rf /var/lib/apt/lists/*
RUN npm install hexo-cli hexo-generator-feed hexo-generator-sitemap hexo-symbols-count-time hexo-deployer-git -g && \
    hexo init /usr/src/app/blog && \
    cd /usr/src/app/blog && \
    npm install
WORKDIR /usr/src/app/blog
COPY Makefile ./
ENTRYPOINT [ "make" ]
VOLUME [ "/usr/src/app/data" ]