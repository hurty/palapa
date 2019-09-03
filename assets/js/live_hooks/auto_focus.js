let autoFocus = {
  mounted() {
    // Force focus at the end of input
    if (
      this.el.tagName == "INPUT" &&
      (this.el.type == "text" || this.el.type == "password")
    ) {
      let val = this.el.value;
      this.el.value = " ";
      this.el.value = val;
    }
    this.el.focus();
  }
};

export default autoFocus;
