import { Controller } from "stimulus";

export default class extends Controller {
  //
  // DOM Manipulations
  //

  show(element) {
    element.classList.remove("hidden");
  }

  hide(element) {
    element.classList.add("hidden");
  }

  toggle(element) {
    element.classList.toggle("hidden");
  }

  focusWithCursorAtTheEnd(element) {
    let val = element.value;
    element.value = " ";
    element.value = val;
    element.focus();
  }

  addHiddenFieldToForm(form, fieldName, fieldValue) {
    const hiddenField = document.createElement("input");
    hiddenField.type = "hidden";
    hiddenField.name = fieldName;
    hiddenField.value = fieldValue;
    form.appendChild(hiddenField);
  }

  animate(node, animationName, callback) {
    node.classList.add("animated", animationName);

    function handleAnimationEnd() {
      node.classList.remove("animated", animationName);
      node.removeEventListener("animationend", handleAnimationEnd);

      if (typeof callback === "function") callback();
    }

    node.addEventListener("animationend", handleAnimationEnd);
  }
}
