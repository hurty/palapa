import BaseController from "./base_controller"

export default class extends BaseController {
  static targets = []

  delete(event) {
    event.preventDefault()

    if (!PA.confirm(event.target)) {
      return;
    }

    let url = event.target.getAttribute("href")

    PA.fetchHTML(url, {
      method: "delete",
    }).then(html => {
      this.element.remove()
    })
  }
}
