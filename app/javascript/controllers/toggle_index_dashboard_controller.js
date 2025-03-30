import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="toggle-index-dashboard"
export default class extends Controller {
  static targets = ["table", "index"];

  connect() {
    console.log("ToggleIndexDashboard connected!");
    this.hideIndex(); // Ensure the index is hidden on load
  }

  toggleView(event) {
    event.preventDefault();
    if (this.indexTarget.style.display === "none") {
      this.showIndex();
    } else {
      this.hideIndex();
    }
  }

  showIndex() {
    this.indexTarget.style.display = "block";
    this.tableTarget.closest("#dashboard").style.display = "none";
  }

  hideIndex() {
    this.indexTarget.style.display = "none";
    this.tableTarget.closest("#dashboard").style.display = "block";
  }
}
