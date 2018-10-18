import BaseController from "./base_controller"

export default class extends BaseController {
  static targets = ["iconOpened", "iconClosed", "pagesList"]

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

}
