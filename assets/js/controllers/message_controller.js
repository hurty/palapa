import { Controller } from "stimulus"
import { LuminousGallery } from 'luminous-lightbox'

export default class extends Controller {
  static targets = ["title", "teamsList", "publishToEveryone", "publishToSpecificTeams"]
  connect() {
    if (this.targets.has("title"))
      this.titleTarget.focus()

    if (this.data.get("page") == "show")
      this.handleImageGallery()

    this.handleTeamListVisibility()
  }

  handleImageGallery() {
    new LuminousGallery(document.querySelectorAll("a[data-trix-content-type^='image']"))
  }

  handleTeamListVisibility() {
    if (this.hasPublishToSpecificTeamsTarget) {
      if (this.publishToSpecificTeamsTarget.checked) {
        this.showTeamsList()
      }
    }
  }

  publishToEveryone() {
    this.hideTeamsList()
  }

  publishToSpecificTeams() {
    this.showTeamsList()
    this.teamsListTarget.scrollIntoView({
      behavior: 'smooth'
    })
  }

  showTeamsList() {
    this.teamsListTarget.classList.remove("hidden")
  }

  hideTeamsList() {
    this.teamsListTarget.classList.add("hidden")
  }
}
