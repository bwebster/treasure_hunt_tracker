 import consumer from "channels/consumer";

document.addEventListener("turbo:load", () => {
    consumer.subscriptions.create("DisplayChannel", {
        connected() {
            console.log("✅ WebSocket Connected to DisplayChannel!");
        },

        disconnected() {
            console.log("⚠️ WebSocket Disconnected! Trying to reconnect...");
        },

        received(data) {
            console.log("Received event data:", data);

            const locationNumber = localStorage.getItem("display.listening_enabled");
            if (locationNumber === data.location_number) {
                window.location.href = `/display?location_id=${data.location_number}&tracking_event_id=${data.tracking_event_id}`;
            } else {
                console.log("Skipping event b/c location ", data.location_number, " != ", locationNumber);
            }
        }
    });
});
