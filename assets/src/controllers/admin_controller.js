import { Controller } from "stimulus";
const classes = require("dom-classes");

const resizeBroadcast = () => {
  let timesRun = 0;
  const interval = setInterval(function () {
    timesRun += 1;

    if (timesRun === 5) {
      clearInterval(interval);
    }

    if (navigator.userAgent.indexOf('MSIE') !== -1 || navigator.appVersion.indexOf('Trident/') > 0) {
      var evt = document.createEvent('UIEvents');
      evt.initUIEvent('resize', true, false, window, 0);
      window.dispatchEvent(evt);
    } else {
      window.dispatchEvent(new Event('resize'));
    }
  }, 62.5);
};

export default class extends Controller {
  static get targets() {
    return ["body"];
  }

  toggleSidebar() {
    const body = this.bodyTarget;
    classes.toggle(body, "sidebar-hidden");
    resizeBroadcast();
  }

  minimizeSidebarAndBrand() {
    const body = this.bodyTarget;
    classes.toggle(body, "sidebar-minimized");
    classes.toggle(body, "brand-minimized");
    resizeBroadcast();
  }

  toggleAsideMenu() {
    const body = this.bodyTarget;
    classes.toggle(body, "aside-menu-hidden");
    resizeBroadcast();
  }

  toggleMobileSidebar() {
    const body = this.bodyTarget;
    classes.toggle(body, "sidebar-mobile-show");
    resizeBroadcast();
  }
}
