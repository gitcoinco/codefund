import "selectize";
import $ from "jquery";

const initSelectize = () => {
  $("select.selectize").selectize({
    plugins: ["remove_button"],
    delimiter: ",",
    persist: false
  });
};

document.addEventListener("turbolinks:load", () => {
  initSelectize();
});
