import { Controller } from "stimulus"
import Choices from "choices.js"

export default class extends Controller {
  static targets = ["select"]

  connect() {
    new Choices(this.selectTarget, {
      removeItemButton: true
    })
  }
}
