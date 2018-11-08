import { Controller } from "stimulus"

export default class extends Controller {

  // 
  // DOM Manipulations
  // 

  show(element) {
    element.classList.remove("hidden")
  }

  hide(element) {
    element.classList.add("hidden")
  }

  toggle(element) {
    element.classList.toggle("hidden")
  }

  focusWithCursorAtTheEnd(element) {
    let val = element.value
    element.value = ' '
    element.value = val
    element.focus()
  }
}
