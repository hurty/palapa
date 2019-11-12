import BaseController from "./base_controller";

export default class extends BaseController {
  initialize() {
    this.intersectionObserver = new IntersectionObserver(targets =>
      this.stickToTop(targets)
    );
  }

  connect() {
    this.intersectionObserver.observe(this.element);
  }
  disconnect() {
    this.intersectionObserver.unobserve(this.element);
  }

  stickToTop(targets) {
    targets.forEach(target => {
      this.element.classList.toggle("sticky-top", target.isIntersecting);
    });
  }
}
