import BaseController from "./base_controller";

export default class extends BaseController {
  static targets = [
    "listTab",
    "closedSuggestionsTab",
    "editor",
    "form",
    "suggestionsList",
    "newSuggestion",
    "suggestionContentInput",
    "leaveSuggestionButton"
  ];

  initialize() {
    this.refreshList();

    document.addEventListener("documentSuggestionDidReopen", event => {
      this.focusSuggestionId = event.detail.suggestionId;
      this.toggleList(event);
    });
  }

  refreshList(filter) {
    this.suggestionsListTarget.innerHTML = "";

    let url = this.data.get("list-url");

    if (filter == "closed") url += "?status=closed";

    PA.fetchHTML(url)
      .then(html => {
        this.suggestionsListTarget.innerHTML = html;
      })
      .then(() => {
        if (this.focusSuggestionId) {
          let suggestionElement = document.getElementById(
            this.focusSuggestionId
          );
          suggestionElement.scrollIntoView({ behavior: "smooth" });
          this.focusSuggestionId = null;
        }
      });
  }

  toggleList(event) {
    if (event) event.preventDefault();

    this.listTabTargets.forEach(tab => {
      tab.classList.toggle("tab--selected");
    });

    if (this.selectedList == "open") {
      this.selectedList = "closed";
      this.hide(this.newSuggestionTarget);
    } else {
      this.selectedList = "open";
      this.show(this.newSuggestionTarget);
    }

    this.refreshList(this.selectedList);
  }

  showForm(event) {
    this.show(this.formTarget);
    this.hide(this.leaveSuggestionButtonTarget);
    this.formTarget.querySelector("trix-editor").focus();
    this.formTarget.scrollIntoView({
      behavior: "smooth"
    });
  }

  hideForm(event) {
    this.hide(this.formTarget);
    this.show(this.leaveSuggestionButtonTarget);
  }

  createSuggestion(event) {
    event.preventDefault();

    // Do not post suggestion if the editor has the defaut empty content
    if (this.suggestionContentInputTarget.value === "") {
      return;
    }

    PA.fetchHTML(this.formTarget.getAttribute("action"), {
      method: "post",
      body: new FormData(this.formTarget)
    }).then(html => {
      this.suggestionsListTarget.innerHTML += html;
      this.editorTarget.editor.loadHTML("");
      this.hideForm();
    });
  }

  get selectedList() {
    return this.data.get("selected-list");
  }

  set selectedList(value) {
    this.data.set("selected-list", value);
  }

  set focusSuggestionId(id) {
    this.data.set("focus-suggestion-id", id);
  }

  get focusSuggestionId() {
    return this.data.get("focus-suggestion-id");
  }
}
