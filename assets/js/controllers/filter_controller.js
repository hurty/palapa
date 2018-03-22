import { Controller } from "stimulus"

export default class extends Controller {
  static targets = ["filters"]

  toggleFilters() {
    this.filtersTarget.classList.toggle("hidden");
  }
}
