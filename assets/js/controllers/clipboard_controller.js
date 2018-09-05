import { Controller } from "stimulus"
import PopperJs from 'popper.js'

export default class extends Controller {
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
      popperContent.classList.add("hidden")
    });

    try {
      document.execCommand('copy');
      selection.removeAllRanges();
      this.popperContentTarget.classList.remove("hidden")
      this.popover.update()
    } catch (e) {
      console.error("Clipboard copy failed")
    }
  }
}
