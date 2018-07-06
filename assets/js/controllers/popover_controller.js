import { Controller } from "stimulus"
import PopperJs from 'popper.js'

export default class extends Controller {
  static targets = ["button", "content", "arrow"]

  connect() {
    this.popover = new PopperJs(this.buttonTarget, this.contentTarget, {
      placement: "bottom-end",
      modifiers: {
        arrow: {
          element: this.arrowTarget
        }
      }
    })

    let controller = this

    addEventListener("click", function (event) {
      let clickedElement = event.target

      if (controller.buttonTarget.contains(clickedElement)) {
        controller.toggle()
      } else {
        controller.hide()
      }
    })
  }

  toggle() {
    this.contentTarget.classList.toggle("hidden")
    this.popover.update()
  }

  hide() {
    this.contentTarget.classList.add("hidden")
  }
}
