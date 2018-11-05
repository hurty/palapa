import BaseController from "./base_controller"
import Popper from 'popper.js'
import { LuminousGallery } from 'luminous-lightbox'
import { Sortable } from '@shopify/draggable';
import SwapAnimation from '@shopify/draggable/lib/plugins/swap-animation';
import debounce from 'lodash.debounce'

export default class extends BaseController {
  static targets = ["pagesList", "sectionsList", "sectionsContainer", "newPageButton", "newPageForm", "newPageInput",
    "newSectionButton", "newSectionForm", "newSectionInput", "draggableContainer"]

  connect() {
    this.handleImageGallery()
    this.handlePageSorting()
    this.handleSectionSorting()
  }

  handleImageGallery() {
    new LuminousGallery(document.querySelectorAll("a[data-trix-content-type^='image']"))
  }

  handlePageSorting() {
    const sortable = new Sortable(this.draggableContainerTargets,
      {
        draggable: ".draggable-source",
        handle: ".draggable-handle",
        swapAnimation: {
          duration: 250,
          easingFunction: 'ease-in-out',
        },
        mirror: {
          constrainDimensions: true,
          xAxis: false
        },
        plugins: [SwapAnimation]
      }
    )

    sortable.on('sortable:sorted', debounce(this.syncSortPage, 800))

    sortable.on('drag:over:container', (event) => {
      let dragOverSectionEvent = new CustomEvent("dragOverSection", { 'detail': event })
      document.dispatchEvent(dragOverSectionEvent)
    })

    sortable.on('drag:out:container', (event) => {
      let dragOutOfSectionEvent = new CustomEvent("dragOutOfSection", { 'detail': event })
      document.dispatchEvent(dragOutOfSectionEvent)
    })

    sortable.on('drag:stop', (event) => {
      let dragStopEvent = new CustomEvent("dragStopEvent", { 'detail': event })
      document.dispatchEvent(dragStopEvent)
    })
  }

  handleSectionSorting() {
    const sortable = new Sortable(this.sectionsContainerTarget,
      {
        draggable: ".document-section",
        handle: ".document-section-handle",
        swapAnimation: {
          duration: 250,
          easingFunction: 'ease-in-out',
        },
        mirror: {
          constrainDimensions: true,
          xAxis: false
        },
        plugins: [SwapAnimation]
      }
    )

    sortable.on('sortable:sorted',
      debounce(this.syncSortSection, 800)
    )
  }

  syncSortSection(event) {
    let section = event.dragEvent.source
    let updateSectionURL = section.getAttribute("data-document-section-url")

    let formData = new FormData();
    formData.append("section[position]", event.newIndex)

    PA.fetchHTML(updateSectionURL, {
      method: "put",
      body: formData
    })
  }

  syncSortPage(event) {
    let page = event.dragEvent.source
    let updatePageURL = page.getAttribute("data-document-page-url")
    let newSectionId = event.newContainer.getAttribute("data-document-section-id")

    let formData = new FormData();
    formData.append("new_section_id", newSectionId)
    formData.append("new_position", event.newIndex)

    PA.fetchHTML(updatePageURL, {
      method: "put",
      body: formData
    })
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
        this.sectionsContainerTarget.innerHTML += html
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

  clickPage(event) {
    event.currentTarget.querySelector("a").click()
  }
}
