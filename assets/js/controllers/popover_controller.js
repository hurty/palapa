import { Controller } from "stimulus"
import PopperJs from 'popper.js'

export default class extends Controller {
  static targets = ["button", "content", "arrow"]

  connect() {
    this.popover = new PopperJs(this.buttonTarget, this.contentTarget, {
      placement: "bottom",
      modifiers: {
        arrow: {
          element: this.arrowTarget
        }
      }
    })
  }

  toggle() {
    this.contentTarget.classList.toggle("hidden")
    this.popover.update()
  }
}
