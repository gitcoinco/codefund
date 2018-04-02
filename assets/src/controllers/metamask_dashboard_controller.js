import { Controller } from "stimulus";
import jwt from "jsonwebtoken";

export default class extends Controller {
  static get targets() {
    return ["iframe"];
  }

  connect() {
    this.load();
  }

  load() {
    const siteUrl = this.iframeTarget.dataset.siteUrl;
    const secretKey = this.iframeTarget.dataset.secretKey;
    const payload = {
      resource: {
        dashboard: 2
      },
      params: {
        user_id: this.iframeTarget.dataset.userId
      }
    };
    const token = jwt.sign(payload, secretKey);
    const iframeUrl = `${siteUrl}/embed/dashboard/${token}#bordered=false&titled=false`;
    this.iframeTarget.src = iframeUrl;
  }
}
