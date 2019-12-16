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
    switch (this.hiddenTypeTarget.value) {
      case 'attachment':
        this.setAttachment()
        break;

      case 'link':
        this.setLink()
        break;

      default:
        this.setInternal()
    }
  }

  setInternal(e) {
    if (e) {
      e.preventDefault();
    }
    this.hiddenTypeTarget.value = "internal";

    this.linkButtonTarget.classList.remove("btn-switch--selected");
    this.attachmentButtonTarget.classList.remove("btn-switch--selected");
    this.internalButtonTarget.classList.add("btn-switch--selected");

    this.show(this.richTextInputTarget);
    this.hide(this.linkInputTarget);
  }

  setLink(e) {
    if (e) {
      e.preventDefault();
    }
    this.hiddenTypeTarget.value = "link";

    this.linkButtonTarget.classList.add("btn-switch--selected");
    this.attachmentButtonTarget.classList.remove("btn-switch--selected");
    this.internalButtonTarget.classList.remove("btn-switch--selected");

    this.hide(this.richTextInputTarget);
    this.show(this.linkInputTarget);
  }

  setAttachment(e) {
    if (e) {
      e.preventDefault();
    }
    this.hiddenTypeTarget.value = "attachment";

    this.linkButtonTarget.classList.remove("btn-switch--selected");
    this.attachmentButtonTarget.classList.add("btn-switch--selected");
    this.internalButtonTarget.classList.remove("btn-switch--selected");
  }
}
