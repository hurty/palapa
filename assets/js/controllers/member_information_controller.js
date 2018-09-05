import BaseController from "./base_controller"
import Dropzone from "../vendor/dropzone"

export default class extends BaseController {
  static targets = ["addInformationButton", "form", "list", "type", "customLabel", "value",
    "attachment", "visibilities", "privateCheckbox"]

  connect() {
    if (this.targets.has("form")) {
      this.displayFields()
    }
  }

  displayFields() {
    this.setCustomValuePlaceholder()

    if (this.privateCheckboxTarget.checked)
      this.show(this.visibilitiesTarget)

    if (this.typeTarget.value === "custom") {
      this.show(this.customLabelTarget)
      this.show(this.attachmentTarget)
      this.setAttachmentDropzone()
      this.show(this.attachmentTarget)
    }
  }

  setAttachmentDropzone() {
    if (this.dropzone != undefined) {
      return
    }

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
      .catch(error => {
        if (error.response.status === 422) {
          error.response.text().then(html => {
            this.formTarget.innerHTML = html
            this.displayFields()
          })
        }
      })
  }

  showForm(event) {
    this.show(this.formTarget)
    this.hide(this.addInformationButtonTarget)
  }

  hideForm(event) {
    if (event)
      event.preventDefault()
    this.hide(this.formTarget)
    this.show(this.addInformationButtonTarget)
  }

  clearForm() {
    this.formTarget.querySelectorAll(".input").forEach((node, index) => { node.value = null })
    this.formTarget.querySelectorAll(".error").forEach((node, index) => { node.remove() })

    if (this.dropzone)
      this.dropzone.removeAllFiles()
  }

  setCustomValuePlaceholder() {
    let infoTypes = JSON.parse(this.data.get("types"))
    let placeholder = infoTypes[this.typeTarget.value]["placeholder"]
    this.valueTarget.setAttribute("placeholder", placeholder)
  }

  toggleVisibilities() {
    this.toggle(this.visibilitiesTarget)
  }
}
