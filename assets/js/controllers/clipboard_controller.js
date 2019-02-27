import BaseController from "./base_controller"
import PopperJs from 'popper.js'

export default class extends BaseController {
  static targets = ["textToCopy", "popperContent", "copyButton"]

  connect() {
    this.popover = new PopperJs(this.copyButtonTarget, this.popperContentTarget, {
      placement: "bottom"
    })
  }

  copy(event) {
    event.preventDefault()
    const selection = window.getSelection();
    const range = document.createRange();
    range.selectNodeContents(this.textToCopyTarget);
    selection.removeAllRanges();
    selection.addRange(range);

    try {
      document.execCommand('copy');
      selection.removeAllRanges();
      this.show(this.popperContentTarget)
      this.popover.update()
    } catch (e) {
      console.error("Clipboard copy failed")
    }
  }

  copyInputValue(event) {
    event.preventDefault()
    this.textToCopyTarget.select()
    this.textToCopyTarget.selectionStart = 0
    this.textToCopyTarget.selectionEnd = this.textToCopyTarget.value.length

    try {
      document.execCommand('copy');
      selection.removeAllRanges();
      this.show(this.popperContentTarget)
      this.popover.update()
    } catch (e) {
      console.error("Clipboard copy failed")
    }
  }
}
