import BaseController from "./base_controller";

export default class extends BaseController {
  static targets = ["existingInvoiceRadio", "newInvoiceRadio", "customerSelect"];

  connect() {
    this.updateCustomerSelect()
  }

  updateCustomerSelect() {
    if (this.existingInvoiceRadioTarget.checked) {
      this.customerSelectTarget.disabled = false
    } else {
      this.customerSelectTarget.disabled = true
    }

  }
}
