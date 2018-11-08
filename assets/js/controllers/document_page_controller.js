import BaseController from "./base_controller"

export default class extends BaseController {
  static targets = ["actionsIcons"]

  showActionsIcons() {
    this.show(this.actionsIconsTarget)
  }

  hideActionsIcons() {
    this.hide(this.actionsIconsTarget)
  }
}
