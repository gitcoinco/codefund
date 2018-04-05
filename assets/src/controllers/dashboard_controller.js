import { Controller } from "stimulus";
import _ from "lodash";
import moment from "moment";
import Chart from "chart.js";
import daterangepicker from "bootstrap-daterangepicker";

import $ from "jquery/dist/jquery";

export default class extends Controller {
  static get targets() {
    return [
      "trafficImpressionsChart",
      "trafficClicksChart",
      "dateRange",
      "datePicker"
    ];
  }

  connect() {
    this.impressionsByDay = JSON.parse(this.element.dataset.impressionsByDay);
    this.clicksByDay = JSON.parse(this.element.dataset.clicksByDay);

    this.impressionChart = this.loadTrafficImpressionsChart(
      this.impressionsByDay
    );
    this.clicksChart = this.loadTrafficClicksChart(this.clicksByDay);

    this.initDatePicker();
  }

  initDatePicker() {
    const { startDate, endDate } = this.element.dataset;

    const picker = $(this.datePickerTarget);

    picker.daterangepicker(
      {
        startDate: moment(startDate),
        endDate: moment(endDate),
        minDate: moment(startDate),
        maxDate: moment(endDate)
      },
      (start, end) => {
        $(this.dateRangeTarget).innerHTML = `${start} - ${end}`;
        this.updateCharts(start, end);
      }
    );

    picker.on("show.daterangepicker", () => {
      $(".main").css("opacity", 0.5);
    });
    picker.on("hide.daterangepicker", () => {
      $(".main").css("opacity", 1);
    });
  }

  strToDate(str) {
    return moment(str);
  }

  updateCharts(start, end) {
    const newImpressions = this.filterData(this.impressionsByDay, start, end);
    const newClicks = this.filterData(this.clicksByDay, start, end);

    this.replaceDatasets(this.clicksChart, newClicks);
    this.replaceDatasets(this.impressionChart, newImpressions);

    this.impressionChart.update();
    this.clicksChart.update();
  }

  replaceDatasets(chart, newData) {
    this.currentChart = chart;
    this.currentChart.data.labels = [];
    newData.labels.forEach(label => this.currentChart.data.labels.push(label));
    this.currentChart.data.datasets.forEach(dataset => {
      dataset.data = [];
      newData.data.forEach(point => dataset.data.push(point));
    });
    return this.currentChart;
  }

  filterData(raw, start, end) {
    const newLabels = [];
    this.filtered = Object.keys(raw)
      .filter(time => {
        if (
          moment(time).isAfter(start, "day") &&
          moment(time).isBefore(end, "day")
        ) {
          newLabels.push(moment(time));
          return raw[time];
        }
      })
      .map(time => raw[time]);

    return {
      data: this.filtered,
      labels: newLabels
    };
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
