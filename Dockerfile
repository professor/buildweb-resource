FROM alpine:latest as main

RUN set -eux; \
    apk --update add bash ruby ruby-json

COPY assets/ /opt/resource/

FROM main as testing

RUN set -eux; \
    gem install rspec;

COPY . /resource/

WORKDIR /resource
RUN rspec

FROM main
