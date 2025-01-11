let seatbeltUI = document.getElementById("seatbelt");
let warningSound = null;

window.addEventListener("message", function (event) {
    switch (event.data.action) {
        case "showUI":
            seatbeltUI.classList.remove("hidden");
            break;

        case "hideUI":
            seatbeltUI.classList.add("hidden"); // Add the hidden class to hide the UI
            seatbeltUI.classList.remove("flashing");
            break;

        case "flashWarning":
            seatbeltUI.classList.add("flashing");
            break;

        case "stopWarning":
            seatbeltUI.classList.remove("flashing");
            break;

        case "playSound":
            let audio = new Audio(`sounds/${event.data.sound}.ogg`);
            audio.play();
            break;

        case "playLoopedWarning":
            if (!warningSound) {
                warningSound = new Audio(`sounds/warning.ogg`);
                warningSound.loop = true;
                warningSound.play();
            }
            break;

        case "stopLoopedWarning":
            if (warningSound) {
                warningSound.pause();
                warningSound.currentTime = 0;
                warningSound = null;
            }
            break;
    }
});
