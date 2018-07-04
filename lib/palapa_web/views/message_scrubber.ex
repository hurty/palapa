defmodule PalapaWeb.MessageScrubber do
  @moduledoc """
  Allows basic HTML tags to support user input for writing relatively
  plain text but allowing headings, links, bold, and so on.

  Does not allow any mailto-links, styling, HTML5 tags, video embeds etc.
  """

  require HtmlSanitizeEx.Scrubber.Meta
  alias HtmlSanitizeEx.Scrubber.Meta

  # Removes any CDATA tags before the traverser/scrubber runs.
  Meta.remove_cdata_sections_before_scrub()
  Meta.strip_comments()

  Meta.allow_tags_and_scrub_their_attributes([
    "a",
    "b",
    "blockquote",
    "code",
    "del",
    "div",
    "em",
    "h1",
    "h2",
    "h3",
    "h4",
    "h5",
    "i",
    "li",
    "ol",
    "p",
    "pre",
    "span",
    "strong",
    "ul",
    "u"
  ])

  Meta.strip_everything_not_covered()
end
