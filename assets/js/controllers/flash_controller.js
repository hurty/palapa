import BaseController from "./base_controller";

export default class extends BaseController {
  connect() {
    setTimeout(() => {
      this.element.remove();
    }, 6000);
  }
}
