import BaseController from "./base_controller"

export default class extends BaseController {
  static targets = ["content", "editForm", "editFormContainer"]

  edit(event) {
    event.preventDefault()

    let url = event.target.getAttribute("href")

    PA.fetchHTML(url).then(html => {
      this.editFormContainerTarget.innerHTML = html
      this.hide(this.contentTarget)
      this.show(this.editFormContainerTarget)
    })
  }

  cancelEdit(event) {
    this.show(this.contentTarget)
    this.hide(this.editFormContainerTarget)
  }

  update(event) {
    event.preventDefault()
    let updateUrl = this.editFormTarget.getAttribute("action")

    PA.fetchHTML(updateUrl, {
      method: "post",
      body: new FormData(this.editFormTarget)
    })
      .then(html => {
        this.element.outerHTML = html
      })
  }

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
