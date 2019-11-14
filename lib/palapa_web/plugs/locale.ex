defmodule PalapaWeb.Locale do
  import Plug.Conn

  def init(options) do
    options
  end

  def call(conn, _options) do
    user_locale = determine_user_locale(conn)
    Gettext.put_locale(PalapaWeb.Gettext, user_locale)
    assign(conn, :locale, user_locale)
  end

  def determine_user_locale(conn) do
    get_locale_from_account_preference(conn) || get_locale_from_headers(conn)
  end

  defp get_locale_from_headers(conn) do
    conn
    |> extract_accept_language
    |> Enum.find("en", fn accepted_locale -> supported_locale?(accepted_locale) end)
  end

  defp get_locale_from_account_preference(conn) do
    conn.assigns.current_account.locale
  end

  def supported_locale?(locale) do
    Enum.member?(Gettext.known_locales(PalapaWeb.Gettext), locale)
  end

  # Extracted from https://github.com/smeevil/set_locale
  defp extract_accept_language(conn) do
    case get_req_header(conn, "accept-language") do
      [value | _] ->
        value
        |> String.split(",")
        |> Enum.map(&parse_language_option/1)
        |> Enum.sort(&(&1.quality > &2.quality))
        |> Enum.map(& &1.tag)
        |> Enum.reject(&is_nil/1)
        |> ensure_language_fallbacks()

      _ ->
        []
    end
  end

  defp parse_language_option(string) do
    captures = Regex.named_captures(~r/^\s?(?<tag>[\w\-]+)(?:;q=(?<quality>[\d\.]+))?$/i, string)

    quality =
      case Float.parse(captures["quality"] || "1.0") do
        {val, _} -> val
        _ -> 1.0
      end

    %{tag: captures["tag"], quality: quality}
  end

  defp ensure_language_fallbacks(tags) do
    Enum.flat_map(tags, fn tag ->
      [language | _] = String.split(tag, "-")
      if Enum.member?(tags, language), do: [tag], else: [tag, language]
    end)
  end
end
