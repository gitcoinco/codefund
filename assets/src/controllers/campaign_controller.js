import { Controller } from "stimulus";
import $ from "jquery/dist/jquery";

export default class extends Controller {
  static get targets() {
    return [
      "ecpm",
      "totalBudget",
      "estimatedImpressions"
    ];
  }

  connect() {
    this.calculateImpressions();
  }

calculateImpressions() {
  const ecpm = this.ecpmTarget.value;
  const totalBudget = this.totalBudgetTarget.value;
  const estimatedImpressions = ((totalBudget / ecpm) * 1000);
  this.estimatedImpressionsTarget.innerHTML = estimatedImpressions;
}
}
