function getMetaValue(name) {
  const element = document.head.querySelector(`meta[name="${name}"]`);
  return element.getAttribute("content");
}

function fetchRequest(url, options = {}) {
  let defaultOptions = {
    method: "get",
    credentials: "same-origin",
    headers: {
      "X-CSRF-Token": getMetaValue("csrf-token"),
      "X-Requested-With": "XMLHttpRequest"
    }
  };

  return fetch(url, Object.assign(defaultOptions, options));
}

async function fetchHTML(url, options = {}) {
  const response = await fetchRequest(url, options);
  if (response.status >= 200 && response.status < 300) {
    return response.text();
  } else {
    let error = new Error(response.status);
    error.response = response;
    throw error;
  }
}

function remoteLink(link, options = {}) {
  let url = link.getAttribute("href");
  if (url === null || url === undefined || url === "#") {
    url = link.getAttribute("data-to");
  }
  let method = link.getAttribute("data-method") || "get";
  let mergedOptions = Object.assign({ url: url, method: method }, options);
  return fetchHTML(url, mergedOptions);
}

function confirm(element) {
  let message = element.getAttribute("data-confirm");
  return message && window.confirm(message);
}

window.PA = {
  fetchRequest: fetchRequest,
  fetchHTML: fetchHTML,
  remoteLink: remoteLink,
  confirm: confirm,
  getMetaValue: getMetaValue
};

export default window.PA;
