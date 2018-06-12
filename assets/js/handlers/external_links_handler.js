document.addEventListener("DOMContentLoaded", function () {

  // Open all external links in a new window
  document.addEventListener("click", function (event) {
    var el = event.target

    if (el.tagName === "A" && !el.isContentEditable && el.host !== window.location.host) {
      el.setAttribute("target", "_blank")
    }
  }, true)
})
