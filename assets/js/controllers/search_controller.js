import BaseController from "./base_controller"
import PopperJs from 'popper.js'
import debounce from 'lodash.debounce'

export default class extends BaseController {
  static targets = ["form", "queryInput", "searchDialog", "resultsContainer", "result", "searchingIndicator"]

  initialize() {
    this.popover = new PopperJs(this.queryInputTarget, this.searchDialogTarget, {
      placement: "bottom"
    })

    this.index = 0
    this.triggerSearch = debounce(this.runSearch, 300)
  }

  activateSearchDialog() {
    this.index = 0
    this.selectResult()
    this.show(this.searchDialogTarget)
    this.popover.update()
    this.searchIsActive = true
  }

  deactivateSearchDialog() {
    this.hide(this.searchDialogTarget)
    this.show(this.searchingIndicatorTarget)
    this.hide(this.resultsContainerTarget)
    this.searchIsActive = false
  }

  updateResults(htmlResults) {
    this.resultsContainerTarget.innerHTML = htmlResults
    this.hide(this.searchingIndicatorTarget)
    this.show(this.resultsContainerTarget)
    this.index = 0
    this.selectResult()
    this.popover.update()
  }

  escapeSearchDialog(event) {
    if (event.target && !this.element.contains(event.target)) {
      event.preventDefault()
      this.hide(this.searchDialogTarget)
    }
  }

  triggerKeyNavigation(event) {
    // Up key
    if (event.keyCode == '38') {
      event.preventDefault()
      this.searchDialogTarget.focus()
      this.selectPreviousResult()
    }

    // Down key
    else if (event.keyCode == '40') {
      event.preventDefault()
      this.searchDialogTarget.focus()
      this.selectNextResult()
    }

    // Escape
    else if (event.keyCode == '27') {
      event.preventDefault()
      this.hide(this.searchDialogTarget)
    }

    // Tab key
    else if (event.keyCode == '9') {
      event.preventDefault()
      this.searchDialogTarget.focus()
      this.selectNextResult()
    }

    // Enter key
    else if (event.keyCode == '13') {
      event.preventDefault()
      let linkElement = this.resultTargets[this.index].querySelector('a');
      window.location = linkElement.getAttribute("href")
    } else {
      this.activateSearchDialog()
    }
  }

  runSearch() {
    if (this.queryInputTarget.value != "") {
      let updateUrl = this.formTarget.getAttribute("action") + "?query=" + this.queryInputTarget.value

      PA.fetchHTML(updateUrl, {
        method: "get"
      }).then(htmlResults => {
        this.updateResults(htmlResults)
      })
    } else {
      this.deactivateSearchDialog()
    }
  }

  selectPreviousResult() {
    if (this.index === 0) {
      this.index = this.resultTargets.length - 1
    } else {
      this.index--
    }
  }

  selectNextResult() {
    if (this.index === this.resultTargets.length - 1) {
      this.index = 0
    } else {
      this.index = this.index + 1
    }
  }

  selectResult() {
    this.resultTargets.forEach((result, i) => {
      result.classList.toggle("bg-green-lightest", this.index == i)
    })
  }

  get searchIsActive() {
    return this.data.get("active") === "true"
  }

  set searchIsActive(value) {
    this.data.set("active", value)
  }

  get index() {
    return parseInt(this.data.get("index"))
  }

  set index(value) {
    this.data.set("index", value)
    this.selectResult()
  }
}
