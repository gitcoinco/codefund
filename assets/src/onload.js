import "selectize";
import $ from "jquery";

const initSelectize = () => {
  $("select.selectize").selectize({
    plugins: ["remove_button"],
    delimiter: ",",
    persist: false
  });
};

const initFontAwesome = () => {
  return FontAwesome.dom.i2svg();
};

document.addEventListener("turbolinks:load", () => {
  initSelectize();
  initFontAwesome();
});
