import { Controller } from "stimulus";
import _ from "lodash";
import moment from "moment";
import Chart from "chart.js";
import daterangepicker from "bootstrap-daterangepicker";

import $ from "jquery/dist/jquery";
/* 
import jQuery from "detached-jquery-1.10.2";
const $ = jQuery.getJQuery(); */

export default class extends Controller {
  static get targets() {
    return ["trafficImpressionsChart", "trafficClicksChart", "dateRange"];
  }

  connect() {
    const impressionsByDay = JSON.parse(this.element.dataset.impressionsByDay);
    const clicksByDay = JSON.parse(this.element.dataset.clicksByDay);

    this.loadTrafficImpressionsChart(impressionsByDay);
    this.loadTrafficClicksChart(clicksByDay);

    this.initDatePicker();

    console.log("Loaded dashboard");
  }

  initDatePicker() {
    const startDate = this.element.dataset.startDate;
    const endDate = this.element.dataset.endDate;

    const picker = $(this.dateRangeTarget);
    picker.daterangepicker(
      {
        startDate: moment(startDate),
        endDate: moment(endDate)
      },
      (start, end) => {
        console.log(start, end);
      }
    );

    console.log(startDate);
    console.log(endDate);

    picker.on("apply.daterangepicker", (ev, picker) => {
      console.log("APPLYING");
    });
  }

  strToDate(str) {
    return moment(str);
  }

  loadTrafficImpressionsChart(impressionsByDay) {
    const ctx = this.trafficImpressionsChartTarget.getContext("2d");

    const options = {
      responsive: true,
      scales: {
        xAxes: [
          {
            type: "time",
            time: {
              format: "MM/DD/YYYY",
              unit: "day"
            }
          }
        ]
      }
    };

    const labels = _.map(_.keys(impressionsByDay), this.strToDate);

    const data = {
      labels,
      datasets: [
        {
          label: "Impressions",
          backgroundColor: "rgba(220,220,220,0.2)",
          borderColor: "rgba(220,220,220,1)",
          pointBackgroundColor: "rgba(220,220,220,1)",
          pointBorderColor: "#fff",
          data: _.values(impressionsByDay)
        }
      ]
    };

    return new Chart(ctx, { type: "line", data, options });
  }

  loadTrafficClicksChart(clicksByDay) {
    const ctx = this.trafficClicksChartTarget.getContext("2d");

    const options = {
      responsive: true,
      scales: {
        xAxes: [
          {
            type: "time",
            time: {
              format: "MM/DD/YYYY",
              unit: "day"
            }
          }
        ]
      }
    };

    const labels = _.map(_.keys(clicksByDay), this.strToDate);

    const data = {
      labels,
      datasets: [
        {
          label: "Clicks",
          backgroundColor: "rgba(151,187,205,0.2)",
          borderColor: "rgba(151,187,205,1)",
          pointBackgroundColor: "rgba(151,187,205,1)",
          pointBorderColor: "#fff",
          data: _.values(clicksByDay)
        }
      ]
    };

    return new Chart(ctx, { type: "line", data, options });
  }
}
