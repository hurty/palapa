import { Controller } from "stimulus"
import { default as autosize } from "autosize"

export default class extends Controller {
  connect() {
    autosize(this.element)

    // Disable the Enter key to prevent line breaks
    this.element.addEventListener("keydown", (e) => {
      if (e.keyCode == '13')
        e.preventDefault()
    })
  }
}
