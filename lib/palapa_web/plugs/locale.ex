defmodule PalapaWeb.Locale do
  import Plug.Conn

  def init(options) do
    options
  end

  # If the user has an account and a language preference
  def call(%{assigns: %{current_account: %{locale: locale}}} = conn, _opts)
      when is_binary(locale) do
    Gettext.put_locale(Palapa.Gettext, locale)
    conn
  end

  # If the user has an account but no preference set
  def call(%{assigns: %{current_account: %{locale: locale} = current_account}} = conn, _options)
      when is_nil(locale) do
    determined_locale = get_locale_from_headers(conn)
    Palapa.Accounts.update_account(current_account, %{locale: determined_locale})
    Gettext.put_locale(Palapa.Gettext, determined_locale)
    conn
  end

  # If the user is not logged in
  def call(conn, _options) do
    session_locale = get_session(conn, :locale)
    user_locale = session_locale || get_locale_from_headers(conn)
    Gettext.put_locale(Palapa.Gettext, user_locale)

    if session_locale do
      conn
    else
      put_session(conn, :locale, user_locale)
    end
  end

  defp get_locale_from_headers(conn) do
    conn
    |> extract_accept_language
    |> Enum.find("en", fn accepted_locale -> supported_locale?(accepted_locale) end)
  end

  def supported_locale?(locale) do
    Enum.member?(Gettext.known_locales(Palapa.Gettext), locale)
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
