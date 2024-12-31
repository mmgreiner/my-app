# Dockerfile


# Make sure RUBY_VERSION matches the Ruby version in .ruby-version
ARG RUBY_VERSION=3.4.1
FROM docker.io/library/ruby:$RUBY_VERSION AS base

# Put all this application's files in a directory called /code.
# This directory name is arbitrary and could be anything.
WORKDIR /code
COPY . /code

# Install base packages
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

# if you have a database
# RUN rake db:migrate

# Tell Docker to listen on port
EXPOSE 9292

# Tell Docker that when we run "docker run", we want it to
# run the following command:
# $ bundle exec rackup --host 0.0.0.0 -p 9292.
CMD ["bundle", "exec", "rackup", "--host", "0.0.0.0", "-p", "9292"]