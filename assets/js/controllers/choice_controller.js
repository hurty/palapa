import { Controller } from "stimulus";
import Choices from "choices.js";

export default class extends Controller {
  initialize() {
    new Choices(this.element, {
      removeItemButton: true,
      placeholder: true,
      duplicateItemsAllowed: false
    });
  }
}
