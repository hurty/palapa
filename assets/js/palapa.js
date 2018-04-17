function getMetaValue(name) {
  const element = document.head.querySelector(`meta[name="${name}"]`)
  return element.getAttribute("content")
}

function fetchWithDefaultOptions(url, options = {}) {
  let defaultOptions = {
    method: "GET",
    credentials: "same-origin",
    headers: {
      "X-CSRF-Token": getMetaValue("csrf-token"),
      "X-Requested-With": "XMLHttpRequest"
    }
  }

  return fetch(url, Object.assign(defaultOptions, options))
}

function fetchHTML(url, options = {}) {
  return fetchWithDefaultOptions(url, options)
    .then(response => response.text())
}

function remoteLink(link, options = {}) {
  let url = link.getAttribute("href")
  if (url === null || url === undefined || url === "#") {
    url = link.getAttribute("data-to")
  }
  let method = link.getAttribute("data-method") || "get"
  let mergedOptions = Object.assign({ url: url, method: method }, options)
  return fetchHTML(url, mergedOptions)
}

function confirm(element) {
  let message = element.getAttribute("data-confirm")
  return (message && window.confirm(message))
}

window.PA = {
  fetch: fetchWithDefaultOptions,
  fetchHTML: fetchHTML,
  remoteLink: remoteLink,
  confirm: confirm
}

export default window.PA
