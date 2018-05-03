defmodule PalapaWeb.Helpers do
  alias Phoenix.HTML

  def format_datetime(datetime) when is_nil(datetime), do: nil

  def format_datetime(datetime) do
    {:ok, formatted} = Timex.format(datetime, "{ISO:Extended}")
    formatted
  end

  def time_from_now(datetime) when is_nil(datetime), do: nil

  def time_from_now(datetime) do
    Timex.from_now(datetime)
  end

  def text_editor(organization, options \\ []) do
    editor_classes =
      "trix-content p-4 shadow-inner focus:shadow-none bg-grey-lightest text-grey-darkest "

    editor_classes = editor_classes <> (options[:class] || "min-h-screen-1/2")

    HTML.Tag.content_tag :div,
      class: "border rounded",
      "data-controller": "editor",
      "data-editor-autocomplete-index": "0",
      "data-editor-members": members_for_autocomplete(organization) do
      [
        HTML.Tag.content_tag(
          :"trix-editor",
          nil,
          class: editor_classes,
          placeholder: options[:placeholder] || "Your message here...",
          input: options[:input] || "content",
          "data-target": options[:"data-target"] || ""
        ),
        HTML.Tag.content_tag(
          :ul,
          nil,
          class: "autocomplete hidden",
          "data-target": "editor.autocompleteList"
        )
      ]
    end
  end

  def members_for_autocomplete(organization) do
    Palapa.Organizations.list_members(organization)
    |> Enum.map(fn m -> %{"id" => m.id, "name" => m.name} end)
    |> Jason.encode!()
  end
end

# <div class="border rounded" data-controller="editor" data-editor-autocomplete-index="0" data-editor-members="<%= PalapaWeb.MemberView.members_for_autocomplete(@current_organization) %>">
#   <trix-editor class="trix-content p-4 shadow-inner focus:shadow-none bg-grey-lightest text-grey-darkest min-h-screen-1/2" placeholder="Your message here..." input="content"></trix-editor>
#   <ul class="autocomplete hidden" data-target="editor.autocompleteList"></ul>
# </div>
