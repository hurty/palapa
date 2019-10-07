import StripeController from "./stripe_controller";

export default class extends StripeController {
  static targets = ["waitMessage", "successMessage", "errorMessage"];

  connect() {
    this.form = this.element;

    this.loadStripeJS()
      .then(() => {
        this.stripe = Stripe(this.data.get("api-key"));
        this.handlePayment();
      })
      .catch(error => {
        console.log(error);
      });
  }

  handlePayment() {
    const controller = this;

    this.stripe
      .handleCardPayment(this.data.get("client-secret"), {
        setup_future_usage: "off_session"
      })
      .then(function(result) {
        if (result.error) {
          controller.handlePaymentError();
        } else {
          controller.handlePaymentSuccess();
        }
      });
  }

  handlePaymentError() {
    this.hide(this.waitMessageTarget);
    this.show(this.errorMessageTarget);
    window.location = this.data.get("error-redirect-url");
  }

  handlePaymentSuccess() {
    this.hide(this.waitMessageTarget);
    this.show(this.successMessageTarget);
    this.refreshSubscriptionStatus().finally(
      response => (window.location = this.data.get("success-redirect-url"))
    );
  }

  // The subscription status will be updated via a Stripe Webhook anyway
  // but this webhook can be late and we want our customer to be able to
  // use his workspace immediately after payment.
  refreshSubscriptionStatus() {
    return PA.fetch(this.data.get("refresh-subscription-url"), {
      method: "post"
    });
  }
}
