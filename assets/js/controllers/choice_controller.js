import { Controller } from "stimulus"
import Choices from "choices.js"

export default class extends Controller {
  static targets = ["select"]

  connect() {
    new Choices(this.element, {
      removeItemButton: true,
      placeholder: true,
      placeholderValue: this.element.getAttribute("placeholder")
    })
  }
}
