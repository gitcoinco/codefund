import { Controller } from "stimulus";
import $ from "jquery/dist/jquery";

export default class extends Controller {
  static get targets() {
    return [
      "ecpm",
      "totalBudget",
      "estimatedImpressions",
      "datePicker",
      "startDate",
      "endDate"
    ];
  }

  connect() {
    this.calculateImpressions();
  }

  calculateImpressions() {
    const ecpm = this.targets.find("ecpm").value;
    const totalBudget = this.targets.find("totalBudget").value;
    const estimatedImpressions = ((totalBudget / ecpm) * 1000);
    $(this.targets.find("estimatedImpressions"))[0].value = estimatedImpressions;
  }
}
