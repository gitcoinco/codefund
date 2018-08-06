import { Controller } from "stimulus";
import _ from "lodash";
import moment from "moment";
import daterangepicker from "bootstrap-daterangepicker";

import $ from "jquery/dist/jquery";

export default class extends Controller {
  static get targets() {
    return [
      "datePicker",
      "startDate",
      "endDate"
    ];
  }

  connect() {
    this.initDatePicker();
  }
  initDatePicker() {
    var that = this;
    const startDate = _.isEmpty(this.startDateTarget.value)
      ? moment()
      : moment(this.startDateTarget.value);

    const endDate = _.isEmpty(this.endDateTarget.value)
      ? moment()
      : moment(this.endDateTarget.value);

    const beginDate = startDate > moment() ? moment() : startDate;

    const picker = $(this.datePickerTarget);

    this.populateDateFields(startDate, endDate);

    picker.daterangepicker(
      {
        startDate: startDate,
        endDate: endDate,
        minDate: beginDate,
        ranges: {
          'Today': [moment(), moment()],
          'Tomorrow': [moment().add(1, 'days'), moment().add(1, 'days')],
          'Next 7 Days': [moment(), moment().add(6, 'days')],
          'Next 30 Days': [moment(), moment().add(29, 'days')],
          'This Month': [moment().startOf('month'), moment().endOf('month')],
          'Next Month': [moment().add(1, 'month').startOf('month'), moment().add(1, 'month').endOf('month')]
        }
      },
      function(start, end, label) {
       that.populateDateFields(start, end);
      });

    picker.on("show.daterangepicker", () => {
      $(".main").css("opacity", 0.5);
    });

    picker.on("hide.daterangepicker", () => {
      $(".main").css("opacity", 1);
    });
  }

  populateDateFields(start, end) {
    this.startDateTarget.value = `${moment(start).format("YYYY-MM-DD")}`;
    this.endDateTarget.value = `${moment(end).format("YYYY-MM-DD")}`;
    this.datePickerTarget.innerHTML = `${start} - ${end}`;
  }
}
