import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="slideshow"
export default class extends Controller {
  static targets = ["slideshow"]

  connect() {
    const openButton = document.getElementById("open-toggle-menu")
    const closeButton = document.getElementById("close-toggle-menu")

    if (openButton) {
      openButton.addEventListener("click", () => this.openMenu())
    }

    if (closeButton) {
      closeButton.addEventListener("click", () => this.closeMenu())
    }
  }

  openMenu() {
    document.getElementById("open-toggle-menu").classList.add("open")
    this.slideshowTarget.classList.add("open")
  }

  closeMenu() {
    document.getElementById("open-toggle-menu").classList.remove("open")
    this.slideshowTarget.classList.remove("open")
  }
}
