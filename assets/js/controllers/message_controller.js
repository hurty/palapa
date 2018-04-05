import { Controller } from "stimulus"

export default class extends Controller {
  static targets = ["teamsList", "publishToEveryone", "publishToSpecificTeams"]

  connect() {
    if (this.publishToSpecificTeamsTarget.checked) {
      this.showTeamsList()
    }
  }

  publishToEveryone() {
    this.hideTeamsList()
  }

  publishToSpecificTeams() {
    this.showTeamsList()
  }

  showTeamsList() {
    this.teamsListTarget.classList.remove("hidden");
  }

  hideTeamsList() {
    this.teamsListTarget.classList.add("hidden");
  }
}
