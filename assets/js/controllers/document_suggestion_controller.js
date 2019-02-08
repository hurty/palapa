import BaseController from "./base_controller"

export default class extends BaseController {
  static targets = ["commentForm", "comments", "actions", "passiveFormItems",
    "activeFormItems", "commentEditor", "commentContentInput", "content", "editForm", "editFormContainer"]

  showCommentForm(event) {
    if (event)
      event.preventDefault()

    this.show(this.commentFormTarget)
    this.actionsTarget.classList.add("bg-grey-lightest")
    this.hide(this.passiveFormItemsTarget)
    this.show(this.activeFormItemsTarget)
    this.activeFormItemsTarget.querySelector("trix-editor").focus()
  }

  hideCommentForm(event) {
    if (event)
      event.preventDefault()

    this.actionsTarget.classList.remove("bg-grey-lightest")
    this.show(this.passiveFormItemsTarget)
    this.hide(this.activeFormItemsTarget)
  }

  postComment(event) {
    event.preventDefault();

    if (this.commentContentInputTarget.value === "") {
      return
    }

    PA.fetchHTML(this.commentFormTarget.getAttribute("action"), {
      method: "post",
      body: new FormData(this.commentFormTarget)
    }).then(html => {
      this.commentsTarget.innerHTML += html
      this.commentEditorTarget.editor.loadHTML("")
      this.hideCommentForm()
    })
  }

  close(event) {
    event.preventDefault()
    let url = this.data.get("close-url")
    PA.fetchHTML(url, {
      method: "post",
    }).then(html => {
      this.remove()
    })
  }

  reopen(event) {
    event.preventDefault()
    let url = this.data.get("close-url")
    PA.fetchHTML(url, {
      method: "delete",
    }).then(html => {
      let reopenEvent = new CustomEvent('documentSuggestionDidReopen',
        {
          detail:
          {
            suggestionId: this.element.getAttribute("id")
          }
        })
      document.dispatchEvent(reopenEvent)
      this.hide(this.element)
    })
  }

  edit(event) {
    event.preventDefault()

    let url = event.target.getAttribute("href")

    PA.fetchHTML(url).then(html => {
      this.editFormContainerTarget.innerHTML = html
      this.hide(this.contentTarget)
      this.show(this.editFormContainerTarget)
      this.editFormContainerTarget.querySelector("trix-editor").focus()
    })
  }

  cancelEdit(event) {
    event.preventDefault()
    this.show(this.contentTarget)
    this.hide(this.editFormContainerTarget)
  }

  update(event) {
    event.preventDefault()
    let updateUrl = this.editFormTarget.getAttribute("action")

    PA.fetchHTML(updateUrl, {
      method: "post",
      body: new FormData(this.editFormTarget)
    }).then(html => {
      this.contentTarget.innerHTML = html
      this.show(this.contentTarget)
      this.hide(this.editFormContainerTarget)
    })
  }

  delete(event) {
    event.preventDefault()
  }

  remove() {
    this.element.remove()
  }
}
