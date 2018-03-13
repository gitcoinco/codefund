#!/bin/bash

source docker/assets.sh

export ASSETS_DIR=assets

if [ $MIX_ENV = 'prod' ]; then
  mix deps.create
  mix ecto.migrate
  mix phx.server
else
  run_assets $ASSETS_DIR
    
  mix deps.get
  mix ecto.migrate
  mix phx.server
fi
