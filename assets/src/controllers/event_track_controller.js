import { Controller } from "stimulus";

export default class extends Controller {
  logEvent() {
    const category = this.element.dataset.gaEventCategory,
      action = this.element.dataset.gaEventAction,
      label = this.element.dataset.gaEventLabel,
      value = this.element.dataset.gaEventValue;
    
    if (typeof ga != "undefined") {
      ga("send", "event", {
        eventCategory: category,
        eventAction: action,
        eventLabel: label,
        eventValue: value
      });
    } else {
      console.log("Emitting GA event on prod", category, action, label, value);
    }
  }
}
