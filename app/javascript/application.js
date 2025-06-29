// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"
import "bootstrap"
import "channels/register_channel";
import "channels/display_channel";
import "tom-select";

document.addEventListener("turbo:load", () => {
    const register = "Enter Registration Mode";
    const exitRegistration = "Exit Registration Mode";

    const display = "Enter Display Mode";
    const exitDisplay = "Exit Display Mode";

    document.querySelectorAll(".searchable-select").forEach((el) => {
        const sel = new TomSelect(el, {
            // openOnFocus: true,
            maxItems: 1,
            allowEmptyOption: true,
            create: true,
            plugins: ['clear_button'],
            persist: false // Don't re-add deleted items automatically
        });
        sel.focus();
    });

    // Registration setup
    document.querySelectorAll(".toggle-registration").forEach(button => {
        button.addEventListener("click", (event) => {
            const number = event.target.getAttribute("data-location-id");

            const locationNumber = localStorage.getItem("listening_enabled");
            if (locationNumber === number) {
                event.target.innerHTML = register;
                localStorage.removeItem("listening_enabled");
                console.log(`✅ Registration exited for location ${locationNumber}`);
            } else {
                document.querySelectorAll(`.toggle-registration[data-location-id="${locationNumber}"]`).forEach(el => {
                    el.innerHTML = register;
                });

                localStorage.setItem("listening_enabled", number);
                event.target.innerHTML = exitRegistration;
                console.log(`✅ Registration entered for location ${number}`);
                window.location.href = '/register';
            }
        });
    });

    const locationNumber = localStorage.getItem("listening_enabled");
    console.log("Current location number", locationNumber);
    if (locationNumber) {
        console.log(`✅ Registration entered for location ${locationNumber} at load`);
        document.querySelectorAll(`.toggle-registration`).forEach(el => {
            el.innerHTML = register;
        });
        document.querySelectorAll(`.toggle-registration[data-location-id="${locationNumber}"]`).forEach(el => {
            el.innerHTML = exitRegistration;
        });
        document.querySelectorAll('input[name="registration_mode"]').forEach(el => {
            el.value = true;
        });
        document.querySelectorAll('.rfid_tag_edit_cancel').forEach(el => {
            el.href = "/register";
        });
    }

    // Display setup
    document.querySelectorAll(".toggle-display").forEach(button => {
        button.addEventListener("click", (event) => {
            const number = event.target.getAttribute("data-location-id");

            const locationNumber = localStorage.getItem("display.listening_enabled");
            console.log(`Currently listening for display events for location ${locationNumber}`);
            if (locationNumber === number) {
                event.target.innerHTML = display;
                localStorage.removeItem("display.listening_enabled");
                console.log(`✅ Display exited for location ${locationNumber}`);
            } else {
                document.querySelectorAll(`.toggle-display[data-location-id="${locationNumber}"]`).forEach(el => {
                    el.innerHTML = display;
                });

                localStorage.setItem("display.listening_enabled", number);
                event.target.innerHTML = exitDisplay;
                console.log(`✅ Display entered for location ${number}`);
                window.location.href = '/display';
            }
        });
    });

    const displayLocationNumber = localStorage.getItem("display.listening_enabled");
    console.log("Current display location number", displayLocationNumber);
    if (displayLocationNumber) {
        console.log(`✅ Display entered for location ${displayLocationNumber} at load`);
        document.querySelectorAll(`.toggle-display`).forEach(el => {
            el.innerHTML = display;
        });
        document.querySelectorAll(`.toggle-display[data-location-id="${displayLocationNumber}"]`).forEach(el => {
            el.innerHTML = exitDisplay;
        });
    }

    const tabElements = document.querySelectorAll('a[data-bs-toggle="tab"]');
    tabElements.forEach(tab => {
        tab.addEventListener("click", function (event) {
            event.preventDefault();
            const tabInstance = new bootstrap.Tab(this);
            tabInstance.show();

            // Store the selected tab in the URL hash
            history.pushState(null, null, this.getAttribute("href"));
        });
    });

    // On page load, check if a tab is specified in the URL hash
    const activeTab = window.location.hash;
    if (activeTab) {
        const tabToActivate = document.querySelector(`a[href="${activeTab}"]`);
        if (tabToActivate) {
            new bootstrap.Tab(tabToActivate).show();
        }
    }

    const flashContainer = document.getElementById("flash-container");
    if (flashContainer) {
        setTimeout(() => {
            flashContainer.style.transition = "opacity 0.5s ease-out";
            flashContainer.style.opacity = "0";
            setTimeout(() => flashContainer.remove(), 500); // Remove after fade-out
        }, 5000); // 5-second delay
    }
});
