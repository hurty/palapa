import BaseController from "./base_controller";

export default class extends BaseController {
  static targets = [
    "hiddenType",
    "internalButton",
    "linkButton",
    "attachmentButton",
    "richTextInput",
    "linkInput"
  ];

  connect() {
    console.log("controller connected");
  }

  setInternal(e) {
    e.preventDefault();
    this.hiddenTypeTarget.value = "internal";

    this.linkButtonTarget.classList.remove("btn-switch--selected");
    this.attachmentButtonTarget.classList.remove("btn-switch--selected");
    this.internalButtonTarget.classList.add("btn-switch--selected");

    this.show(this.richTextInputTarget);
    this.hide(this.linkInputTarget);
  }

  setLink(e) {
    e.preventDefault();
    this.hiddenTypeTarget.value = "link";

    this.linkButtonTarget.classList.add("btn-switch--selected");
    this.attachmentButtonTarget.classList.remove("btn-switch--selected");
    this.internalButtonTarget.classList.remove("btn-switch--selected");

    this.hide(this.richTextInputTarget);
    this.show(this.linkInputTarget);
  }

  setAttachment(e) {
    e.preventDefault();
    this.hiddenTypeTarget.value = "attachment";

    this.linkButtonTarget.classList.remove("btn-switch--selected");
    this.attachmentButtonTarget.classList.add("btn-switch--selected");
    this.internalButtonTarget.classList.remove("btn-switch--selected");
  }
}
