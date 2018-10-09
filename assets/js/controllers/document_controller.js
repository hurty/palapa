import BaseController from "./base_controller"

export default class extends BaseController {
  static targets = ["tableOfContents", "newSectionButton", "newSectionForm", "newSectionInput"]

  showNewSectionForm(event) {
    event.preventDefault()
    this.show(this.newSectionFormTarget)
    this.hide(this.newSectionButtonTarget)
    this.newSectionInputTarget.focus()
  }

  hideNewSectionForm(event) {
    if (event)
      event.preventDefault()
    this.hide(this.newSectionFormTarget)
    this.show(this.newSectionButtonTarget)
  }

  createSection(event) {
    event.preventDefault()
    let url = event.target.getAttribute("action")
    let body = new FormData(this.newSectionFormTarget)

    PA.fetchHTML(url, { method: "post", body: body })
      .then((html) => {
        this.tableOfContentsTarget.innerHTML += html
        this.hideNewSectionForm()
        this.newSectionInputTarget.value = ""
      })
  }
}
