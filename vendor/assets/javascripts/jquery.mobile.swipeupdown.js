
// jQueryMobile-SwipeUpDown
// ----------------------------------
//
// Copyright (c)2012 Donnovan Lewis
// Distributed under MIT license
//
// https://github.com/blackdynamo/jquerymobile-swipeupdown

// checked out on 2015-02-11, commit 0f1dd2f8f124861546cc0535094c1b84de2ca8ba

(function () {
// initializes touch and scroll events
    var supportTouch = $.support.touch,
        scrollEvent = "touchmove scroll",
        touchStartEvent = supportTouch ? "touchstart" : "mousedown",
        touchStopEvent = supportTouch ? "touchend" : "mouseup",
        touchMoveEvent = supportTouch ? "touchmove" : "mousemove";

    // handles swipeup and swipedown
    $.event.special.swipeupdown = {
        setup: function () {
            var thisObject = this;
            var $this = $(thisObject);

            $this.bind(touchStartEvent, function (event) {
                var data = event.originalEvent.touches ?
                        event.originalEvent.touches[ 0 ] :
                        event,
                    start = {
                        time: (new Date).getTime(),
                        coords: [ data.pageX, data.pageY ],
                        origin: $(event.target)
                    },
                    stop;

                function moveHandler(event) {
                    if (!start) {
                        return;
                    }

                    var data = event.originalEvent.touches ?
                        event.originalEvent.touches[ 0 ] :
                        event;
                    stop = {
                        time: (new Date).getTime(),
                        coords: [ data.pageX, data.pageY ]
                    };


                    // prevent scrolling
                    // DISABLED BY chetan - we want the normal scrolling action
                    // if (Math.abs(start.coords[1] - stop.coords[1]) > 10) {
                    //     event.preventDefault();
                    // }
                }

                $this
                    .bind(touchMoveEvent, moveHandler)
                    .one(touchStopEvent, function (event) {
                        $this.unbind(touchMoveEvent, moveHandler);
                        if (start && stop) {
                            var dX = Math.abs(start.coords[0] - stop.coords[0]),
                                dY = Math.abs(start.coords[1] - stop.coords[1]);
                            if (stop.time - start.time < 1000 && dY > 30 && dX < 75) {
                                // ADDED BY chetan - pass info in eventData - function(e, info){}
                                var info = {start: start, stop: stop, deltaX: dX, deltaY: dY};
                                start.origin
                                    .trigger("swipeupdown", info)
                                    .trigger(start.coords[1] > stop.coords[1] ? "swipeup" : "swipedown", info);
                            }
                        }
                        start = stop = undefined;
                    });
            });
        }
    };

//Adds the events to the jQuery events special collection
    $.each({
        swipedown: "swipeupdown",
        swipeup: "swipeupdown"
    }, function (event, sourceEvent) {
        $.event.special[event] = {
            setup: function () {
                $(this).bind(sourceEvent, $.noop);
            }
        };
        //Adds new events shortcuts
        $.fn[ event ] = function( fn ) {
            return fn ? this.bind( event, fn ) : this.trigger( event );
        };
        // jQuery < 1.8
        if ( $.attrFn ) {
            $.attrFn[ event ] = true;
        }
    });

})();
