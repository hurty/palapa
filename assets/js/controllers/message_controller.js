import { Controller } from "stimulus"
import { LuminousGallery } from 'luminous-lightbox'

export default class extends Controller {
  static targets = ["editor", "commentForm", "commentsList", "commentsCount", "commentContent", "leaveComment"]

  connect() {
    if (this.data.get("page") == "show")
      this.handleImageGallery()
  }

  handleImageGallery() {
    new LuminousGallery(document.querySelectorAll("a[data-trix-content-type^='image']"))
  }

  showCommentForm(event) {
    this.commentFormTarget.classList.remove("hidden")
    this.leaveCommentTarget.classList.add("hidden")
    this.commentFormTarget.querySelector("trix-editor").focus()
    this.commentFormTarget.scrollIntoView({
      behavior: 'smooth'
    })
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
}
