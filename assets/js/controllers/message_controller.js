import { Controller } from "stimulus"

export default class extends Controller {
  static targets = ["teamsList", "publishToEveryone", "publishToSpecificTeams", "commentForm", "commentsList",
    "commentsCount", "textEditor", "textEditorContent"]

  //
  // When posting a new message
  //

  connect() {
    if (this.haspublishToSpecificTeamsTarget) {
      if (this.publishToSpecificTeamsTarget.checked) {
        this.showTeamsList()
      }
    }
  }

  publishToEveryone() {
    this.hideTeamsList()
  }

  publishToSpecificTeams() {
    this.showTeamsList()
  }

  showTeamsList() {
    this.teamsListTarget.classList.remove("hidden");
  }

  hideTeamsList() {
    this.teamsListTarget.classList.add("hidden");
  }

  //
  // When viewing a message
  //

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

        this.commentsListTarget.appendChild(commentElement)
        this.commentsCountTarget.innerHTML = ""
        this.commentsCountTarget.appendChild(commentsCountElement)
        this.clearTextEditor()
      })
  }

  deleteComment(event) {
    event.preventDefault()
    let link = event.target
    let message = link.getAttribute("data-confirm")
    if (message && !window.confirm(message)) {
      return;
    }

    let deleteURL = event.target.getAttribute("href")

    fetch(deleteURL, {
      method: "delete",
      credentials: "same-origin",
      headers: {
        "x-csrf-token": event.target.getAttribute("data-csrf")
      }
    }).then(response => response.text())
      .then(html_response => {
        event.target.closest(".js-message-comment").remove()
        this.commentsCountTarget.innerHTML = html_response
      })
  }

  clearTextEditor() {
    this.textEditorController.clear()
  }

  get textEditorController() {
    return this.application.getControllerForElementAndIdentifier(this.textEditorTarget, "text_editor")
  }
}
