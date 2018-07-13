import { Controller } from "stimulus"

export default class extends Controller {
  connect() {
    this.populateTimezoneField()
  }

  populateTimezoneField() {
    let timezone = Intl.DateTimeFormat().resolvedOptions().timeZone
    if (timezone) {
      this.element.value = timezone
    }
  }
}
