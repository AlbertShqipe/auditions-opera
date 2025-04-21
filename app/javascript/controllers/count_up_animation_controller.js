import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="count-up-animation"
export default class extends Controller {
  static targets = ["number"]

  connect() {
    this.numberTargets.forEach((el) => {
      const target = parseInt(el.dataset.target, 10)
      const duration = 1000 // 1 second
      const frameRate = 60
      const totalFrames = duration / (1000 / frameRate)
      let frame = 0

      const counter = () => {
        frame++
        const progress = frame / totalFrames
        const current = Math.round(target * progress)

        el.textContent = current

        if (frame < totalFrames) {
          requestAnimationFrame(counter)
        } else {
          el.textContent = target
        }
      }

      requestAnimationFrame(counter)
    })
  }
}
