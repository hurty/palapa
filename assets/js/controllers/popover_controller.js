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

    let controller = this
    addEventListener("click", function (event) {
      let element = event.target

      if (element !== controller.buttonTarget) {
        controller.hide()
      }
    })
  }

  toggle() {
    this.contentTarget.classList.toggle("hidden")
    this.popover.update()
  }

  hide() {
    console.log("hide")
    this.contentTarget.classList.add("hidden")
  }
}
