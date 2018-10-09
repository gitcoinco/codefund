import { Controller } from 'stimulus';
import $ from 'jquery';

export default class extends Controller {
  connect() {
    $(this.element).selectize({
      closeAfterSelect: true,
    });
  }
}
