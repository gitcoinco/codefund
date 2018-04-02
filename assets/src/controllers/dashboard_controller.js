import { Controller } from "stimulus";
import _ from "lodash";
import moment from "moment";
import Chart from "chart.js";
import daterangepicker from "bootstrap-daterangepicker";

import $ from "jquery/dist/jquery";

export default class extends Controller {
  static get targets() {
    return ["trafficImpressionsChart", "trafficClicksChart", "dateRange"];
  }

  connect() {
    this.impressionsByDay = JSON.parse(this.element.dataset.impressionsByDay);
    this.clicksByDay = JSON.parse(this.element.dataset.clicksByDay);

    this.impressionsByDay = {
      "03/01/2018": 4,
      "03/02/2018": 5,
      "03/03/2018": 2,
      "03/31/2018": 4
    };
    this.clicksByDay = {
      "03/01/2018": 1,
      "03/02/2018": 6,
      "03/10/2018": 3,
      "03/31/2018": 10
    };

    this.impressionChart = this.loadTrafficImpressionsChart(
      this.impressionsByDay
    );
    this.clicksChart = this.loadTrafficClicksChart(this.clicksByDay);

    this.initDatePicker();

    console.log("Loaded dashboard");
  }

  initDatePicker() {
    const { startDate } = this.element.dataset;
    const { endDate } = this.element.dataset;

    const picker = $(this.dateRangeTarget);
    picker.daterangepicker(
      {
        startDate: moment(startDate),
        endDate: moment(endDate),
        minDate: moment(startDate),
        maxDate: moment(endDate)
      },
      (start, end) => {
        this.updateCharts(start, end);
      }
    );
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
    console.log(newData);
    chart.data.labels.pop();
    chart.data.labels.push(newData.labels);
    chart.data.datasets.forEach(dataset => {
      dataset.data.pop();
      dataset.data.push(newData.data);
    });
    return chart;
  }

  filterData(raw, start, end) {
    const newLabels = [];
    this.filtered = Object.keys(raw).filter(time => {
      if (moment(time) > moment(start) && moment(time) < moment(end)) {
        newLabels.push(moment(time));
        return raw[time];
      }
    });
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
