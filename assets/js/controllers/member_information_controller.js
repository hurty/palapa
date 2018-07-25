import { Controller } from "stimulus"
import Dropzone from "../vendor/dropzone"

export default class extends Controller {
  static targets = ["addInformationButton", "form", "list", "type", "customLabel", "value", "attachment"]

  connect() {
    this.displayFields()
    this.setAttachmentDropzone()
  }

  displayFields(event) {
    this.hideCustomLabel()
    this.hideAttachment()

    if (this.typeTarget.value === "custom") {
      this.showCustomLabel()
      this.showAttachment()
    }
  }

  setAttachmentDropzone() {
    this.dropzone = new Dropzone(this.attachmentTarget, {
      url: this.data.get("attachment-url"),
      headers: {
        "X-CSRF-Token": PA.getMetaValue("csrf-token")
      }
    });

    let self = this

    this.dropzone.on("success", function (file, response) {
      let attachmentIdElement = document.createElement("input")
      attachmentIdElement.setAttribute("type", "hidden")
      attachmentIdElement.setAttribute("name", "member_information[attachments][]")
      attachmentIdElement.setAttribute("value", response.attachment_sid)
      self.formTarget.appendChild(attachmentIdElement)
    });
  }

  create(event) {
    event.preventDefault()

    let url = this.formTarget.getAttribute("action")
    let list = this.listTarget

    PA.fetchHTML(url, {
      method: "post",
      body: new FormData(this.formTarget)
    })
      .then(html => {
        list.innerHTML = html
        this.clearForm()
      })
  }

  showForm(event) {
    this.formTarget.classList.remove("hidden")
    this.addInformationButtonTarget.classList.add("hidden")
  }

  hideForm(event) {
    if (event)
      event.preventDefault()
    this.formTarget.classList.add("hidden")
    this.addInformationButtonTarget.classList.remove("hidden")
  }

  clearForm() {
    this.formTarget.querySelectorAll(".input").forEach((node, index) => { node.value = null })
    this.dropzone.removeAllFiles()
  }

  showCustomLabel() {
    this.customLabelTarget.classList.remove("hidden")
  }

  hideCustomLabel() {
    this.customLabelTarget.classList.add("hidden")
  }

  showAttachment() {
    this.attachmentTarget.classList.remove("hidden")
  }

  hideAttachment() {
    this.attachmentTarget.classList.add("hidden")
  }
}
