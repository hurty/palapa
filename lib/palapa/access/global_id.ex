defmodule Palapa.Access.GlobalId do
  @enforce_keys [:uri]
  defstruct [:uri, :context, :resource_type, :resource_id]

  @default_context "globalid"
  @path_regex ~r{\A/([^/]+)/?([^/]+)?\z}

  defmodule MissingResourceIdError do
    defexception message: "Unable to create a GlobalId without a resource id."
  end

  def create(context \\ @default_context, %{__struct__: _} = resource) when is_binary(context) do
    unless resource.id do
      raise MissingResourceIdError
    end

    %__MODULE__{
      uri: %URI{
        scheme: "gid",
        host: context,
        path: "/#{resource.__struct__}/#{resource.id}"
      }
    }
  end

  def parse(gid) when is_binary(gid) do
    uri = URI.parse(gid)
    validate_uri(uri)
    {resource_type, resource_id} = extract_resource_from_path(uri)

    %__MODULE__{
      context: uri.host,
      resource_type: resource_type,
      resource_id: resource_id,
      uri: uri
    }
  end

  def locate(gid) when is_binary(gid) do
    gid
    |> parse
    |> locate
  end

  def locate(%__MODULE__{} = gid) do
    schema = String.to_existing_atom(gid.resource_type)
    Palapa.Repo.get(schema, gid.resource_id)
  end

  def locate_all(gids, resource_type \\ nil) do
    if gids && Enum.any?(gids) do
      gids =
        if resource_type do
          gids
          |> Enum.map(fn gid -> parse(gid) end)
          |> Enum.filter(fn gid -> gid.resource_type == to_string(resource_type) end)
        end

      Enum.map(gids, fn gid -> locate(gid) end)
    else
      []
    end
  end

  defp validate_uri(uri) do
    validate_scheme(uri)
    validate_path(uri)
  end

  defp validate_scheme(uri) do
    unless uri.scheme == "gid" do
      raise ArgumentError, message: "Not a gid:// URI scheme."
    end
  end

  defp validate_path(uri) do
    unless uri.path =~ @path_regex do
      raise ArgumentError, message: "Not a valid resource path."
    end
  end

  defp extract_resource_from_path(uri) do
    try do
      [[_, resource_type, resource_id]] = Regex.scan(@path_regex, uri.path)
      {resource_type, resource_id}
    rescue
      _ -> raise ArgumentError, message: "Cannot extract resource information."
    end
  end

  # def get(locator, gid) do
  #   build_config()
  #   locator.get(gid)
  # end
end

defimpl String.Chars, for: Palapa.Access.GlobalId do
  def to_string(gid) do
    URI.to_string(gid.uri)
  end
end

defimpl Phoenix.HTML.Safe, for: Palapa.Access.GlobalId do
  def to_iodata(gid) do
    URI.to_string(gid.uri)
  end
end
