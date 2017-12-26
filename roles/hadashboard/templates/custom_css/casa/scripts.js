$(document).ready(function () {
    $("#default-monitoring-checks-status").click(function () {
        if (window.location.pathname.indexOf("Phone") >= 0){
            window.location.href = "/Phone_Monitoring?skin=casa"
        } else {
            window.location.href = "/Monitoring?skin=casa"
        }
    });
});

// Disable scrolling on iOS:
// https://stackoverflow.com/questions/7768269/ipad-safari-disable-scrolling-and-bounce-effect
document.ontouchmove = function (event) {
    event.preventDefault();
};