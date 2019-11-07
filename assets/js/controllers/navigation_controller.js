import { Controller } from "stimulus";
import BaseController from "./base_controller";

export default class extends BaseController {
  static targets = ["switcher"];

  toggleMobileMenu(event) {
    event.preventDefault();
    document.body.classList.toggle("layout");
    document.body.classList.toggle("menu-layout");
  }

  showSwitcher(event) {
    event.preventDefault();

    this.switcherTarget.style.transition = "opacity 0.3s";
    const {
      opacity
    } = this.switcherTarget.ownerDocument.defaultView.getComputedStyle(
      this.switcherTarget,
      null
    );
    if (opacity === "1") {
      this.switcherTarget.style.opacity = "0";
    } else {
      this.switcherTarget.style.opacity = "1";
    }
  }
}
