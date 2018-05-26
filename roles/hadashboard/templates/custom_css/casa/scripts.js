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
                    window.location.href = returnURI + "?skin=casa";
                } else {
                    window.location.href = "/Hallway?skin=casa";
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
        let houseMode = $("#default-house-mode .value").html().toLowerCase();
        // if houseMode is set to away or sleeping and we're not already on the Lockscreen -> navigate to lockscreen
        if ((houseMode == "weg" || houseMode == "slapen") && (window.location.pathname.indexOf("LockScreen") < 0)) {
            window.location.href = "/LockScreen?skin=casa&returnURI=" + window.location.pathname;
        }
    }
    autoLockScreen();
    $("#default-house-mode .value").bind('DOMSubtreeModified', autoLockScreen);

    // #FUTURE: value colorization

    // #default-rijtijd-ilse .value {
    //     color: red !important;
    // }

});

// Disable scrolling on iOS:
// https://stackoverflow.com/questions/7768269/ipad-safari-disable-scrolling-and-bounce-effect
document.ontouchmove = function (event) {
    event.preventDefault();
};