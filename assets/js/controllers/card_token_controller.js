import StripeController from "./stripe_controller";

export default class extends StripeController {
  static targets = ["cardContainer"];

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

  addCardToken(event) {
    event.preventDefault();

    this.stripe.createToken(this.cardElement).then(result => {
      if (result.error) {
        console.log(result.error);
      } else {
        this.addHiddenFieldToForm(
          this.form,
          "customer[stripe_token_id]",
          result.token.id
        );
        this.form.submit();
      }
    });
  }
}
