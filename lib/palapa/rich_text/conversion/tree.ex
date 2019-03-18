defmodule Palapa.RichText.Tree do
  defdelegate parse(html_string), to: Floki

  def map(html_tree_list, fun) when is_list(html_tree_list) do
    Enum.map(html_tree_list, &transform_node(&1, fun))
  end

  def map(html_tree, fun), do: transform_node(html_tree, fun)

  def transform_node({name, attrs, rest}, fun) do
    {new_name, new_attrs, rest} = fun.({name, attrs, rest})
    {new_name, new_attrs, Enum.map(rest, &transform_node(&1, fun))}
  end

  def transform_node(other, _fun), do: other
end
