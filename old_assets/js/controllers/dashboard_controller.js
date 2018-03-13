import { Controller } from "stimulus"

export default class extends Controller {
  connect() {
    this.outputTarget.dailyTrafficStatsContent = `Hello!`
  }
}