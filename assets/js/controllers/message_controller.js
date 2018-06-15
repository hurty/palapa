import { Controller } from "stimulus"

export default class extends Controller {
  static targets = ["teamsList", "publishToEveryone", "publishToSpecificTeams", "commentForm", "commentsList",
    "commentsCount", "commentContent", "editor", "leaveComment"]
  connect() {
    this.handleTeamListVisibility()
  }

  handleTeamListVisibility() {
    if (this.hasPublishToSpecificTeamsTarget) {
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
    this.teamsListTarget.scrollIntoView({
      behavior: 'smooth'
    })
  }

  showTeamsList() {
    this.teamsListTarget.classList.remove("hidden")
  }

  hideTeamsList() {
    this.teamsListTarget.classList.add("hidden")
  }

  showCommentForm(event) {
    this.commentFormTarget.classList.remove("hidden")
    this.leaveCommentTarget.classList.add("hidden")
  }

  hideCommentForm(event) {
    this.commentFormTarget.classList.add("hidden")
    this.leaveCommentTarget.classList.remove("hidden")
  }

  submitComment(event) {
    event.preventDefault();

    // Do not post comment if the editor has the defaut empty content
    if (this.commentContentTarget.value === "") {
      return
    }

    PA.fetchHTML(this.commentFormTarget.getAttribute("action"), {
      method: "post",
      body: new FormData(this.commentFormTarget)
    })
      .then(html => {
        let parser = new DOMParser();
        let doc = parser.parseFromString(html, "text/html");
        let commentElement = doc.getElementById("comment")
        let commentsCountElement = doc.getElementById("comments_count")

        this.commentsListTarget.appendChild(commentElement)
        this.commentsCountTarget.innerHTML = ""
        this.commentsCountTarget.appendChild(commentsCountElement)
        this.editorTarget.editor.loadHTML("")
        this.hideCommentForm()
      })
  }

  deleteComment(event) {
    event.preventDefault()
    let link = event.target

    if (!PA.confirm(link)) {
      return;
    }

    PA.remoteLink(link, { method: "delete" })
      .then(html => {
        link.closest(".js-message-comment").remove()
        this.commentsCountTarget.innerHTML = html
      })
  }
}
