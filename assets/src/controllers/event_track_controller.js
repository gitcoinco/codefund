import { Controller } from 'stimulus';

export default class extends Controller {
  logEvent(event) {
    const category = this.element.dataset.gaEventCategory;
    const action = this.element.dataset.gaEventAction;
    const label = this.element.dataset.gaEventLabel;
    const value = this.element.dataset.gaEventValue;

    if (window.debugCodeFund) {
      event.preventDefault();
      event.stopPropagation();
      console.log('Emitting GA event', category, action, label, value);
    }

    try {
      window.ga('send', 'event', {
        eventCategory: category,
        eventAction: action,
        eventLabel: label,
        eventValue: value,
      });
    } catch (ex) {
      if (window.debugCodeFund) {
        console.log(
          'Failed to emit GA event',
          category,
          action,
          label,
          value,
          ex.message
        );
      }
    }
  }
}
