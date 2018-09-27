/* flatpickr v4.5.1, @license MIT */
(function (global, factory) {
    typeof exports === 'object' && typeof module !== 'undefined' ? module.exports = factory() :
    typeof define === 'function' && define.amd ? define(factory) :
    (global.confirmDatePlugin = factory());
}(this, (function () { 'use strict';

    var defaultConfig = {
      confirmIcon: "<svg version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink' width='17' height='17' viewBox='0 0 17 17'> <g> </g> <path d='M15.418 1.774l-8.833 13.485-4.918-4.386 0.666-0.746 4.051 3.614 8.198-12.515 0.836 0.548z' fill='#000000' /> </svg>",
      confirmText: "OK ",
      showAlways: false,
      theme: "light"
    };

    function confirmDatePlugin(pluginConfig) {
      var config = Object.assign({}, defaultConfig, pluginConfig);
      var confirmContainer;
      return function (fp) {
        if (fp.config.noCalendar || fp.isMobile) return {};
        return Object.assign({
          onKeyDown: function onKeyDown(_, __, ___, e) {
            if (fp.config.enableTime && e.key === "Tab" && e.target === fp.amPM) {
              e.preventDefault();
              confirmContainer.focus();
            } else if (e.key === "Enter" && e.target === confirmContainer) fp.close();
          },
          onReady: function onReady() {
            confirmContainer = fp._createElement("div", "flatpickr-confirm " + (config.showAlways ? "visible" : "") + " " + config.theme + "Theme", config.confirmText);
            confirmContainer.tabIndex = -1;
            confirmContainer.innerHTML += config.confirmIcon;
            confirmContainer.addEventListener("click", fp.close);
            fp.calendarContainer.appendChild(confirmContainer);
          }
        }, !config.showAlways ? {
          onChange: function onChange(_, dateStr) {
            var showCondition = fp.config.enableTime || fp.config.mode === "multiple";
            if (dateStr && !fp.config.inline && showCondition) return confirmContainer.classList.add("visible");
            confirmContainer.classList.remove("visible");
          }
        } : {});
      };
    }

    return confirmDatePlugin;

})));
