import { Controller } from "stimulus"

export default class extends Controller {
  static targets = ["autocompleteList", "autocompleteChoice"]

  connect() {
    document.addEventListener("trix-initialize", e => {
      this.editor = e.target.editor
      this.hideAutocomplete()
    })

    document.addEventListener("trix-change", e => {
      if (this.autocompleteCanBeTriggered())
        this.highlightAutocompleteChoice()
    })

    this.element.addEventListener("keydown", e => {

      if (this.autocompleteIsActive) {
        // Up key
        if (e.keyCode == '38') {
          e.preventDefault()

          if (this.autocompleteIndex === 0) {
            this.autocompleteIndex = this.autocompleteChoiceTargets.length - 1
          } else {
            this.autocompleteIndex--
          }
        }

        // Down key
        else if (e.keyCode == '40') {
          e.preventDefault()
          if (this.autocompleteIndex === this.autocompleteChoiceTargets.length - 1) {
            this.autocompleteIndex = 0
          } else {
            this.autocompleteIndex = this.autocompleteIndex + 1
          }
        }

        // Escape
        else if (e.keyCode == '27') {
          e.preventDefault()
          this.hideAutocomplete()
        }

        // Enter or Tab keys
        else if (e.keyCode == '13' || e.keyCode == '9') {
          e.preventDefault()
          console.log("Validate")

          this.editor.setSelectedRange(this.cursorPosition)
          let memberName = this.autocompleteChoiceTargets[this.autocompleteIndex].getAttribute("data-member-name")
          let attachment = new Trix.Attachment({ content: memberName })
          this.editor.insertAttachment(attachment)
          this.hideAutocomplete()
        }
      }
    })

    this.element.addEventListener("focusout", (e) => {
      this.hideAutocomplete()
    })
  }

  autocompleteCanBeTriggered() {
    let content = this.editor.getDocument().toString()
    let characterTyped = content.charAt(this.cursorPosition - 1)
    let characterBefore = content.charAt(this.cursorPosition - 2)

    return (characterTyped === "@") && (characterBefore.match(/\s/) || characterBefore === null || characterBefore === "")
  }

  hideAutocomplete() {
    this.autocompleteIndex = 0
    this.autocompleteListTarget.classList.add("hidden")
    this.autocompleteIsActive = false
  }

  highlightAutocompleteChoice() {
    // TODO : qq fois le cursor n'est plus là, du coup pas de position
    let rect = this.editor.getClientRectAtPosition(this.cursorPosition)
    if (rect) {
      this.autocompleteListTarget.classList.remove("hidden")
      this.autocompleteListTarget.style.top = rect.top + rect.height + "px"
      this.autocompleteListTarget.style.left = rect.left + rect.width + "px"
      this.autocompleteListTarget.style.width = "auto"
      this.autocompleteListTarget.style.maxWidth = "350px"

      this.autocompleteChoiceTargets.forEach((el, i) => {
        el.classList.toggle("autocomplete__choice--selected", this.autocompleteIndex === i)
      })
      this.autocompleteIsActive = true
    }
  }

  selectAutocompleteChoice(e) {
    let index = this.autocompleteChoiceTargets.indexOf(e.target)
    this.autocompleteIndex = index
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
}
