import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="count-up-animation"
export default class extends Controller {
  static targets = ["number"]

  connect() {
    this.numberTargets.forEach((el) => {
      const target = parseFloat(el.dataset.target) // 🔹 Allow float
      const decimals = parseInt(el.dataset.decimals || 0, 10) // 🔹 Control precision
      const duration = 1000 // 1 second
      const frameRate = 60
      const totalFrames = duration / (1000 / frameRate)
      let frame = 0

      const counter = () => {
        frame++
        const progress = frame / totalFrames
        const current = target * progress

        el.textContent = current.toFixed(decimals)

        if (frame < totalFrames) {
          requestAnimationFrame(counter)
        } else {
          el.textContent = target.toFixed(decimals)
        }
      }

      requestAnimationFrame(counter)
    })
  }
}
