import BaseController from "./base_controller"

export default class extends BaseController {
  static targets = ["iconOpened", "iconClosed", "pagesList"]

  connect() {
    console.log(this.iconClosedTarget)
    console.log(this.iconOpenedTarget)
    console.log(this.pagesListTarget)
  }

  toggleSection(event) {
    // let clickedSectionId = "section_" + event.currentTarget.getAttribute("data-section-title-id")

    // this.sectionContentTargets.forEach((sectionContent) => {
    //   let sectionId = sectionContent.getAttribute("id")
    //   sectionContent.classList.toggle("section-pages--closed", sectionId != clickedSectionId)
    // })

    // this.sectionIconTargets.forEach(sectionIcon => {
    //   sectionIcon.classList.remove("fa-caret-down")
    //   sectionIcon.classList.add("fa-caret-right")
    // })


    this.toggle(this.iconClosedTarget)
    this.toggle(this.iconOpenedTarget)
    this.toggle(this.pagesListTarget)
  }
}
