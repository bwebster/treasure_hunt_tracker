// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"
import "bootstrap"

document.addEventListener("DOMContentLoaded", () => {
    const tabElements = document.querySelectorAll('a[data-bs-toggle="tab"]');

    // Function to switch tabs when clicked
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
});
