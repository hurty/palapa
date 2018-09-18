import BaseController from "./base_controller"
import Dropzone from "dropzone"

export default class extends BaseController {
  static targets = ["addInformationButton", "formContent", "type", "customLabel", "value", "attachment",
    "visibilities", "privateCheckbox", "attachmentHiddenInput"]

  connect() {
    Dropzone.autoDiscover = false
    this.displayFields()
  }

  showForm(event) {
    if (event)
      event.preventDefault()
    this.show(this.formContentTarget)
    this.hide(this.addInformationButtonTarget)
  }

  hideForm(event) {
    if (event)
      event.preventDefault()
    this.hide(this.formContentTarget)
    this.show(this.addInformationButtonTarget)
  }

  displayFields() {
    this.setCustomValuePlaceholder()

    if (this.privateCheckboxTarget.checked)
      this.show(this.visibilitiesTarget)

    if (this.typeTarget.value === "custom") {
      this.setAttachmentDropzone()
      this.show(this.customLabelTarget)
      this.show(this.attachmentTarget)

    } else {
      this.removeAllFiles()
      this.hide(this.customLabelTarget)
      this.hide(this.attachmentTarget)
    }
  }

  setAttachmentDropzone() {
    if (typeof this.dropzone !== "undefined")
      return

    this.dropzone = new Dropzone(this.attachmentTarget, {
      url: this.data.get("attachment-url"),
      headers: {
        "X-CSRF-Token": PA.getMetaValue("csrf-token")
      },
      addRemoveLinks: true
    });

    let hiddenAttachments = this.attachmentHiddenInputTargets

    hiddenAttachments.forEach((attachment) => {
      let file = {
        sid: attachment.value,
        name: attachment.getAttribute("data-filename"),
        thumb_url: attachment.getAttribute("data-thumb-url"),
        delete_url: attachment.getAttribute("data-delete-url"),
        size: attachment.getAttribute("data-size"),
        is_image: attachment.getAttribute("data-is-image")
      }

      this.dropzone.emit("addedfile", file)

      if (file.is_image === "true")
        this.dropzone.emit("thumbnail", file, file.thumb_url)

      this.dropzone.emit("complete", file)
    })

    this.dropzone.on("success", (file, response) => {
      file.delete_url = response.delete_url
      this.addAttachmentToForm(response)
    })

    this.dropzone.on("removedfile", (file) => {
      let url = file.delete_url

      if (url) {
        PA.fetchHTML(url, { method: "delete" })
      }
    })
  }

  addAttachmentToForm(attachment) {
    let attachmentIdElement = document.createElement("input")
    attachmentIdElement.setAttribute("type", "hidden")
    attachmentIdElement.setAttribute("name", "member_information[attachments][]")
    attachmentIdElement.setAttribute("value", attachment.attachment_sid)
    this.element.appendChild(attachmentIdElement)
  }

  clearForm() {
    this.element.querySelectorAll(".input").forEach((node, index) => { node.value = null })
    this.element.querySelectorAll(".error").forEach((node, index) => { node.remove() })

    if (typeof this.dropzone !== "undefined")
      this.dropzone.removeAllFiles()
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
        this.hideForm()
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
