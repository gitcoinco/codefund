import { Application } from "stimulus";
import EventTrackController from "./controllers/event_track_controller";
const application = Application.start();
application.register("event_track", EventTrackController);