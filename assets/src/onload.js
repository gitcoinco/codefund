import "selectize";
import $ from "jquery";

const initSelectize = () => {
  $("select.selectize").selectize({
    plugins: ["remove_button"],
    delimiter: ",",
    persist: false
  });
};

$(function () {
  initSelectize();
});
