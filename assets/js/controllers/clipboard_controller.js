import BaseController from "./base_controller"
import PopperJs from 'popper.js'

export default class extends BaseController {
  static targets = ["textToCopy", "popperContent", "copyButton"]

  connect() {
    this.popover = new PopperJs(this.copyButtonTarget, this.popperContentTarget, {
      placement: "left"
    })
  }

  copy(e) {
    const selection = window.getSelection();
    const range = document.createRange();
    range.selectNodeContents(this.textToCopyTarget);
    selection.removeAllRanges();
    selection.addRange(range);

    document.querySelectorAll('.js-clipboard-popper-content').forEach(popperContent => {
      this.hide(popperContent)
    });

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
