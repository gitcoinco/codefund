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
    let estimatedImpressions = 0;
    const ecpm = parseFloat(this.ecpmTarget.value);
    const totalBudget = parseFloat(this.totalBudgetTarget.value);
    if (ecpm > 0) {
      estimatedImpressions = ((totalBudget / ecpm) * 1000);
    }
    this.estimatedImpressionsTarget.value = Math.round(estimatedImpressions);
  }
}
