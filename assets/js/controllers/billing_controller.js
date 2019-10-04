import StripeController from "./stripe_controller";

export default class extends StripeController {
  static targets = ["cardElement", "cardErrors"];

  connect() {
    this.form = this.element;

    this.loadStripeJS()
      .then(() => {
        const apiKey = this.data.get("api-key");
        this.stripe = Stripe(apiKey);
        this.elements = this.stripe.elements();

        this.setupCardField();
      })
      .catch(error => {
        console.log(error);
      });
  }

  setupCardField() {
    this.card = this.elements.create("card");
    this.card.mount(this.cardElementTarget);

    this.card.addEventListener("change", event => {
      if (event.error) {
        this.cardErrorsTarget.textContent = event.error.message;
      } else {
        this.cardErrorsTarget.textContent = "";
      }
    });
  }

  submitSubscription(event) {
    event.preventDefault();

    this.stripe.createToken(this.card).then(result => {
      if (result.error) {
        this.updateCardErrors(error);
      } else {
        const token = result.token;
        this.addHiddenFieldToForm("customer[stripe_token_id]", token.id);
        this.addHiddenFieldToForm("customer[card_brand]", token.card.brand);
        this.addHiddenFieldToForm("customer[card_last_4]", token.card.last4);
        this.addHiddenFieldToForm(
          "customer[card_expiration_month]",
          token.card.exp_month
        );
        this.addHiddenFieldToForm(
          "customer[card_expiration_year]",
          token.card.exp_year
        );

        this.form.submit();
      }
    });
  }

  updateCardErrors(error) {
    if (error) {
      this.cardErrorsTarget.textContent = error.message;
    } else {
      this.cardErrorsTarget.textContent = "";
    }
  }

  addHiddenFieldToForm(name, value) {
    const hiddenField = document.createElement("input");
    hiddenField.type = "hidden";
    hiddenField.name = name;
    hiddenField.value = value;
    this.form.appendChild(hiddenField);
  }
}
