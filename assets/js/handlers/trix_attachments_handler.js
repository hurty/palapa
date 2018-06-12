document.addEventListener("DOMContentLoaded", function () {

  // Handle files upload through the text editor
  document.addEventListener("trix-attachment-add", function (event) {
    let attachment
    attachment = event.attachment
    if (attachment.file) {
      uploadAttachment(attachment)
    }
  })

  // Handle file deletion when the attachment is deleted
  document.addEventListener("trix-attachment-remove", function (event) {
    let attachment
    attachment = event.attachment
    if (attachment.file) {

      console.log("Removed attachment")
      console.log(attachment.getAttribute("attachment_uuid"))
      deleteAttachment(event.attachment)
    }
  })

  function uploadAttachment(attachment) {
    let file, form, xhr, host;
    host = "/attachments"
    file = attachment.file;

    const element = document.head.querySelector('meta[name="csrf-token"]')
    const csrfToken = element.getAttribute("content")

    form = new FormData;
    form.append("Content-Type", file.type);
    form.append("file", file);

    xhr = new XMLHttpRequest;
    xhr.open("POST", host, true);
    xhr.setRequestHeader("X-CSRF-Token", csrfToken)

    xhr.upload.onprogress = function (event) {
      var progress;
      progress = event.loaded / event.total * 100;
      return attachment.setUploadProgress(progress);
    };

    xhr.onload = function () {
      var href, url;
      if (xhr.status === 201) {
        let response = JSON.parse(xhr.responseText)

        return attachment.setAttributes({
          attachment_uuid: response.attachment_uuid,
          url: response.thumb_url,
          href: response.original_url
        });
      }
    };

    return xhr.send(form);
  };

  function deleteAttachment(attachment) {
    let attachmentUUID = attachment.getAttribute("attachment_uuid")
    PA.fetch(`/attachments/${attachmentUUID}`, { method: "DELETE" })
  }
})
