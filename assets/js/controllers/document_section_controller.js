import BaseController from "./base_controller"

export default class extends BaseController {
  static targets = ["iconOpened", "iconClosed", "pagesList"]

  toggleSection(event) {
    this.toggle(this.iconClosedTarget)
    this.toggle(this.iconOpenedTarget)
    this.toggle(this.pagesListTarget)
  }
}
