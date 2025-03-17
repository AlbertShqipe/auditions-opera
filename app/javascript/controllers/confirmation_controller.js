import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="confirmation"
export default class extends Controller {
  connect() {
    console.log("Connecting to data-controller");
  }

  confirm(event) {
    event.preventDefault();
    const message = event.target.dataset.confirmMessage;

    if (window.confirm(message)) {
      event.target.closest("form").submit();
    }
  }
}
