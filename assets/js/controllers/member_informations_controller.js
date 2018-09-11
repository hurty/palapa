import BaseController from "./base_controller"

export default class extends BaseController {
  static targets = ["addInformationButton", "form", "list"]

  showForm(event) {
    event.preventDefault()
    this.show(this.formTarget)
    this.hide(this.addInformationButtonTarget)
  }

  hideForm(event) {
    event.preventDefault()
    this.hide(this.formTarget)
    this.show(this.addInformationButtonTarget)
  }
}
