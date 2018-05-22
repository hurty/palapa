import { Controller } from "stimulus"

export default class extends Controller {
  static targets = ["timezone"]

  connect() {
    this.populateTimezoneField()
  }

  populateTimezoneField() {
    let timezone = Intl.DateTimeFormat().resolvedOptions().timeZone
    if (timezone) {
      this.timezoneTarget.value = timezone
    }
  }
}
