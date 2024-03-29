defmodule PalapaWeb.EventView do
  use PalapaWeb, :view

  def event_summary(conn, event) do
    author = event.author.account.name

    case event.action do
      :new_organization ->
        gettext("%{author} created the workspace %{organization}",
          author: author,
          organization: event.organization.name
        )

      :new_member ->
        gettext("%{member} joined the workspace", member: author)

      :new_message ->
        gettext("%{author} posted a new message", author: author)

      :new_message_comment ->
        message = event.message

        gettext("%{author} commented on message %{message_link}",
          author: author,
          message_link:
            safe_to_string(
              quoted_link(message.title,
                to: Routes.message_url(conn, :show, message.organization_id, message.id)
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
                to: Routes.document_url(conn, :show, document.organization_id, document)
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
                to: Routes.document_page_url(conn, :show, event.organization_id, page)
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
                to: Routes.document_page_url(conn, :show, event.organization_id, event.page)
              )
            )
        )
        |> raw()

      :new_contact ->
        gettext("%{author} added %{contact_link} as a new contact",
          author: author,
          contact_link:
            safe_to_string(
              link(PalapaWeb.ContactView.full_name(event.contact),
                to:
                  Routes.live_url(
                    conn,
                    PalapaWeb.ContactLive,
                    event.organization_id,
                    event.contact_id
                  )
              )
            )
        )
        |> raw()

      :new_contact_comment ->
        gettext("%{author} posted a new comment on %{contact_link}",
          author: author,
          contact_link:
            safe_to_string(
              link(PalapaWeb.ContactView.full_name(event.contact),
                to:
                  Routes.live_url(
                    conn,
                    PalapaWeb.ContactLive,
                    event.organization_id,
                    event.contact_id
                  )
              )
            )
        )
        |> raw()

      _ ->
        nil
    end
  end

  def event_target_title(conn, event) do
    case event.action do
      :new_message ->
        message = event.message

        link(message.title,
          to: Routes.message_url(conn, :show, message.organization_id, message.id)
        )

      :new_document ->
        document = event.document

        link(document.title,
          to: Routes.document_url(conn, :show, document.organization_id, document)
        )

      :new_document_page ->
        page = event.page
        link(page.title, to: Routes.document_page_url(conn, :show, event.organization_id, page))

      _ ->
        nil
    end
  end

  def event_target_excerpt(conn, event) do
    case event.action do
      :new_message ->
        message = event.message

        raw_link(PalapaWeb.MessageView.excerpt(message.content),
          to: Routes.message_url(conn, :show, message.organization_id, message.id)
        )

      :new_message_comment ->
        message_comment = event.message_comment
        message = event.message

        raw_link(PalapaWeb.MessageView.excerpt(message_comment.content),
          to:
            Routes.message_url(conn, :show, message_comment.organization_id, message) <>
              "##{Helpers.dom_id(message_comment)}"
        )

      :new_document_page ->
        page = event.page

        raw_link(PalapaWeb.MessageView.excerpt(page.content),
          to: Routes.document_page_url(conn, :show, event.organization_id, page)
        )

      :new_document_suggestion ->
        suggestion = event.document_suggestion

        raw_link(PalapaWeb.MessageView.excerpt(suggestion.content),
          to: Routes.document_page_url(conn, :show, event.organization_id, suggestion.page_id)
        )

      :new_document_suggestion_comment ->
        page = event.page
        suggestion_comment = event.document_suggestion_comment

        raw_link(PalapaWeb.MessageView.excerpt(suggestion_comment.content),
          to: Routes.document_page_url(conn, :show, event.organization_id, page.id)
        )

      :new_contact_comment ->
        raw_link(PalapaWeb.MessageView.excerpt(event.contact_comment.content),
          to:
            Routes.live_url(
              conn,
              PalapaWeb.ContactLive,
              event.organization_id,
              event.contact_id
            )
        )

      _ ->
        nil
    end
  end

  def event_icon(event) do
    case event.action do
      :new_organization ->
        "fas fa-cog"

      :new_member ->
        "fas fa-user-alt"

      :new_message ->
        "fas fa-comment"

      :new_message_comment ->
        "fas fa-comments"

      :new_document ->
        "fas fa-file-alt"

      :new_document_page ->
        "fas fa-file-alt"

      :new_document_suggestion ->
        "fas fa-file-alt"

      :new_document_suggestion_comment ->
        "fas fa-file-alt"

      :new_contact ->
        "fas fa-address-book"

      :new_contact_comment ->
        "fas fa-address-book"

      _ ->
        nil
    end
  end

  defp raw_link(title, opts) do
    link(raw(title), opts)
  end

  defp quoted_link(title, opts) do
    link("“#{title}”", opts)
  end
end
