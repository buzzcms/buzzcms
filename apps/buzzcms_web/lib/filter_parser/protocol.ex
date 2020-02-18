defprotocol FilterParser.ItemParser do
  def parse(value, field_name, opts \\ [])
end
