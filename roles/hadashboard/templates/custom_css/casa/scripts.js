// Thank you kind sir: https://stackoverflow.com/a/21903119/381010
var getUrlParameter = function getUrlParameter(sParam) {
    var sPageURL = decodeURIComponent(window.location.search.substring(1)),
        sURLVariables = sPageURL.split('&'),
        sParameterName,
        i;

    for (i = 0; i < sURLVariables.length; i++) {
        sParameterName = sURLVariables[i].split('=');

        if (sParameterName[0] === sParam) {
            return sParameterName[1] === undefined ? true : sParameterName[1];
        }
    }
};

// Navigate to new page, retain skin
function navigate(uri) {
    window.location.href = uri + "?skin=casa";
}


$(document).ready(function () {
    $("#default-monitoring-checks-status").click(function () {
        if (window.location.pathname.indexOf("Phone") >= 0) {
            window.location.href = "/Phone_Monitoring?skin=casa&timeout=120&return=Phone_Home"
        } else {
            window.location.href = "/Monitoring?skin=casa&timeout=120&return=Home"
        }
    });

    // Pincode stuff
    if (window.location.pathname.indexOf("LockScreen") >= 0) {

        // When the house-mode changes to Home, automatically redirect to the page we were on previously
        // (fallback = Hallway)
        $("#default-house-mode .value").bind('DOMSubtreeModified', function (e) {
            if ($("#default-house-mode .value").html().toLowerCase() == "thuis") {
                let returnURI = getUrlParameter("returnURI");
                if (returnURI) {
                    navigate(returnURI);
                } else {
                    navigate("/Hallway");
                }
            }
        });

        // When clicking "OK", check the pinCode. If correct, set house to Home by doing a call to the backend,
        // otherwise show and error message
        $("#default-pincode-unlock-button").click(function () {
            let pinCodeElement = $("#default-pincode-label .value");
            let pinCode = pinCodeElement.data("pincode");
            console.log("pincode: " + pinCode);
            // on correct pincode, set house mode to home
            if (pinCode == "{{hadash_pincode}}") {
                $("#default-pincode-label .state_text").html("<span class='correct-pin'>Correct pin. Loading...</span>");
                $.post("/call_service", {
                    "service": "input_select/select_option",
                    "entity_id": "input_select.house_mode",
                    "option": "Home",
                    "namespace": "default"
                });
            } else {
                $("#default-pincode-label .state_text").html("<span class='incorrect-pin'>Incorrect pin</span>");
                pinCodeElement.html("");
                pinCodeElement.data("pincode", "");
            }
        });

        // Clear the pincode input and stored pincode when clicking clear
        $("#default-pincode-clear-button").click(function () {
            let pinCodeElement = $("#default-pincode-label .value");
            pinCodeElement.html("");
            pinCodeElement.data("pincode", "");
        });


        // Buttons for numbers. When clicking button, add the corresponding number to the known pinCode
        // Store the new pinCode in the DOM (using $.data()) and add an asterisk to the input field
        let numberButtons =
            "#default-pincode-number-1, #default-pincode-number-2, #default-pincode-number-3, " +
            "#default-pincode-number-4, #default-pincode-number-5, #default-pincode-number-6, " +
            "#default-pincode-number-7, #default-pincode-number-8, #default-pincode-number-9, " +
            "#default-pincode-number-0";

        $(numberButtons).click(function (event) {
            let pinCodeElement = $("#default-pincode-label .value");
            let existingPin = pinCodeElement.data("pincode") || "";
            let elementParts = event.currentTarget.id.split("-");
            let number = elementParts[elementParts.length - 1];
            let newPinCode = existingPin + number;
            pinCodeElement.data("pincode", newPinCode);
            pinCodeElement.html(new Array(newPinCode.length + 1).join("*")); // fill input field with asterisks
            $("#default-pincode-label .state_text").html(""); // remove any prior status messages
        });
    }

    function autoLockScreen() {
        let houseMode = $("#default-house-mode .value");
        if (houseMode.length) {
            houseMode = houseMode.html().toLowerCase();
            // if houseMode is set to away or sleeping and we're not already on the Lockscreen -> navigate to lockscreen
            if ((houseMode == "weg" || houseMode == "slapen") && (window.location.pathname.indexOf("LockScreen") < 0)) {
                window.location.href = "/LockScreen?skin=casa&returnURI=" + window.location.pathname;
            }
        }
    }
    autoLockScreen();
    $("#default-house-mode .value").bind('DOMSubtreeModified', autoLockScreen);

    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // RIJTIJD COLORIZATION
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    // Drive Time value colorization
    function colorizeDrivingTime(e) {
        let driveTime = parseInt($("#default-rijtijd-ilse .value").html());
        if (driveTime < 40) {
            $("#default-rijtijd-ilse .value, #default-rijtijd-ilse .unit").css("color", "#45b71b");
        } else if (driveTime >= 40 && driveTime < 45) {
            $("#default-rijtijd-ilse .value, #default-rijtijd-ilse .unit").css("color", "#FFD700");
        } else { //driveTime > 40
            $("#default-rijtijd-ilse .value, #default-rijtijd-ilse .unit").css("color", "red");
        }
    }

    $("#default-rijtijd-ilse .value, #default-rijtijd-ilse .unit").bind('DOMSubtreeModified', colorizeDrivingTime);
    // for Safari on initial load, Chrome will need the DOMSubtreeModified event as the initial content is empty
    colorizeDrivingTime();


    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // PACKAGE DELIVERY COLORIZATION
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    // Drive Time value colorization
    function colorizePackageDelivery(e) {
        let packageCount = parseInt($("#default-package-delivery .value").html());
        if (packageCount > 0) {
            $(".widget-basedisplay-default-package-delivery").css("background", "#d88014");
        } else {
            $(".widget-basedisplay-default-package-delivery").css("background", "");
        }
    }

    $("#default-package-delivery .value").bind('DOMSubtreeModified', colorizePackageDelivery);
    // for Safari on initial load, Chrome will need the DOMSubtreeModified event as the initial content is empty
    colorizePackageDelivery();

    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // TRASH COLORIZATION
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // Trash Pickup colorization

    function colorizeTrashPickup(e) {
        let pickupDate = $("#default-trash-pickup .state_text").html();
        if (pickupDate == "" || pickupDate == undefined) return;
        let dateParts = pickupDate.split("-");
        let pickupDateTs = new Date(parseInt(dateParts[0]), parseInt(dateParts[1]) - 1, parseInt(dateParts[2]), 0, 0, 0).getTime(); // time = midnight (current timezone)
        let day_before_4pm = pickupDateTs - (8 * 60 * 60 * 1000); // 4pm = 8 hrs before midnight
        let day_itself_11am = pickupDateTs + (11 * 60 * 60 * 1000); // 11am = 11 hrs after midnight
        let nowTs = new Date().getTime();
        let pickupType = $("#default-trash-pickup .value").html().toUpperCase();

        if (nowTs > day_before_4pm && nowTs < day_itself_11am) {
            $("#default-trash-pickup .value").css("text-shadow", "-1px 0 white, 0 1px white, 1px 0 white, 0 -1px white");
            if (pickupType == "GFT") {
                $(".widget-basedisplay-default-trash-pickup").css("background", "#55ad68");
                $("#default-trash-pickup .value").css("color", "#1b5e20");
            } else if (pickupType == "PAPIER") {
                $(".widget-basedisplay-default-trash-pickup").css("background", "#4853d2");
                $("#default-trash-pickup .value").css("color", "#202886");
            } else if (pickupType == "PLASTIC") {
                $(".widget-basedisplay-default-trash-pickup").css("background", "#d88014");
                $("#default-trash-pickup .value").css("color", "#f7ae53");
            }
        } else {
            // reset styles when date no longer in notification range
            $(".widget-basedisplay-default-trash-pickup").css("background", "");
            $("#default-trash-pickup .value").css({
                "color": "",
                "text-shadow": ""
            });

        }
    };

    $("#default-trash-pickup .value, #default-trash-pickup .state_text").bind('DOMSubtreeModified', colorizeTrashPickup);
    // for Safari on initial load, Chrome will need the DOMSubtreeModified event as the initial content is empty
    colorizeTrashPickup();

    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // CAMERAS
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    $("#default-front-garden-camera").click(function (event) {
        // TODO: make the onclick actually work
        let id = event.currentTarget.id;
    });


    $('.img-frame').on("error", function (event) {
        // if an image doesn't load properly, show a message on top of it
        let target = $(event.target);
        parent = $(target.parents(".widget"));
        if (!parent.find('.camera-offline-message').length) {
            let el = $("<div>").addClass('camera-offline-message');
            el.append($("<div>").html("Camera offline or unreachable"));
            parent.append(el);
        }
    }).on("load", function (event) {
        // remove any previous offline messages when an image loads successfully
        let target = $(event.target);
        let parent = $(target.parents(".widget"));
        parent.find('.camera-offline-message').remove();

        // On click: go to larger camera image
        let el = parent.find('.camera-clickable');
        if (el.length == 0) {
            el = $("<div>").addClass('camera-clickable');
            let camera_url = "Camera_" + parent.find(".title").text().toLowerCase().replace(/ /g, "_");
            el.on("click", function () {
                navigate(camera_url);
            });
            parent.append(el);
        }

        // TODO: fix toggle
        // let toggle = parent.find('.camera-toggle');
        // if (toggle.length == 0) {
        //     toggle = $("<div>").addClass('camera-toggle').html("toggle");
        //     toggle.on("click", function () {
        //         console.log("toggling camera");
        //         $.post("/call_service", {
        //             "service": "camera/turn_off",
        //             "entity_id": "camera.hallway",
        //         });
        //     });
        //     parent.append(toggle);
        // }

    });
});


// Disable scrolling on iOS
// https://stackoverflow.com/questions/7768269/ipad-safari-disable-scrolling-and-bounce-effect
// Instead scroll becomes a click
// TODO: consider: https://makandracards.com/makandra/51956-event-order-when-clicking-on-touch-devices
var lastMovedTime = Date.now()
document.ontouchmove = function (event) {
    event.preventDefault();
    event.stopPropagation();

    // Only turn scroll into a click for the first scroll event we get
    // A real scroll on iOS will invoke this function multiple times, typically a few tens of msec apart.
    // We don't want to turn all those events into clicks, since that will cause multiple toggles of the button that is
    // clicked instead of just one.
    let lastMovedDelta = Date.now() - lastMovedTime;
    lastMovedTime = Date.now();
    console.log(lastMovedDelta);
    if (lastMovedDelta > 1000) {
        event.target.click();
    }
};