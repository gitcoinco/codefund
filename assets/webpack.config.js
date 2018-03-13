const debug = process.env.NODE_ENV !== 'production';

const Webpack = require('webpack');
const path = require('path');
const ROOT_PATH = path.resolve(__dirname);
const SRC_PATH = path.resolve(ROOT_PATH, 'src');
const BUILD_PATH = path.resolve(ROOT_PATH, '../apps/app_web/priv/static');

// Use next version to be compatible with Webpack 4!
// https://github.com/webpack-contrib/extract-text-webpack-plugin/tree/next
const ExtractTextPlugin = require('extract-text-webpack-plugin');

const commonPlugins = [
  new ExtractTextPlugin({
    filename: 'css/styles.css',
    allChunks: true,
  }),
];

module.exports = {
  context: __dirname,
  devtool: debug ? 'inline-sourcemap' : false,
  entry: {
    bundle: SRC_PATH + '/index',
  },
  output: {
    path: BUILD_PATH,
    publicPath: '',
    filename: 'js/[name].js',
    chunkFilename: '[name].bundle.js',
  },
  plugins: debug ? commonPlugins : [
    ...commonPlugins,
    // Add production plugins here!
  ],
  resolve: {
    extensions: ['.js', '.jsx'],
  },
  module: {
    rules: [
      // Load javascripts
      {
        test: /\.jsx?$/,
        include: SRC_PATH,
        exclude: /node_modules/,
        loader: 'babel-loader',
        options: {
          presets: ['env', 'react', 'stage-0'],
        },
      },
      // Load stylesheets
      {
        test: /(\.css)$/,
        use: ExtractTextPlugin.extract({
          fallback: 'style-loader',
          use: 'css-loader',
        }),
      },
      // Load images
      {
        test: /\.(png|svg|jpg|gif)$/,
        loader: 'file-loader',
      },
      // Load fonts
      {
        test: /\.(woff|woff2|eot|ttf|otf)$/,
        loader: 'file-loader',
      },
    ],
  },
}