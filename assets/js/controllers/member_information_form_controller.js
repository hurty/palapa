import BaseController from "./base_controller"
import Dropzone from "../vendor/dropzone"

export default class extends BaseController {
  static targets = ["type", "customLabel", "value", "attachment", "visibilities", "privateCheckbox"]

  connect() {
    this.displayFields()
  }

  displayFields() {
    this.setCustomValuePlaceholder()

    if (this.privateCheckboxTarget.checked)
      this.show(this.visibilitiesTarget)

    if (this.typeTarget.value === "custom") {
      this.show(this.customLabelTarget)
      this.setAttachmentDropzone()
      this.show(this.attachmentTarget)

    } else {
      this.removeAllFiles()
      this.hide(this.customLabelTarget)
      this.hide(this.attachmentTarget)
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

  clearForm() {
    this.element.querySelectorAll(".input").forEach((node, index) => { node.value = null })
    this.element.querySelectorAll(".error").forEach((node, index) => { node.remove() })
    this.removeAllFiles()
  }

  removeAllFiles() {
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

  create(event) {
    event.preventDefault()

    event.target.disabled = true

    let url = this.element.getAttribute("action")
    let list = document.getElementById("member-informations-list")

    PA.fetchHTML(url, {
      method: "post",
      body: new FormData(this.element)
    })
      .then(html => {
        list.innerHTML = html
        this.clearForm()
        event.target.disabled = false
      })
      .catch(error => {
        event.target.disabled = false
        if (error.response && error.response.status === 422) {
          error.response.text().then(html => {
            this.element.innerHTML = html
            this.displayFields()
          })
        }
      })
  }
}
