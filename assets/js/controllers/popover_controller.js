import { Controller } from "stimulus"
import PopperJs from 'popper.js'

export default class extends Controller {
  static targets = ["button", "content"]

  connect() {
    this.popover = new PopperJs(this.buttonTarget, this.contentTarget, {
      placement: "bottom"
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
