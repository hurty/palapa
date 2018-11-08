import { Controller } from "stimulus"
import Popper from 'popper.js'

export default class extends Controller {
  static targets = ["button", "content"]

  toggle() {
    this.popover = new Popper(this.buttonTarget, this.contentTarget, {
      placement: "bottom"
    })
    this.contentTarget.classList.toggle("hidden")
  }

  hide(event) {
    if (event.target != this.buttonTarget && !this.contentTarget.contains(event.target)) {
      this.contentTarget.classList.add("hidden")
      this.popover = null
    }
  }
}
