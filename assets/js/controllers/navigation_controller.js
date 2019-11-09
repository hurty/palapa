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
    this.toggle(this.switcherTarget);
  }
}
