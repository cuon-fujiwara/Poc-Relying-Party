FROM ruby:3.3.4

WORKDIR /app

COPY Gemfile /app
COPY Gemfile.lock /app

RUN gem install bundler && bundle install

COPY . /app

RUN apt-get update && \
    apt-get install -y nodejs && \
    rm -f tmp/pids/server.pid