let serializeForm = form => {
  let formData = new FormData(form);
  let params = new URLSearchParams();
  for (let [key, val] of formData.entries()) {
    params.append(key, val);
  }

  return params.toString();
};

let SavedForm = {
  mounted() {
    this.el.addEventListener("input", e => {
      Params.set(this.viewName, "stashed_form", serializeForm(this.el));
    });
  }
};

export default SavedForm;
