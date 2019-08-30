import BaseController from "./base_controller"

export default class extends BaseController {
  static targets = ["content", "copyButton", "formContainer"]

  delete(event) {
    event.preventDefault()

    if (!PA.confirm(event.target)) {
      return;
    }

    PA.remoteLink(event.target, { method: "delete" }).then(html => {
      this.element.remove()
    })
  }

  edit(event) {
    event.preventDefault()
    PA.remoteLink(event.target).then(html => {
      this.formContainerTarget.innerHTML = html
      this.show(this.formContainerTarget)
      this.hide(this.contentTarget)
    })
  }

  update(event) {
    event.preventDefault()
    event.target.disabled = true

    let form = event.target.closest("form")
    let url = form.getAttribute("action")

    PA.fetchHTML(url, {
      method: "put",
      body: new FormData(form)
    }).then(html => {
      this.element.innerHTML = html
      event.target.disabled = false
    }).catch(error => {
      event.target.disabled = false
      if (error.response && error.response.status === 422) {
        error.response.text().then(html => {
          this.formContainerTarget.innerHTML = html
        })
      }
    })
  }

  showCopyButton() {
    if (this.targets.has("copyButton"))
      this.show(this.copyButtonTarget)
  }

  hideCopyButton() {
    if (this.targets.has("copyButton"))
      this.hide(this.copyButtonTarget)
  }

  hideUpdateForm(event) {
    event.preventDefault()
    this.hide(this.formContainerTarget)
    this.show(this.contentTarget)
  }
}
