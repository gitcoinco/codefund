import { Controller } from "stimulus";
import _ from "lodash";
import moment from "moment";
import Chart from "chart.js";
import daterangepicker from "bootstrap-daterangepicker";

import $ from "jquery/dist/jquery";

export default class extends Controller {
  static get targets() {
    return [
      "datePicker",
      "date",
    ];
  }

  connect() {
    this.initDatePicker();
  }

  initDatePicker() {
    const { date } = this.element.dataset;

    const picker = $(this.datePickerTarget);
    $(this.dateTarget)[0].value = moment().startOf('month').format("YYYY-MM-DD");

    picker.daterangepicker(
      {
        date: moment(date),
        startDate: moment().startOf('month'),
        endDate: moment().endOf('month'),
        maxDate: moment().endOf('month'),
        showCustomRangeLabel: false,
        ranges: {
          'Two Months Ago': [moment().subtract(2, 'month').startOf('month'), moment().subtract(2, 'month').endOf('month')],
          'Last Month': [moment().subtract(1, 'month').startOf('month'), moment().subtract(1, 'month').endOf('month')],
          'This Month': [moment().startOf('month'), moment().endOf('month')],

        }
      },
      (start, end) => {
        $(this.dateTarget)[0].value = `${moment(start).format("YYYY-MM-DD")}`;
      }
    );

    picker.on("show.daterangepicker", () => {
      $(".main").css("opacity", 0.5);
    });
    picker.on("hide.daterangepicker", () => {
      $(".main").css("opacity", 1);
    });
  }
}
