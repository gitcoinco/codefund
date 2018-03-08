# base image elixer to start with
FROM elixir:1.6.1

# install hex package manager
RUN mix local.hex --force

# install phoenix
RUN mix archive.install https://github.com/phoenixframework/archives/raw/master/phoenix_new.ez --force

# install python
RUN apt-get install python2.7

# install node
RUN curl -sL https://deb.nodesource.com/setup_7.x -o nodesource_setup.sh
RUN bash nodesource_setup.sh
RUN apt-get install nodejs

# create app folder
RUN mkdir /app
COPY . /app
WORKDIR /app

# setting the port and the environment (prod = PRODUCTION!)
ENV MIX_ENV=prod
ENV PORT=4000

# install dependencies (production only)
RUN mix local.rebar --force
RUN mix deps.get
RUN mix compile

# install node dependencies
RUN cd assets && npm install
# build only the things for production
RUN cd assets && npm run deploy

# create the digests
RUN mix phx.digest

# run phoenix in production on PORT 4000
CMD ["mix ecto.create; mix ecto.migrate; mix phx.server"]
