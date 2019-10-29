import BaseController from "./base_controller";

export default class extends BaseController {
  initialize() {
    const commentForm = document.getElementById("contact_comment_form");
    this.editor = commentForm.getElementsByTagName("trix-editor")[0].editor;
  }
  connect() {
    this.clearTextEditor();
  }

  clearTextEditor() {
    this.editor.loadHTML("");
  }
}
