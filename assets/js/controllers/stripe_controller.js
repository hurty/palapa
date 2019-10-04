import BaseController from "./base_controller";

export default class extends BaseController {
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
