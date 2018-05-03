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
      "startDate",
      "endDate"
    ];
  }

  connect() {
    this.initDatePicker();
  }

  initDatePicker() {
    const { startDate, endDate } = this.element.dataset;

    const picker = $(this.datePickerTarget);
    $(this.startDateTarget)[0].value = moment(startDate).format("YYYY-MM-DD");
    $(this.endDateTarget)[0].value =  moment(endDate).format("YYYY-MM-DD");;

    picker.daterangepicker(
      {
        startDate: moment(startDate),
        endDate: moment(endDate),
        maxDate: moment(),
        ranges: {
          'Today': [moment(), moment()],
          'Yesterday': [moment().subtract(1, 'days'), moment().subtract(1, 'days')],
          'Last 7 Days': [moment().subtract(6, 'days'), moment()],
          'Last 30 Days': [moment().subtract(29, 'days'), moment()],
          'This Month': [moment().startOf('month'), moment().endOf('month')],
          'Last Month': [moment().subtract(1, 'month').startOf('month'), moment().subtract(1, 'month').endOf('month')]
        }
      },
      (start, end) => {
        $(this.startDateTarget)[0].value = `${moment(start).format("YYYY-MM-DD")}`;
        $(this.endDateTarget)[0].value = `${moment(end).format("YYYY-MM-DD")}`;
        $(this.dateRangeTarget).innerHTML = `${start} - ${end}`;
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
