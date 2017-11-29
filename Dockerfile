FROM ruby:2.3.0-alpine

RUN mkdir -p /usr/app/src
WORKDIR /usr/app
VOLUME /usr/app/src

RUN apk add --no-cache imagemagick libxml2-dev libxslt-dev && \
    wget http://kindlegen.s3.amazonaws.com/kindlegen_linux_2.6_i386_v2_9.tar.gz -O - | tar -xzf - -C /usr/bin kindlegen

COPY Gemfile /usr/app/
COPY Gemfile.lock /usr/app/

RUN apk add --no-cache build-base && \
    gem install bundler && \
    bundle config build.nokogiri --use-system-libraries && \
    bundle install && \
    apk del build-base

COPY . /usr/app
ENTRYPOINT ["ruby", "-Ilib"]
