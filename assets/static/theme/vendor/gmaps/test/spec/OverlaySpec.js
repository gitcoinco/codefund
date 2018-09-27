describe("Drawing HTML overlays", function() {
  var map_with_overlays, overlay;

  beforeEach(function() {
    map_with_overlays = map_with_overlays || new GMaps({
      el : '#map-with-overlays',
      lat : -12.0433,
      lng : -77.0283,
      zoom : 12
    });

    overlay = overlay || map_with_overlays.drawOverlay({
      lat: map_with_overlays.getCenter().lat(),
      lng: map_with_overlays.getCenter().lng(),
      layer: 'overlayLayer',
      content: '<div class="overlay">Lima</div>',
      verticalAlign: 'top',
      horizontalAlign: 'center'
    });
  });

  it("should add the overlay to the overlays collection", function() {
    expect(map_with_overlays.overlays.length).toEqual(1);
    expect(map_with_overlays.overlays[0]).toEqual(overlay);
  });

  it("should add the overlay in the current map", function() {
    expect(overlay.getMap()).toEqual(map_with_overlays.map);
  });

  describe("With events", function() {
    var callbacks, overlayWithClick;

    beforeEach(function() {
      callbacks = {
        onclick: function() {
          console.log('Clicked the overlay');
        }
      };

      spyOn(callbacks, 'onclick').andCallThrough();

      overlayWithClick = map_with_overlays.drawOverlay({
        lat: map_with_overlays.getCenter().lat(),
        lng: map_with_overlays.getCenter().lng(),
        content: '<p>Clickable overlay</p>',
        click: callbacks.onclick
      });
    });

    it("should respond to click event", function() {
      var domIsReady = false;

      google.maps.event.addListenerOnce(overlayWithClick, "ready", function () {
        domIsReady = true;
      });

      waitsFor(function () {
        return domIsReady;
      }, "the overlay's DOM element to be ready", 10000);

      runs(function () {
        google.maps.event.trigger(overlayWithClick.el, "click");
        expect(callbacks.onclick).toHaveBeenCalled();
      });
    });
  });
});