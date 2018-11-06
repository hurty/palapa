import BaseController from "./base_controller"
import PopperJs from 'popper.js'

export default class extends BaseController {
  static targets = ["menu", "title", "iconOpened", "iconClosed", "pagesList", "form", "titleInput", "errorMessage"]

  connect() {
    this.handleDragPageOverSection()
  }

  handleDragPageOverSection() {
    document.addEventListener("dragOverSection", (event) => {
      if (event.detail.overContainer === this.pagesListTarget) {
        this.pagesListTarget.classList.add("bg-grey-lighter")
        // this.openSection()
      }
    })

    document.addEventListener("dragOutOfSection", (event) => {
      if (event.detail.overContainer === this.pagesListTarget) {
        this.pagesListTarget.classList.remove("bg-grey-lighter")
      }
    })

    document.addEventListener("dragStopEvent", (event) => {
      this.pagesListTarget.classList.remove("bg-grey-lighter")
    })
  }

  toggleSection(event) {
    if (this.isSectionOpen()) {
      this.closeSection()
    } else {
      this.openSection()
    }
  }

  isSectionOpen() {
    return this.pagesListTarget.classList.contains("document-section--open")
  }

  openSection() {
    this.pagesListTarget.classList.replace("document-section--closed", "document-section--open")
  }

  closeSection() {
    this.pagesListTarget.classList.replace("document-section--open", "document-section--closed")
  }

  showForm(event) {
    event.preventDefault()

    let popper = new PopperJs(this.menuTarget, this.formTarget, {
      placement: "bottom"
    })
    this.hide(this.errorMessageTarget)
    this.show(this.formTarget)
  }

  rename(event) {
    event.preventDefault()
    let newTitle = this.titleInputTarget.value

    if (newTitle === "") {
      this.show(this.errorMessageTarget)
      return
    }

    let formData = new FormData()
    formData.append("section[title]", newTitle)

    PA.fetchHTML(this.data.get("url"), { method: "put", body: formData }).then(() => {
      this.title = newTitle
      this.hide(this.formTarget)
    })
  }

  cancelRename(event) {
    event.preventDefault()
    this.hide(this.formTarget)
  }

  set title(value) {
    this.data.set("title", value)
    this.titleTarget.innerHTML = value
  }


}
