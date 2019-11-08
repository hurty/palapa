import Choices from "choices.js";

const initChoices = function(el) {
  new Choices(el, {
    removeItemButton: true,
    placeholder: true,
    duplicateItemsAllowed: false
  });
};

let choices = {
  mounted() {
    initChoices(this.el);
  },

  updated() {
    initChoices(this.el);
  }
};

export default choices;
