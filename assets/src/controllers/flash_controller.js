import { Controller } from "stimulus";
import _ from "lodash";
import Swal from "sweetalert2";
import Noty from "noty";

export default class extends Controller {
  static get targets() {
    return ["body"];
  }

  connect() {
    const flashes = JSON.parse(this.element.dataset.flash);
    _.forOwn(flashes, (value, key) => {
      this.displayFlashNotifications(key, value);
    });
  }

  displayFlashNotifications(key, value) {
    if (key === "error" && !_.isEmpty(value)) {
      this.spawnSweetAlert(value);
    } else {
      this.spawnNotify(value);
    }
  }

  spawnSweetAlert(value) {
    Swal("Oops!", value, "warning");
  }

  spawnNotify(value) {
    const noty = new Noty({
      type: "success",
      layout: "topRight",
      theme: "nest",
      text: value,
      timeout: 3500,
      progressBar: true,
      closeWith: ["click", "button"],
      animation: {
        open: "noty_effects_open",
        close: "noty_effects_close"
      },
      id: false,
      force: false,
      killer: false,
      queue: "global",
      container: false,
      buttons: [],
      sounds: {
        sources: [],
        volume: 1,
        conditions: []
      },
      titleCount: {
        conditions: []
      },
      modal: false
    });
    
    noty.show();
  }
}
