import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="slideshow"
export default class extends Controller {
  static targets = ["burger", "slideshow"]

  connect() {
    this.burgerTarget.addEventListener("click", this.toggleMenu.bind(this))
  }

  toggleMenu() {
    this.burgerTarget.classList.toggle("open")
    this.slideshowTarget.classList.toggle("open")
  }
}
