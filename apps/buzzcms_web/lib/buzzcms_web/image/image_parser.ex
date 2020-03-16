defmodule BuzzcmsWeb.Image.Parser do
  @allow_actions ["resize", "fit", "crop"]
  @allow_widths ["100", "200", "300", "400", "600", "800", "1200"]
  @allow_heights ["100", "200", "300", "400", "600", "800", "1200"]
  @allow_qualities ["60", "80", "90", "100"]
  @allow_formats ["jpg", "webp", "png"]

  def to_map(transform) do
    transform
    |> String.split(",")
    |> Enum.reduce([], fn item, acc ->
      case String.split(item, "_") do
        ["c", v] when v in @allow_actions -> acc ++ [{"action", v}]
        ["w", v] -> acc ++ [{"width", get_width(v)}]
        ["h", v] -> acc ++ [{"height", get_height(v)}]
        ["f", v] when v in @allow_formats -> acc ++ [{"format", v}]
        ["b", v] -> acc ++ [{"extend", v}]
        ["q", v] when v in @allow_qualities -> acc ++ [{"quality", v}]
        _ -> acc
      end
    end)
    |> Enum.into(%{"extend" => "white", "action" => "resize"})
  end

  def to_transform(map) do
    map
    |> Enum.reduce([], fn item, acc ->
      case item do
        {"action", v} -> acc ++ ["c_#{v}"]
        {"width", v} -> acc ++ ["w_#{v}"]
        {"height", v} -> acc ++ ["h_#{v}"]
        {"format", v} -> acc ++ ["f_#{v}"]
        {"extend", v} -> acc ++ ["b_#{v}"]
        {"quality", v} -> acc ++ ["q_#{v}"]
        _ -> acc
      end
    end)
    |> Enum.sort()
    |> Enum.join(",")
  end

  def to_request_url(%{map: map, id: id, bucket: bucket}) do
    action =
      case Map.get(map, "action") do
        "scale" -> "resize"
        v -> v
      end

    query =
      Map.drop(map, ["action"])
      |> Map.merge(%{"file" => Path.join([bucket, "origin", id] |> Enum.filter(&(&1 != nil)))})

    "#{imaginary_host()}/#{action}?#{URI.encode_query(query)}"
  end

  defp get_width(width) do
    [max_width] = Enum.take(@allow_widths, -1)

    @allow_widths
    |> Enum.find(nil, fn w ->
      Integer.parse(w) >= Integer.parse(width)
    end) || max_width
  end

  defp get_height(height) do
    [max_height] = Enum.take(@allow_heights, -1)

    @allow_heights
    |> Enum.find(nil, fn h ->
      Integer.parse(h) >= Integer.parse(height)
    end) || max_height
  end

  defp imaginary_host do
    case System.fetch_env("IMAGINARY_HOST") do
      {:ok, host} -> host
      _ -> "http://imaginary:9000"
    end
  end
end
