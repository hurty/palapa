import BaseController from "./base_controller"
import Popper from 'popper.js'
import { Application } from "stimulus";

export default class extends BaseController {
  static targets = ["actionsIcons", "menuButton", "menuContent", "title", "iconOpened", "iconClosed",
    "pagesList", "form", "titleInput", "errorMessage"]

  connect() {
    this.handleDragPageOverSection()
  }

  showActionsIcons() {
    this.show(this.actionsIconsTarget)
  }

  hideActionsIcons() {
    this.hide(this.actionsIconsTarget)
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

  toggleMenu(event) {
    this.menuPopover = new Popper(this.menuButtonTarget, this.menuContentTarget, {
      placement: "bottom"
    })
    this.menuContentTarget.classList.toggle("hidden")

  }

  hideMenu(event) {
    if (event == null || (event.target != this.menuButtonTarget && !this.menuContentTarget.contains(event.target))) {
      this.menuContentTarget.classList.add("hidden")
      this.menuPopover = null
    }
  }


  showRenameForm(event) {
    if (event)
      event.preventDefault()

    this.hideMenu()
    let popper = new Popper(this.menuButtonTarget, this.formTarget, {
      placement: "bottom"
    })

    this.hide(this.errorMessageTarget)
    this.show(this.formTarget)
    this.focusWithCursorAtTheEnd(this.titleInputTarget)
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

  delete(event) {
    event.preventDefault()
    let url = event.target.getAttribute("href")
    
    if (!PA.confirm(event.target)) {
      return;
    }

    PA.fetchHTML(url, {
      method: "delete",
    }).then(() => {
      if (this.currentSectionId == this.id) {
        window.location = this.documentUrl
      } else {
        this.element.remove()
      }
    })
  }

  get id() {
    return this.data.get("id")
  }

  get documentController() {
    let documentElement = document.getElementById("document")
    return this.application.getControllerForElementAndIdentifier(documentElement, "document")
  }

  get currentSectionId() {
    return this.documentController.currentSectionId
  }

  get documentUrl() {
    return this.documentController.documentUrl
  }

  set title(value) {
    this.data.set("title", value)
    this.titleTarget.innerHTML = value
  }
}
