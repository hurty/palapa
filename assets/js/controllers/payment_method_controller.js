import StripeController from "./stripe_controller";

export default class extends StripeController {
  static targets = ["cardContainer", "cardErrors", "saveButton"];

  connect() {
    this.form = this.element;

    this.loadStripeJS()
      .then(() => {
        this.stripe = Stripe(this.data.get("api-key"));
        this.elements = this.stripe.elements();
        this.cardElement = this.elements.create("card");
        this.cardElement.mount(this.cardContainerTarget);
      })
      .catch(error => {
        console.log(error);
      });
  }

  handleCardSetup(event) {
    event.preventDefault();
    this.saveButtonTarget.disabled = true;

    const controller = this;
    const clientSecret = this.data.get("client-secret");

    this.stripe
      .handleCardSetup(clientSecret, this.cardElement)
      .then(result => {
        if (result.error) {
          controller.handleSetupError(result.error);
        } else {
          controller.handleSetupSuccess(result.setupIntent);
        }
      })
      .finally(() => (this.saveButtonTarget.disabled = false));
  }

  handleSetupError(error) {
    this.cardErrorsTarget.textContent = error.message;
  }

  handleSetupSuccess(setupIntent) {
    const tokenIdInput = document.createElement("input");
    tokenIdInput.setAttribute("type", "hidden");
    tokenIdInput.setAttribute("name", "customer[payment_method_id]");
    tokenIdInput.setAttribute("value", setupIntent.payment_method);
    this.form.appendChild(tokenIdInput);
    this.form.submit();
  }
}
