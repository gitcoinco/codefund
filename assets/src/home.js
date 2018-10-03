import { Application } from "stimulus";
import { definitionsFromContext } from "stimulus/webpack-helpers";

import socket from "./socket";
import "./service-worker-register";

import EventTrackController from "./controllers/event_track_controller";

const application = Application.start();
application.register("event_track", EventTrackController);

console.log(
  `Application "${process.env.APP_NAME} ${process.env.VERSION}" running on "${
  process.env.NODE_ENV
  }" mode [home.js]`
);
