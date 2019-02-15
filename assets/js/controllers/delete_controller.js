import { Controller } from "stimulus"
import BaseController from "./base_controller"

export default class extends BaseController {
  delete(event) {
    event.preventDefault()

    let confirmMessage = this.element.getAttribute("data-confirm");
    if (confirmMessage && !window.confirm(confirmMessage))
      return

    let form = document.createElement("form")

    form.method = "post"
    form.action = this.element.getAttribute("href");
    form.style.display = "hidden";

    let method = this.buildHiddenInput("_method", "delete")
    let csrf = this.buildHiddenInput("_csrf_token", PA.getMetaValue("csrf-token"))

    form.appendChild(csrf);
    form.appendChild(method);
    document.body.appendChild(form);
    form.submit();
  }

  buildHiddenInput(name, value) {
    var input = document.createElement("input");
    input.type = "hidden";
    input.name = name;
    input.value = value;
    return input;
  }
}
