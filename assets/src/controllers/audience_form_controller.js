import { Controller } from "stimulus";
import axios from "../utils/axios";
import $ from "jquery/dist/jquery";

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
    this.data.set("payload", {});
  }

  generateEstimates() {
    console.log("GENERATING ESTIMATES");
    console.log(this.payload);
  }

  get payload() {
    return this.data.get("payload");
  }

  set payload(value) {
    this.data.set("payload", value);
    console.log("TRIGGER!");
  }
}