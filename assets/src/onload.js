import 'selectize';
import $ from 'jquery';

const initSelectize = () => {
  $('select.selectize').selectize({
    plugins: ['remove_button'],
    delimiter: ',',
    persist: false,
    onDropdownClose: _dropdown => {},
  });
};

const initFontAwesome = () => FontAwesome.dom.i2svg();
document.addEventListener('turbolinks:load', () => {
  initSelectize();
  initFontAwesome();
});
