import { Controller } from "stimulus";
import axios from "../utils/axios";

export default class extends Controller {
  connect() {
    this.load();
  }

  load() {
    axios
      .get(this.data.get("url"))
      .then(response => response.data)
      .then(html => {
        this.element.innerHTML = html;
      });
  }
}