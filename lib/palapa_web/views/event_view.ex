defmodule PalapaWeb.EventView do
  use PalapaWeb, :view

  def event_summary(conn, event) do
    author = event.author.account.name

    case event.action do
      :new_message ->
        gettext("%{author} posted a new message", author: author)

      :new_message_comment ->
        message = event.message

        gettext("%{author} commented on message %{message_link}",
          author: author,
          message_link:
            safe_to_string(
              quoted_link(message.title,
                to: message_path(conn, :show, message.organization_id, message.id)
              )
            )
        )
        |> raw

      :new_document ->
        gettext("%{author} created a new document", author: author)

      :new_document_page ->
        document = event.document

        gettext("%{author} created a new page in %{document_link}",
          author: author,
          document_link:
            safe_to_string(
              quoted_link(document.title,
                to: document_path(conn, :show, document.organization_id, document)
              )
            )
        )
        |> raw()

      :new_document_suggestion ->
        page = event.page

        gettext("%{author} posted a new suggestion on page %{page_link}",
          author: author,
          page_link:
            safe_to_string(
              quoted_link("#{event.document.title} / #{event.page.title}",
                to: document_page_path(conn, :show, event.organization_id, page)
              )
            )
        )
        |> raw

      :new_document_suggestion_comment ->
        gettext(
          "%{comment_author} commented on %{suggestion_author}'s suggestion on page %{page_link}",
          comment_author: author,
          suggestion_author: event.document_suggestion.author.account.name,
          page_link:
            safe_to_string(
              quoted_link("#{event.document.title} / #{event.page.title}",
                to: document_page_path(conn, :show, event.organization_id, event.page)
              )
            )
        )
        |> raw()

      :new_member ->
        gettext("%{member} joined the workspace")

      _ ->
        nil
    end
  end

  def event_target_title(conn, event) do
    case event.action do
      :new_message ->
        message = event.message
        link(message.title, to: message_path(conn, :show, message.organization_id, message.id))

      :new_document ->
        document = event.document
        link(document.title, to: document_path(conn, :show, document.organization_id, document))

      :new_document_page ->
        page = event.page
        link(page.title, to: document_page_path(conn, :show, event.organization_id, page))

      _ ->
        nil
    end
  end

  def event_target_excerpt(conn, event) do
    case event.action do
      :new_message ->
        message = event.message

        link(PalapaWeb.MessageView.excerpt(message.content),
          to: message_path(conn, :show, message.organization_id, message.id)
        )

      :new_message_comment ->
        message_comment = event.message_comment
        message = event.message

        link(PalapaWeb.MessageView.excerpt(message_comment.content),
          to:
            message_path(conn, :show, message_comment.organization_id, message) <>
              "##{dom_id(message_comment)}"
        )

      :new_document_page ->
        page = event.page

        link(PalapaWeb.MessageView.excerpt(page.content),
          to: document_page_path(conn, :show, event.organization_id, page)
        )

      :new_document_suggestion ->
        suggestion = event.document_suggestion

        tag(:div) do
        end

        link(PalapaWeb.MessageView.excerpt(suggestion.content),
          to: document_page_path(conn, :show, event.organization_id, suggestion.page_id)
        )

      :new_document_suggestion_comment ->
        "suggestion comment"

      _ ->
        nil
    end
  end

  defp quoted_link(title, opts) do
    link("“#{title}”", opts)
  end
end
