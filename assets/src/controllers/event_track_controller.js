import { Controller } from 'stimulus';

export default class extends Controller {
  logEvent(event) {
    const {
      gaEventCategory,
      gaEventAction,
      gaEventLabel,
      gaEventValue,
    } = this.element.dataset;

    const gaEventOptions = {
      hitType: 'event',
      eventCategory: gaEventCategory,
      eventAction: gaEventAction,
      eventLabel: gaEventLabel,
      eventValue: gaEventValue,
    };

    if (window.debugCodeFund) {
      event.preventDefault();
      event.stopPropagation();
      console.log('Emitting GA event', gaEventOptions);
    }

    try {
      window.ga('send', gaEventOptions);
    } catch (ex) {
      if (window.debugCodeFund) {
        console.log('Failed to emit GA event', gaEventOptions, ex.message);
      }
    }
  }
}
