import { Controller } from "stimulus"

export default class extends Controller {
  static targets = ["switcher"]

  showSwitcher(event) {
    event.preventDefault()

    this.switcherTarget.style.transition = 'opacity 0.3s';
    const { opacity } = this.switcherTarget.ownerDocument.defaultView.getComputedStyle(this.switcherTarget, null);
    if (opacity === '1') {
      this.switcherTarget.style.opacity = '0';
    } else {
      this.loadSwitcher()
      this.switcherTarget.style.opacity = '1';
    }
  }

  loadSwitcher() {
    fetch(this.data.get("url"), { credentials: 'same-origin' })
      .then(response => response.text())
      .then(html => {
        this.switcherTarget.innerHTML = html
      })
  }
}
