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
    resetTimer();
};

// Automatically navigate to homepage after inactivity.
// somewhat based on https://www.kirupa.com/html5/detecting_if_the_user_is_idle_or_inactive.htm

document.addEventListener("mousemove", resetTimer, false);
document.addEventListener("mousedown", resetTimer, false);
document.addEventListener("keypress", resetTimer, false);
document.addEventListener("DOMMouseScroll", resetTimer, false);
document.addEventListener("mousewheel", resetTimer, false);
document.addEventListener("touchmove", resetTimer, false);
document.addEventListener("MSPointerMove", resetTimer, false);

var timeoutID;
startTimer();
     
function startTimer() {
    timeoutID = window.setTimeout(goInactive, 120000);
}
     
function resetTimer(e) {
    window.clearTimeout(timeoutID);
    startTimer();
    console.log("Inactivity timer reset");
}
     
function goInactive() {
    console.log("User inactive, navigating to the homepage");
    // Only do this when you're not on the homepage
    if (window.location.pathname.indexOf("Home") <= 0) {
        // Navigate back to the homepage
        if (window.location.pathname.indexOf("Phone") >= 0){
            window.location.href = "/Phone_Home?skin=casa"
        } else {
            window.location.href = "/Home?skin=casa"
        }
    }
}
 