import { Controller } from "stimulus";
import axios from "../utils/axios";
import qs from "qs";
import $ from "jquery/dist/jquery";
import _ from "lodash";

export default class extends Controller {
  static get targets() {
    return [
      "name",
      "programmingLanguages",
      "topicCategories",
      "excludedCountries",
      "estimatedImpressionsLow",
      "estimatedImpressionsHigh",
      "estimatedImpressionsProgress",
      "estimatedLinkClicksLow",
      "estimatedLinkClicksHigh",
      "estimatedLinkClicksProgress",
      "potentialAudienceWithData",
      "potentialAudienceWithoutData"
    ];
  }

  connect() {
    this.payload = {
      filters: {
        programming_languages: [],
        topic_categories: [],
        excluded_countries: []
      }
    };
    this.initSelectize();
  }

  initSelectize() {
    $("select.audience-form-selectize")
      .selectize({
        plugins: ["remove_button"],
        delimiter: ",",
        persist: false
      })
      .on("change", this.generateEstimates.bind(this));
  }

  generateEstimates(event) {
    let payload = this.payload;

    if (event.currentTarget.attributes.class.value.includes("audience-form-selectize")) {
      const options = _.map(event.currentTarget.selectedOptions, (opt) => {
        return opt.value;
      });
      payload['filters'][event.currentTarget.dataset.key] = options;
    } else {
      payload['filters'][event.currentTarget.dataset.key] = event.currentTarget.value;
    }

    this.payload = payload;

    const query = qs.stringify(this.payload, { arrayFormat: "brackets" });

    axios({
      url: `/audience_metrics?${query}`,
      method: 'GET',
      headers: {
        'content-type': 'application/x-www-form-urlencoded'
      }
    }).then(this.handleMetricsResponse.bind(this));
  }

  handleMetricsResponse(response) {
    if (response.status === 200) {
      const ceiling = 100000;
      const cpc = 0.03;
      const impLow = this.round((response.data.impression_count * 0.1), -3);
      const impHigh = this.round(response.data.impression_count, -3);
      const impPct = this.round((impHigh / ceiling) * 100, 0);
      const clickLow = this.round((impLow * cpc), -1);
      const clickHigh = this.round((impHigh * cpc), -1);
      const clickPct = this.round((clickHigh / (ceiling * cpc)) * 100, 0);

      this.estimatedImpressionsLowTarget.innerText = impLow.toLocaleString();
      this.estimatedImpressionsHighTarget.innerText = impHigh.toLocaleString();
      this.impressionsBar.style.width = `${impPct}%`;
      this.estimatedLinkClicksLowTarget.innerText = clickLow.toLocaleString();
      this.estimatedLinkClicksHighTarget.innerText = clickHigh.toLocaleString();
      this.linkClicksBar.style.width = `${clickPct}%`;

      this.showData();
    } else {
      this.showNoData();
    }
  }

  showData() {
    this.potentialAudienceWithoutDataTarget.classList.remove("d-block");
    this.potentialAudienceWithoutDataTarget.classList.add("d-none");
    this.potentialAudienceWithDataTarget.classList.remove("d-none");
    this.potentialAudienceWithDataTarget.classList.add("d-block");
  }

  showNoData() {
    this.potentialAudienceWithDataTarget.classList.remove("d-block");
    this.potentialAudienceWithDataTarget.classList.add("d-none");
    this.potentialAudienceWithoutDataTarget.classList.remove("d-none");
    this.potentialAudienceWithoutDataTarget.classList.add("d-block");
  }

  round(number, precision) {
    var shift = function (number, exponent) {
      var numArray = ("" + number).split("e");
      return +(numArray[0] + "e" + (numArray[1] ? (+numArray[1] + exponent) : exponent));
    };
    return shift(Math.round(shift(number, +precision)), -precision);
  }

  get payload() {
    return JSON.parse(this.data.get("payload"));
  }

  set payload(value) {
    this.data.set("payload", JSON.stringify(value));
  }

  get impressionsBar() {
    return this.targets.find('estimatedImpressionsProgress');
  }

  get linkClicksBar() {
    return this.targets.find('estimatedLinkClicksProgress');
  } 
}