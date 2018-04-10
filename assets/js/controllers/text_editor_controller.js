import { Controller } from "stimulus"
import Quill from "quill"

export default class extends Controller {
  static targets = ["toolbar", "content", "hiddenContent"]

  connect() {
    let toolbarOptions = [
      [{ 'header': 1 }, { 'header': 2 }],
      ['bold', 'italic', 'underline', 'strike'],
      [{ 'list': 'ordered' }, { 'list': 'bullet' }],
      [{ 'color': [] }, { 'background': [] }],
      ['blockquote', 'code-block'],
      ['link', 'image', 'video']
    ];

    this.editor = new Quill(this.contentTarget, {
      modules: { toolbar: toolbarOptions },
      theme: 'snow'
    });

    this.editor.on('text-change', () =>
      this.updateHiddenContent()
    );
  }

  updateHiddenContent() {
    this.hiddenContentTarget.value = this.editor.root.innerHTML
  }

  clear() {
    this.editor.root.innerHTML = ""
  }
}
