// import { Controller } from "stimulus";
// import axios from "../utils/axios";
// import qs from "qs";
// import $ from "jquery/dist/jquery";
// import _ from "lodash";

// export default class extends Controller {
//   static get targets() {
//     return [
//       "name",
//       "programmingLanguages",
//       "topicCategories",
//       "excludedCountries",
//       "uniqueUserCount",
//       "propertyCount",
//       "impressionCount"
//     ];
//   }

//   connect() {
//     this.payload = {
//       filters: {
//         programming_languages: [],
//         topic_categories: [],
//         excluded_countries: []
//       }
//     };
//     this.initSelectize();
//   }

//   initSelectize() {
//     $("select.audience-form-selectize")
//       .selectize({
//         plugins: ["remove_button"],
//         delimiter: ",",
//         persist: false
//       })
//       .on("change", this.generateEstimates.bind(this));
//   }

//   generateEstimates(event) {
//     let payload = this.payload;
    
//     console.log(payload);

//     if (event.currentTarget.attributes.class.value.includes("audience-form-selectize")) {
//       const options = _.map(event.currentTarget.selectedOptions, (opt) => {
//         return opt.value;
//       });
//       payload['filters'][event.currentTarget.dataset.key] = options;
//     } else {
//       payload['filters'][event.currentTarget.dataset.key] = event.currentTarget.value;
//     }
//     this.payload = payload;
//     const query = qs.stringify(this.payload, { arrayFormat: "brackets" });
//     axios({
//       url: `/audience_metrics?${query}`,
//       method: 'GET',
//       headers: {
//         'content-type': 'application/x-www-form-urlencoded'
//       }
//     }).then(this.handleMetricsResponse.bind(this));
//   }

//   handleMetricsResponse(response) {
//     if (response.status === 200) {
//       this.uniqueUserCountTarget.innerText = response.data.unique_user_count;
//       this.propertyCountTarget.innerText = response.data.property_count;
//       this.impressionCountTarget.innerText = response.data.impression_count;
//     } else {
//       this.uniqueUserCountTarget.innerText = "-";
//       this.propertyCountTarget.innerText = "-";
//       this.impressionCountTarget.innerText = "-";
//     }
//   }

//   get payload() {
//     return JSON.parse(this.data.get("payload"));
//   }

//   set payload(value) {
//     this.data.set("payload", JSON.stringify(value));
//   }
// }