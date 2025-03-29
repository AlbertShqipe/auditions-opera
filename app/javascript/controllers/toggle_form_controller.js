import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="toggle-form"
export default class extends Controller {
  connect() {
    console.log("ToggleFormController connected");
  }
  static targets = ["form"];

  toggle() {
    this.formTarget.classList.toggle("hidden");
  }
}
