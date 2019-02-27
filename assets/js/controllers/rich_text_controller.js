import BaseController from "./base_controller"
import { LuminousGallery } from 'luminous-lightbox'

export default class extends BaseController {
  connect() {
    this.handleImagesGallery()
  }

  handleImagesGallery() {
    new LuminousGallery(this.element.querySelectorAll("figure[class^='attachment attachment--preview'] > a"))
  }

  get attachmentsLinks() {
    return this.element.querySelectorAll("figure[class^='attachment attachment--preview'] > a")
  }
}
