import { Controller } from "stimulus"
import BaseController from "./base_controller"

export default class extends BaseController {
  delete(event) {
    event.preventDefault()

    if (this.confirmMessage && !window.confirm(this.confirmMessage))
      return

    let form = this.buildForm()
    let method = this.buildHiddenInput("_method", "delete")

    form.appendChild(method);
    document.body.appendChild(form);
    form.submit();
  }

  post(event) {
    event.preventDefault()

    if (this.confirmMessage && !window.confirm(this.confirmMessage))
      return

    let form = this.buildForm()
    document.body.appendChild(form)
    form.submit();
  }

  buildForm() {
    let form = document.createElement("form")
    form.method = "post"
    form.action = this.element.getAttribute("href");
    form.style.display = "hidden";

    let csrf = this.buildHiddenInput("_csrf_token", PA.getMetaValue("csrf-token"))
    form.appendChild(csrf);

    return form
  }

  buildHiddenInput(name, value) {
    var input = document.createElement("input");
    input.type = "hidden";
    input.name = name;
    input.value = value;
    return input;
  }

  get confirmMessage() {
    return this.element.getAttribute("data-confirm");
  }
}
