import BaseController from "./base_controller"
import PopperJs from 'popper.js'

export default class extends BaseController {
  static targets = ["form", "queryInput", "resultsContainer"]

  connect() {
    this.popover = new PopperJs(this.queryInputTarget, this.resultsContainerTarget, {
      placement: "bottom"
    })
  }

  runSearch() {
    if (this.queryInputTarget.value && this.queryInputTarget.value != "") {
      this.show(this.resultsContainerTarget)

      let updateUrl = this.formTarget.getAttribute("action") + "?query=" + this.queryInputTarget.value

      PA.fetchHTML(updateUrl, {
        method: "get"
      }).then(html => {
        this.resultsContainerTarget.innerHTML = html
        this.popover.update()
      })
    } else {
      this.hide(this.resultsContainerTarget)
    }
  }
}
