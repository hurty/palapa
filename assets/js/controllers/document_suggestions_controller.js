import BaseController from "./base_controller"

export default class extends BaseController {
  static targets = ["listTab", "closedSuggestionsTab", "editor", "form",
    "suggestionsList", "suggestionContentInput", "leaveSuggestionButton"]

  initialize() {
    this.refreshList()
  }

  refreshList(filter) {
    let url = this.data.get("list-url")

    if (filter == "closed")
      url += "?status=closed"


    PA.fetchHTML(url)
      .then(html => {
        this.suggestionsListTarget.innerHTML = html
      })
  }

  toggleList(event) {
    if (event)
      event.preventDefault()

    this.listTabTargets.forEach(tab => {
      tab.classList.toggle("tab--selected")
    })

    if (this.selectedList == "open") {
      this.selectedList = "closed"
    } else {
      this.selectedList = "open"
    }

    this.refreshList(this.selectedList)
  }

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
    if (this.suggestionContentInputTarget.value === "") {
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

  get selectedList() {
    return this.data.get("selected-list")
  }

  set selectedList(value) {
    this.data.set("selected-list", value)
  }
}
