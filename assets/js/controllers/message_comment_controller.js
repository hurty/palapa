import { Controller } from "stimulus"

export default class extends Controller {
  static targets = ["formContainer", "commentForm", "content", "hiddenInput"]

  editComment(event) {
    event.preventDefault()
    let link = event.target.closest("a")

    PA.remoteLink(link).then(html => {
      this.formContainerTarget.innerHTML = html
      this.showEditForm()
    })
  }

  updateComment(event) {
    event.preventDefault()

    // Do not post comment if the editor has the defaut empty content
    if (this.hiddenInputTarget.value === "") {
      return
    }

    let updateUrl = this.commentFormTarget.getAttribute("action")

    PA.fetchHTML(updateUrl, {
      method: "post",
      body: new FormData(this.commentFormTarget)
    })
      .then(html => {
        this.contentTarget.innerHTML = html
        this.hideEditForm()
      })
  }

  deleteComment(event) {
    event.preventDefault()
    let link = event.target.closest("a")

    if (!PA.confirm(link)) {
      return;
    }

    PA.remoteLink(link, { method: "delete" })
      .then(html => {
        this.element.remove()
        document.getElementById("message-comments-count").innerHTML = html
      })
  }

  showEditForm() {
    this.formContainerTarget.classList.remove("hidden")
    this.contentTarget.classList.add("hidden")
  }

  hideEditForm() {
    this.formContainerTarget.classList.add("hidden")
    this.contentTarget.classList.remove("hidden")
  }
}
