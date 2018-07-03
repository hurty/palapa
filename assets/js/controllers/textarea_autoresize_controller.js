import { Controller } from "stimulus"
import { default as autosize } from "autosize"

export default class extends Controller {
  connect() {
    let textarea = this.element
    autosize(textarea)

    // Disable the Enter key to prevent line breaks
    textarea.addEventListener("keydown", (e) => {
      if (e.keyCode == '13') {
        e.preventDefault()
      } else {
        autosize(textarea)
      }
    })
  }
}
