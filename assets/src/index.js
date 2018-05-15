/* eslint-disable no-console */

import "jquery/dist/jquery";
import "popper.js";
import "bootstrap/dist/js/bootstrap";
import "phoenix_html";
import "./onload";

import { Application } from "stimulus";
import { definitionsFromContext } from "stimulus/webpack-helpers";

import socket from "./socket";
import "./css/app.scss";
import "./service-worker-register";

const application = Application.start();
const context = require.context("./controllers", true, /\.js$/);
application.load(definitionsFromContext(context));

const Turbolinks = require("turbolinks");

Turbolinks.start();

console.log(
  `Application "${process.env.APP_NAME} ${process.env.VERSION}" running on "${
    process.env.NODE_ENV
  }" mode`
);
