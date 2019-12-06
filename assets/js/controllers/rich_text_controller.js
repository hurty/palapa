import BaseController from "./base_controller"
import {
  LuminousGallery
} from 'luminous-lightbox'

export default class extends BaseController {
  connect() {
    this.handleImagesGallery()
  }

  handleImagesGallery() {
    new LuminousGallery(this.imagesAttachmentsLinks)
  }

  get imagesAttachmentsLinks() {
    return this.element.querySelectorAll("a[class^='attachment-gallery-item'],a[class^='attachment-original-item']")
  }
}
