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
    const errorRedirectURL = this.data.get("error-redirect-url");
    const successRedirectURL = this.data.get("success-redirect-url");
    const controller = this;

    this.stripe
      .handleCardPayment(this.data.get("client-secret"), {
        setup_future_usage: "off_session"
      })
      .then(function(result) {
        controller.hide(controller.waitMessageTarget);

        if (result.error) {
          controller.show(controller.errorMessageTarget);
          window.location = errorRedirectURL;
        } else {
          controller.show(controller.successMessageTarget);
          window.location = successRedirectURL;
        }
      });
  }

  displayErrorMessage() {
    this.messageTarget;
  }

  loadStripeJS() {
    return new Promise((resolve, reject) => {
      const existingScript = document.getElementById("stripejs");

      if (!existingScript) {
        const script = document.createElement("script");
        script.async = false;
        script.src = "https://js.stripe.com/v3/";
        script.type = "text/javascript";
        script.id = "stripejs";

        script.addEventListener("load", resolve);
        script.addEventListener("error", () =>
          reject("Error loading StripeJS script.")
        );
        script.addEventListener("abort", () =>
          reject("StripeJS loading aborted.")
        );

        document.body.appendChild(script);
      } else {
        resolve;
      }
    });
  }
}
