import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="lang"
export default class extends Controller {
  static targets = ["link"]

  connect() {
    const currentLocale = document.documentElement.lang // e.g., "en" or "fr"
    console.log("Current locale:", currentLocale)

    this.linkTargets.forEach(link => {
      console.log("Link locale:", link.dataset.locale)
      if (link.dataset.locale === currentLocale) {
        link.classList.add("locale-active") // or your style
      } else {
        link.classList.remove("locale-active")
      }
    })
  }
}
