/* eslint-disable no-console */

import { register } from "register-service-worker";

const SW_URL = `/js/sw.js`;

if (process.env.NODE_ENV === "production") {
  register(SW_URL, {
    ready() {
      console.log(
        `App is being served from cache by a service worker.
           For more details, visit https://goo.gl/AFskqB`
      );
    },
    cached() {
      console.log("Content has been cached for offline use.");
    },
    updated() {
      console.log("New content is available; please refresh.");
    },
    offline() {
      console.log(
        "No internet connection found. App is running in offline mode."
      );
    },
    error(error) {
      console.error("Error during service worker registration:", error);
    }
  });
}
