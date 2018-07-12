import { Controller } from "stimulus"

export default class extends Controller {
  static targets = ["renewButton", "cancelButton"]

  cancel(event) {
    event.preventDefault()
    let link = this.cancelButtonTarget

    if (!PA.confirm(link)) {
      return;
    }

    PA.remoteLink(link, { method: "delete" })
      .then(html => {
        this.element.remove()
        let pendingInvitationsCount = document.getElementById("pending_invitations_list").childElementCount
        if (pendingInvitationsCount === 0)
          document.getElementById("pending_invitations_container").remove()

      })
  }
}
