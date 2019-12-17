import BaseController from "./base_controller";

export default class extends BaseController {
  static targets = [
    "hiddenType",
    "internalButton",
    "linkButton",
    "attachmentButton",
    "titleInput",
    "richTextInput",
    "attachmentInput",
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

    this.linkButtonTarget.classList.remove("tab--active");
    this.attachmentButtonTarget.classList.remove("tab--active");
    this.internalButtonTarget.classList.add("tab--active");

    this.show(this.richTextInputTarget);
    this.hide(this.attachmentInputTarget);
    this.hide(this.linkInputTarget);

    this.focusWithCursorAtTheEnd(this.titleInputTarget)
  }

  setLink(e) {
    if (e) {
      e.preventDefault();
    }
    this.hiddenTypeTarget.value = "link";

    this.linkButtonTarget.classList.add("tab--active");
    this.attachmentButtonTarget.classList.remove("tab--active");
    this.internalButtonTarget.classList.remove("tab--active");

    this.hide(this.richTextInputTarget);
    this.hide(this.attachmentInputTarget);
    this.show(this.linkInputTarget);

    this.focusWithCursorAtTheEnd(this.titleInputTarget)
  }

  setAttachment(e) {
    if (e) {
      e.preventDefault();
    }
    this.hiddenTypeTarget.value = "attachment";

    this.linkButtonTarget.classList.remove("tab--active");
    this.attachmentButtonTarget.classList.add("tab--active");
    this.internalButtonTarget.classList.remove("tab--active");

    this.hide(this.richTextInputTarget);
    this.hide(this.linkInputTarget);
    this.show(this.attachmentInputTarget);

    this.focusWithCursorAtTheEnd(this.titleInputTarget)
  }
}
