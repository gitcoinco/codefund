import { Controller } from "stimulus";
import axios from "../utils/axios";
import $ from "jquery/dist/jquery";
import _ from "lodash";

export default class extends Controller {
  static get targets() {
    return [
      "name",
      "programmingLanguages",
      "topicCategories",
      "excludedCountries"
    ];
  }

  connect() {
    this.payload = {};
    this.initSelectize();
    console.log("HELLO!");
  }

  initSelectize() {
    YOU ARE HERE!
    $("select.selectize").selectize({
      plugins: ["remove_button"],
      delimiter: ",",
      persist: false
    });
  }

  generateEstimates(event) {
    var change = {};
    change[event.currentTarget.dataset.key] = event.currentTarget.value;
    this.payload = Object.assign(this.payload, change);
  }

  get payload() {
    return JSON.parse(this.data.get("payload"));
  }

  set payload(value) {
    this.data.set("payload", JSON.stringify(value));
    console.log(JSON.stringify(value));
  }
}