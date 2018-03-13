function install_deps {
  # install node dependencies
  pushd $1
    npm install
  popd
}

function build_assets {
  # build only the things for production
  pushd $1
    npm run deploy
  popd
}


function run_assets {
    install_deps $1
    build_assets $1
}
