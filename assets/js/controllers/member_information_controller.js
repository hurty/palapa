import BaseController from "./base_controller"

export default class extends BaseController {
  static targets = ["copyButton"]

  delete(event) {
    event.preventDefault()

    if (!PA.confirm(event.target)) {
      return;
    }

    PA.remoteLink(event.target).then(html => {
      this.element.remove()
    })
  }

  showCopyButton() {
    this.show(this.copyButtonTarget)
  }

  hideCopyButton() {
    this.hide(this.copyButtonTarget)
  }
}
