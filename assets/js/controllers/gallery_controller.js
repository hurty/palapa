import BaseController from "./base_controller"
import { LuminousGallery } from 'luminous-lightbox'

export default class extends BaseController {
  static targets = []

  connect() {
    new LuminousGallery(this.element.querySelectorAll("figure[class^='attachment attachment--preview'] > a"))
  }
}
