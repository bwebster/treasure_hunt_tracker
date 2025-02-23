 import consumer from "channels/consumer";

document.addEventListener("turbo:load", () => {
    consumer.subscriptions.create("RegisterChannel", {
        connected() {
            console.log("✅ WebSocket Connected to RegisterChannel!");
        },

        disconnected() {
            console.log("⚠️ WebSocket Disconnected! Trying to reconnect...");
        },

        received(data) {
            console.log("Received event data:", data);

            const locationNumber = localStorage.getItem("listening_enabled");
            if (locationNumber == data.location_number) {
                window.location.href = `/rfid_tags/${data.rfid_id}/edit`;
            } else {
                console.log("Skipping event b/c location ", data.location_number, " != ", locationNumber);
            }
        }
    });
});
