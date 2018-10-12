import BaseController from "./base_controller"
import Popper from 'popper.js'
import { LuminousGallery } from 'luminous-lightbox'

export default class extends BaseController {
  static targets = ["pagesList", "sectionsList", "newPageButton", "newPageForm", "newPageInput",
    "newSectionButton", "newSectionForm", "newSectionInput", "section"]

  connect() {
    this.handleImageGallery()
  }

  handleImageGallery() {
    new LuminousGallery(document.querySelectorAll("a[data-trix-content-type^='image']"))
  }

  showNewSectionForm(event) {
    if (event)
      event.preventDefault()

    this.hide(this.newPageFormTarget)
    this.show(this.newSectionFormTarget)
    let popper = new Popper(this.newSectionButtonTarget, this.newSectionFormTarget, {
      placement: "bottom-start"
    });
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
        this.sectionsListTarget.innerHTML += html
        this.hideNewSectionForm()
        this.newSectionInputTarget.value = ""
      })
  }

  showNewPageForm(event) {
    if (event)
      event.preventDefault()

    this.hide(this.newSectionFormTarget)
    this.show(this.newPageFormTarget)
    let popper = new Popper(this.newPageButtonTarget, this.newPageFormTarget, {
      placement: "bottom-start"
    });
    this.newPageInputTarget.focus()
  }

  hideNewPageForm(event) {
    if (event)
      event.preventDefault()
    this.hide(this.newPageFormTarget)
    this.show(this.newPageButtonTarget)
  }

  createPage(event) {
    event.preventDefault()
    let url = event.target.getAttribute("action")
    let body = new FormData(this.newPageFormTarget)

    PA.fetchHTML(url, { method: "post", body: body })
      .then((html) => {
        this.pagesListTarget.innerHTML += html
        this.hideNewPageForm()
        this.newPageInputTarget.value = ""
      })
  }

  toggleSection(event) {
    let clickedSectionId = "section_" + event.currentTarget.getAttribute("data-section-id")

    this.sectionTargets.forEach((section) => {
      let sectionId = section.getAttribute("id")
      section.classList.toggle("section-pages--closed", sectionId != clickedSectionId)
    })

    let icon = event.currentTarget.querySelector(".fa-caret-right")
    console.log(icon)
    icon.classList.remove("fa-caret-right")
    icon.classList.add("fa-caret-down")
  }
}
