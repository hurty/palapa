import { Controller } from "stimulus"

export default class extends Controller {
  static targets = ["commentForm", "commentsList", "commentsCount", "textEditor", "textEditorContent"]

  submitComment(event) {
    event.preventDefault();

    // Do not post comment if the editor has the defaut empty content
    if (this.textEditorContentTarget.value === "<p><br></p>") {
      return
    }

    fetch(this.commentFormTarget.getAttribute("action"), {
      method: "post",
      credentials: "same-origin",
      body: new FormData(this.commentFormTarget),
    }).then(response => response.text())
      .then(html_response => {
        let parser = new DOMParser();
        let doc = parser.parseFromString(html_response, "text/html");
        let commentElement = doc.getElementById("comment")
        let commentsCountElement = doc.getElementById("comments_count")

        this.addComment(commentElement)
        this.updateCommentsCount(commentsCountElement)
        this.clearTextEditor()
      })
  }

  addComment(commentElement) {
    this.commentsListTarget.appendChild(commentElement)
  }

  updateCommentsCount(commentsCountElement) {
    this.commentsCountTarget.innerHTML = ""
    this.commentsCountTarget.appendChild(commentsCountElement)
  }

  clearTextEditor() {
    this.textEditorController.clear()
  }

  get textEditorController() {
    return this.application.getControllerForElementAndIdentifier(this.textEditorTarget, "text_editor")
  }
}
