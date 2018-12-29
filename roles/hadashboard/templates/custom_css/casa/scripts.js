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
            window.location.href = "/Phone_Monitoring?skin=casa"
        } else {
            window.location.href = "/Monitoring?skin=casa"
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
    $("#default-rijtijd-ilse .value, #default-rijtijd-ilse .unit").bind('DOMSubtreeModified', function (e) {
        let driveTime = parseInt($("#default-rijtijd-ilse .value").html());
        if (driveTime < 40) {
            $("#default-rijtijd-ilse .value, #default-rijtijd-ilse .unit").css("color", "#45b71b");
        } else if (driveTime >= 40 && driveTime < 45) {
            $("#default-rijtijd-ilse .value, #default-rijtijd-ilse .unit").css("color", "#FFD700");
        } else { //driveTime > 40
            $("#default-rijtijd-ilse .value, #default-rijtijd-ilse .unit").css("color", "red");
        }
    });

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
var lastMovedTime = Date.now()
document.ontouchmove = function (event) {
    event.preventDefault();

    // Only turn scroll into a click for the first scroll event we get
    // A real scroll on iOS will invoke this function multiple times, typically a few tens of msec apart.
    // We don't want to turn all those events into clicks, since that will cause multiple toggles of the button that is
    // clicked instead of just one.
    let lastMovedDelta = Date.now() - lastMovedTime;
    lastMovedTime = Date.now();
    console.log(lastMovedDelta);
    if (lastMovedDelta > 100) {
        event.target.click();
    }
};