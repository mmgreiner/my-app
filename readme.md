---
categories:
- programming
date: 2024-12-28
draft: true
tags:
- Docker
- Sinatra
- ruby
- Azure
title: Docker, Sinatra and Azure
description: Dockerize a Sinatra App and Deploy it to Azure
showToc: true
---

This describes the most simple way to create a Docker container of a [Sinatra][sinatra] app and deploying it to [Azure][azure].

## Sinatra

> Sinatra is a DSL for quickly creating web applications in Ruby with minimal effort

As a prerequisite, you must have [ruby][ruby] installed.

~~~bash
mkdir my-app
cd my-app
bundle init
bundle add sinatra rackup puma
touch myapp.rb
~~~

The `Gemfile` looks something like this:

~~~
# frozen_string_literal: true
source "https://rubygems.org"

gem "sinatra", "~> 4.1"
gem "rackup", "~> 2.2"
gem "puma", "~> 6.5"
~~~

We have a very simple ruby application in `app.rb`:

~~~ruby
require 'sinatra'
require 'logger'

set :logging, :debug

get '/' do
  logger.info "inside home"
  "Hallo World"
end
~~~

Run this little app:

~~~bash
% % ruby app.rb
== Sinatra (v4.1.1) has taken the stage on 4567 for development with backup from Puma
Puma starting in single mode...

* Puma version: 6.5.0 ("Sky's Version")
* Ruby version: ruby 3.4.1 (2024-12-25 revision 48d4efcb85) +PRISM [x86_64-darwin23]
* Min threads: 0
* Max threads: 5
* Environment: development
*       PID: 37241
* Listening on http://127.0.0.1:4567
* Listening on http://[::1]:4567
  Use Ctrl-C to stop
~~~

To use the [rake middleware](https://github.com/rack/rack), first create a rake file `config.ru`:

~~~~ruby
require './app'
run Sinatra::Application
~~~~

Then start the server:

~~~sh
% bundle exec rackup -p 9292
Puma starting in single mode...
* Puma version: 6.5.0 ("Sky's Version")
* Ruby version: ruby 3.4.1 (2024-12-25 revision 48d4efcb85) +PRISM [x86_64-darwin23]
*  Min threads: 0
*  Max threads: 5
*  Environment: development
*          PID: 61845
* Listening on http://127.0.0.1:9292
* Listening on http://[::1]:9292
Use Ctrl-C to stop
I, [2024-12-30T00:59:29.162530 #61845]  INFO -- : inside home
::1 - - [30/Dec/2024:00:59:29 +0100] "GET / HTTP/1.1" 200 11 0.0192
~~~

Point the browser at <http://localhost:9292/>, and you should see `Hallo World`.

## Docker and Dockerfile

You need to install the **docker desktop** software to run in the background. See [Docker Desktop install](https://docs.docker.com/desktop/setup/install/mac-install/) for the necessary instructions.

The `Dockerfile` contains all the necessary steps to create a docker image.

It looks like this:

~~~~
# Dockerfile

# Make sure RUBY_VERSION matches the Ruby version in .ruby-version
ARG RUBY_VERSION=3.4.1
FROM docker.io/library/ruby:$RUBY_VERSION AS base

# Put all this application's files in a directory called /code.
# This directory name is arbitrary and could be anything.
WORKDIR /code
COPY . /code

# Install base packages if using the database sqlite3
# RUN apt-get update -qq && \
#     apt-get install -y sqlite3 && \
#     rm -rf /var/lib/apt/lists /var/cache/apt/archives

# Throw-away build stage to reduce size of final image
FROM base AS build

# Install application gems
COPY Gemfile Gemfile.lock ./
RUN bundle install && \
    rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git 
    
# Run this command. RUN can be used to run anything. In our
# case we're using it to install our dependencies.
RUN bundle install

# Set production environment
ENV APP_ENV="development"

RUN rake db:migrate

# Tell Docker to listen on port
EXPOSE 9292

# Tell Docker that when we run "docker run", we want it to
# run the following command:
# $ bundle exec rackup --host 0.0.0.0 -p 9292.
CMD ["bundle", "exec", "rackup", "--host", "0.0.0.0", "-p", "9292"]
~~~~

I prefer not to use `ruby-slim`, since you then have to add all other dependencies (C++ compiler and libraries, etc) manually. See the [docker image libary](https://hub.docker.com/_/ruby) for possible ruby images.

## Create image

You create the docker image with the following command:

~~~~
% docker build -t my-app .
~~~~

If you now look into Docker Desktop under images, you will see `my-app` as the latest generated image. Start it by clicking on the *run* button and start the browser at <http://localhost:9292/>.

How it will throw an error. Why? because the ports have not been mapped.

Now try the following command:

    % docker run -p 9292:9292 my-app

And then browse at <http://localhost:9292/>. It should say: `Hallo World`.
If you go back to *Docker Desktop*, you will also see that it now has a new Container created. Click on *run*, and it should work.

## Adding a database

- [ ] TODO



[sinatra]: https://sinatrarb.com/
[azure]: https://portal.azure.com/
[docker]: https://www.docker.com/
[ruby]: https://www.ruby-lang.org/en/

