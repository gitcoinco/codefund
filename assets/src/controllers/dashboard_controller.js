import { Controller } from "stimulus";
import _ from "lodash";
import Chart from "chart.js";

export default class extends Controller {
  static get targets() {
    return ["trafficImpressionsChart", "trafficClicksChart"];
  }

  connect() {
    const impressionsByDay = JSON.parse(this.element.dataset.impressionsByDay);
    const clicksByDay = JSON.parse(this.element.dataset.clicksByDay);
    this.loadTrafficImpressionsChart(impressionsByDay);
    this.loadTrafficClicksChart(clicksByDay);

    console.log("Loaded dashboard");
  }

  loadTrafficImpressionsChart(impressionsByDay) {
    const ctx = this.trafficImpressionsChartTarget.getContext("2d");

    const options = {
      responsive: true,
      scales: {
        xAxes: [
          {
            time: {
              unit: "day"
            }
          }
        ]
      }
    };

    const data = {
      labels: _.keys(impressionsByDay),
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
            time: {
              unit: "day"
            }
          }
        ]
      }
    };

    const data = {
      labels: _.keys(clicksByDay),
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
