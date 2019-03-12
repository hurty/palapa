import {
  Controller
} from "stimulus"

export default class extends Controller {
  static targets = ["autocompleteList", "autocompleteChoice"]

  connect() {
    document.addEventListener("trix-initialize", e => {
      this.editor = e.target.editor
      this.addAttachmentButton()
      // this.members = JSON.parse(this.data.get("members"))
      // this.hideAutocomplete()
      // this.setUpKeyboardNavigation()
    })

    // document.addEventListener("trix-change", e => {
    //   this.detectSearchTerm()
    //   this.filterAutocompleteList()
    // })

    // Handle files upload through the text editor
    document.addEventListener("trix-attachment-add", e => {
      let attachment
      attachment = e.attachment
      if (attachment.file) {
        this.uploadAttachment(attachment)
      }
    })

    // this.element.addEventListener("focusout", (e) => {
    //   this.hideAutocomplete()
    // })
  }

  // detectSearchTerm() {
  //   if (this.cursorPosition === 0) {
  //     this.searchTerm = null
  //     return
  //   }

  //   let currentString = this.editorContent[this.cursorPosition - 1] || ""
  //   let position = this.cursorPosition - 1
  //   let searchingTrigger = true

  //   while (searchingTrigger) {
  //     if (currentString[0] === " ") {
  //       this.searchTerm = null
  //       searchingTrigger = false
  //       break
  //     } else if (currentString[0] === "\n") {
  //       this.searchTerm = null
  //       searchingTrigger = false
  //       break
  //     } else if (position < 0) {
  //       this.searchTerm = null
  //       searchingTrigger = false
  //       break
  //     }

  //     if (currentString[0] === "@" && (
  //       this.editorContent[position - 1] === " " ||
  //       this.editorContent[position - 1] === "￼" || // kind of empty string representing attachments in the editor.
  //       this.editorContent[position - 1] === "\n" ||
  //       position === 0)
  //     ) {
  //       this.autocompletePosition = position
  //       this.searchTerm = currentString
  //       break
  //     }

  //     position--
  //     currentString = this.editorContent[position] + currentString
  //   }
  // }

  // filterAutocompleteList() {
  //   if (!this.searchTerm) {
  //     this.hideAutocomplete()
  //     return
  //   }

  //   let filteredMembers
  //   if (this.searchTerm.length === 1) {
  //     filteredMembers = this.members.slice(0, 4)
  //   } else {
  //     filteredMembers = this.members.filter(member =>
  //       member.name.toLowerCase().includes(this.searchTerm.substr(1).toLowerCase())
  //     )
  //   }
  //   // Empty the suggestions list
  //   while (this.autocompleteListTarget.firstChild) {
  //     this.autocompleteListTarget.removeChild(this.autocompleteListTarget.firstChild)
  //   }

  //   // Populate the suggestion list with matched members names only
  //   filteredMembers.forEach(member => {
  //     let choice = document.createElement("li")
  //     choice.classList.add("autocomplete__choice")
  //     choice.setAttribute("data-target", "editor.autocompleteChoice")
  //     choice.setAttribute("data-action", "mouseover->editor#selectAutocompleteChoice click->editor#insertAutocompleteChoice")
  //     choice.setAttribute("data-member-id", member.id)
  //     choice.setAttribute("data-member-name", member.name)
  //     choice.innerHTML = member.name

  //     this.autocompleteListTarget.appendChild(choice)
  //   })
  //   this.autocompleteIndex = 0
  //   this.showAutocomplete()
  // }

  // setUpKeyboardNavigation() {
  //   document.addEventListener("keydown", e => {

  //     if (this.autocompleteIsActive) {
  //       // Up key
  //       if (e.keyCode == '38') {
  //         e.preventDefault()

  //         if (this.autocompleteIndex === 0) {
  //           this.autocompleteIndex = this.autocompleteChoiceTargets.length - 1
  //         } else {
  //           this.autocompleteIndex--
  //         }
  //       }

  //       // Down key
  //       else if (e.keyCode == '40') {
  //         e.preventDefault()
  //         if (this.autocompleteIndex === this.autocompleteChoiceTargets.length - 1) {
  //           this.autocompleteIndex = 0
  //         } else {
  //           this.autocompleteIndex = this.autocompleteIndex + 1
  //         }
  //       }

  //       // Escape
  //       else if (e.keyCode == '27') {
  //         e.preventDefault()
  //         this.hideAutocomplete()
  //       }

  //       // Tab key
  //       else if (e.keyCode == '9') {
  //         e.preventDefault()
  //         this.insertAutocompleteChoice()
  //       }

  //       // Enter key
  //       else if (e.keyCode == '13') {
  //         e.preventDefault()
  //         this.insertAutocompleteChoice(true)
  //       }
  //     }
  //   })
  // }

  // hideAutocomplete() {
  //   this.autocompleteIndex = 0
  //   this.autocompleteListTarget.classList.add("hidden")
  //   this.autocompleteIsActive = false
  // }

  // showAutocomplete() {
  //   let rect = this.editor.getClientRectAtPosition(this.autocompletePosition)
  //   if (rect) {
  //     this.autocompleteListTarget.classList.remove("hidden")

  //     this.autocompleteListTarget.style.top = rect.top + rect.height + "px"
  //     this.autocompleteListTarget.style.left = rect.left + rect.width + "px"
  //     this.autocompleteListTarget.style.width = "auto"
  //     this.autocompleteListTarget.style.maxWidth = "350px"
  //     this.autocompleteListTarget.style.minWidth = "1 00px"

  //     this.autocompleteIsActive = true
  //   }
  // }

  // selectAutocompleteChoice(e) {
  //   let index = this.autocompleteChoiceTargets.indexOf(e.target)
  //   this.autocompleteIndex = index
  // }

  // insertAutocompleteChoice(deleteEndingLineBreak = false) {
  //   let startRange = this.autocompletePosition
  //   let endRange = this.cursorPosition

  //   this.editor.setSelectedRange([startRange, endRange])

  //   let memberName = this.autocompleteChoiceTargets[this.autocompleteIndex].getAttribute("data-member-name")
  //   let memberId = this.autocompleteChoiceTargets[this.autocompleteIndex].getAttribute("data-member-id")
  //   let attachementContent = `<mention data-member-id="${memberId}" class="autocomplete__inserted">@${memberName}</mention>`
  //   let attachment = new Trix.Attachment({
  //     content: attachementContent
  //   })

  //   // Workaround https://github.com/basecamp/trix/issues/422 (pb still present in firefox, webkit is ok)
  //   attachment.setAttributes({
  //     url: "#",
  //     href: "#"
  //   })

  //   this.editor.insertAttachment(attachment)
  //   this.editor.insertString(" ")

  //   if (deleteEndingLineBreak)
  //     this.editor.deleteInDirection("forward")

  //   this.hideAutocomplete()
  // }

  // highlightAutocompleteChoice() {
  //   this.autocompleteChoiceTargets.forEach((el, i) => {
  //     el.classList.toggle("autocomplete__choice--selected", this.autocompleteIndex === i)
  //   })
  // }

  // fetchAutocompleteList(searchTerm) {
  //   let url = this.data.get("autocompleteUrl") + "?name_pattern=" + searchTerm
  //   PA.fetchHTML(url).then(filteredList => {
  //     this.autocompleteListTarget.innerHTML = filteredList
  //   })
  // }

  uploadAttachment(attachment) {
    let file, form, xhr, host;
    host = this.data.get("attachments-url")
    file = attachment.file;

    const element = document.head.querySelector('meta[name="csrf-token"]')
    const csrfToken = element.getAttribute("content")

    form = new FormData;
    form.append("Content-Type", file.type);
    form.append("file", file);

    xhr = new XMLHttpRequest;
    xhr.open("POST", host, true);
    xhr.setRequestHeader("X-CSRF-Token", csrfToken)

    xhr.upload.onprogress = function (event) {
      var progress;
      if (event.total > 0) {
        progress = event.loaded / event.total * 100;
        return attachment.setUploadProgress(progress);
      } else {
        return attachment.setUploadProgress(100);
      }
    };

    xhr.onload = function () {
      var href, url;
      if (xhr.status === 201) {
        let response = JSON.parse(xhr.responseText)

        return attachment.setAttributes({
          sgid: response.sgid,
          url: response.thumb_url,
          href: response.original_url
        });
      }
    };

    return xhr.send(form);
  };

  addAttachmentButton() {
    document.addEventListener("trix-action-invoke", function (event) {
      let editor = event.target.editor

      if (event.actionName === "x-attachment") {
        let input = document.createElement('input')
        input.type = 'file'
        input.multiple = true
        input.click()

        input.onchange = e => {
          editor.insertFiles(e.target.files)
        }
      }
    })

  }

  get cursorPosition() {
    return this.editor.getPosition()
  }

  get autocompleteIndex() {
    return parseInt(this.data.get("autocompleteIndex"))
  }

  set autocompleteIndex(value) {
    this.data.set("autocompleteIndex", value)
    this.highlightAutocompleteChoice()
  }

  get editorContent() {
    return this.editor.getDocument().toString()
  }
}
