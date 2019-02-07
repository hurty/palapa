import BaseController from "./base_controller"

export default class extends BaseController {
  static targets = ["replyForm", "replies", "actions", "passiveFormItems",
    "activeFormItems", "replyEditor", "replyContentInput"]

  showReplyForm(event) {
    if (event)
      event.preventDefault()

    this.show(this.replyFormTarget)
    this.actionsTarget.classList.add("bg-grey-lightest")
    this.hide(this.passiveFormItemsTarget)
    this.show(this.activeFormItemsTarget)
    this.activeFormItemsTarget.querySelector("trix-editor").focus()
  }

  hideReplyForm(event) {
    if (event)
      event.preventDefault()

    this.actionsTarget.classList.remove("bg-grey-lightest")
    this.show(this.passiveFormItemsTarget)
    this.hide(this.activeFormItemsTarget)
  }

  sendReply(event) {
    event.preventDefault();

    if (this.replyContentInputTarget.value === "") {
      return
    }

    PA.fetchHTML(this.replyFormTarget.getAttribute("action"), {
      method: "post",
      body: new FormData(this.replyFormTarget)
    }).then(html => {
      this.repliesTarget.innerHTML += html
      this.replyEditorTarget.editor.loadHTML("")
      this.hideReplyForm()
    })
  }

  close(event) {
    event.preventDefault()
    let url = this.data.get("close-url")
    PA.fetchHTML(url, {
      method: "post",
    }).then(html => {
      this.element.remove()
    })
  }

  reopen(event) {
    event.preventDefault()
    let url = this.data.get("close-url")
    PA.fetchHTML(url, {
      method: "delete",
    }).then(html => {
      this.element.remove()
    })
  }
}
