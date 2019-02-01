import BaseController from "./base_controller"

export default class extends BaseController {
  static targets = ["editor", "form", "suggestionsList",
    "suggestionContent", "leaveSuggestionButton"]

  showForm(event) {
    this.show(this.formTarget)
    this.hide(this.leaveSuggestionButtonTarget)
    this.formTarget.querySelector("trix-editor").focus()
    this.formTarget.scrollIntoView({
      behavior: 'smooth'
    })
  }

  hideForm(event) {
    this.hide(this.formTarget)
    this.show(this.leaveSuggestionButtonTarget)
  }

  createSuggestion(event) {
    event.preventDefault();

    // Do not post suggestion if the editor has the defaut empty content
    if (this.suggestionContentTarget.value === "") {
      return
    }

    PA.fetchHTML(this.formTarget.getAttribute("action"), {
      method: "post",
      body: new FormData(this.formTarget)
    }).then(html => {
      this.suggestionsListTarget.innerHTML += html
      this.editorTarget.editor.loadHTML("")
      this.hideForm()
    })
  }
}
