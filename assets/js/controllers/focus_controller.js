import { Controller } from "stimulus"
import BaseController from "./base_controller"

export default class extends BaseController {

  connect() {
    this.focusWithCursorAtTheEnd(this.element)
  }
}
