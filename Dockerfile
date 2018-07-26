# base image elixer to start with
FROM elixir:1.7-slim

RUN apt-get update && apt-get -y install python2.7 curl make gcc inotify-tools git gnupg

# install node
RUN curl -sL https://deb.nodesource.com/setup_7.x -o nodesource_setup.sh && \
    bash nodesource_setup.sh && \
    apt-get install -y nodejs

# install hex package manager and phoenix
RUN mix local.hex --force && \
    mix archive.install https://github.com/phoenixframework/archives/raw/master/phoenix_new.ez --force

# create app folder
RUN mkdir /app
COPY . /app
WORKDIR /app

# setting the port and the environment (prod = PRODUCTION!)
ENV MIX_ENV=dev
ENV PORT=4000

# install dependencies (production only)
RUN mix local.rebar --force && \
    mix deps.get \
    mix compile

# install node dependencies
RUN cd assets && \
    npm install && \
    npm run build

# run phoenix in production on PORT 4000
CMD docker/run.sh
