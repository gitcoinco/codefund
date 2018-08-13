/* Theme Name: Canvab - Responsive Landing Page Template
   Author: Themesbrand
   Version: 1.0.0
   File Description: Main JS file of the template
*/

! function($) {
    "use strict";

    var CanvabApp = function() {};

    //scroll
    CanvabApp.prototype.initSticky = function() {
        $(window).scroll(function() {
            var scroll = $(window).scrollTop();

            if (scroll >= 40) {
                $(".sticky").addClass("darkheader");
            } else {
                $(".sticky").removeClass("darkheader");
            }
        });
    },

    CanvabApp.prototype.initAnimatedScrollMenu = function() {
        $('.navigation-menu a').on('click', function(event) {
            var $anchor = $(this);
            $('html, body').stop().animate({
                scrollTop: $($anchor.attr('href')).offset().top - 0
            }, 1500, 'easeInOutExpo');
            event.preventDefault();
        });
    },

    CanvabApp.prototype.initMainMenu = function() {
        var scroll = $(window).scrollTop();

        $('.navbar-toggle').on('click', function(event) {
            $(this).toggleClass('open');
            $('#navigation').slideToggle(400);
        });

        $('.navigation-menu>li').slice(-2).addClass('last-elements');

        $('.menu-arrow,.submenu-arrow').on('click', function(e) {
            if ($(window).width() < 992) {
                e.preventDefault();
                $(this).parent('li').toggleClass('open').find('.submenu:first').toggleClass('open');
            }
        });
    },

    CanvabApp.prototype.init = function() {
        this.initSticky();
        this.initAnimatedScrollMenu();
        this.initMainMenu();
    },
    $.CanvabApp = new CanvabApp, $.CanvabApp.Constructor = CanvabApp
}(window.jQuery),

//initializing
function($) {
    "use strict";
    $.CanvabApp.init();
}(window.jQuery);