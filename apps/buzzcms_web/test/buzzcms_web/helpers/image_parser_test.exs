transform_cases = %{
  "w_100" => "b_white,c_scale,w_100",
  "w_100,q_80" => "b_white,c_scale,q_80,w_100",
  "w_100,q_80,c_scale" => "b_white,c_scale,q_80,w_100",
  "q_80,w_100" => "b_white,c_scale,q_80,w_100",
  "c_fit,q_80,w_100" => "b_white,c_fit,q_80,w_100",
  "c_fit,q_80,w_100,b_black" => "b_black,c_fit,q_80,w_100",
  "c_fit,c_scale,q_80,w_100,b_black" => "b_black,c_scale,q_80,w_100",
  "c_scale,c_fit,q_80,w_100,b_black" => "b_black,c_fit,q_80,w_100",
  "c_scale,c_fit,q_80,w_100,b_black,xxx" => "b_black,c_fit,q_80,w_100",
  "c_scale,c_fit,q_80,w_100,h_111,b_black,xxx" => "b_black,c_fit,h_200,q_80,w_100"
}

bucket = "bucket"

file_cases = %{
  "w_100/test.jpg" => "/resize?extend=white&file=#{bucket}/origin/test.jpg&width=100",
  "w_100,q_80/test.jpg" =>
    "/resize?extend=white&file=#{bucket}/origin/test.jpg&quality=80&width=100",
  "w_100,q_80,c_scale/test.jpg" =>
    "/resize?extend=white&file=#{bucket}/origin/test.jpg&quality=80&width=100",
  "q_80,w_100/test.jpg" =>
    "/resize?extend=white&file=#{bucket}/origin/test.jpg&quality=80&width=100",
  "c_fit,q_80,w_100/test.jpg" =>
    "/fit?extend=white&file=#{bucket}/origin/test.jpg&quality=80&width=100",
  "c_fit,q_80,w_100,b_black/test.jpg" =>
    "/fit?extend=black&file=#{bucket}/origin/test.jpg&quality=80&width=100",
  "c_fit,c_scale,q_80,w_100,b_black/test.jpg" =>
    "/resize?extend=black&file=#{bucket}/origin/test.jpg&quality=80&width=100",
  "c_scale,c_fit,q_80,w_100,b_black/test.jpg" =>
    "/fit?extend=black&file=#{bucket}/origin/test.jpg&quality=80&width=100",
  "c_scale,c_fit,q_80,w_100,b_black,xxx/test.jpg" =>
    "/fit?extend=black&file=#{bucket}/origin/test.jpg&quality=80&width=100"
}

defmodule BuzzcmsWeb.ImaginaryParamsTest do
  use BuzzcmsWeb.ConnCase
  import BuzzcmsWeb.ImageParser

  describe "to normalized transform" do
    Enum.each(transform_cases, fn {input, expected_output} ->
      test "#{input}" do
        transform = unquote(input) |> to_map |> to_transform()
        assert transform == unquote(expected_output)
      end
    end)
  end

  describe "to imaginary request url" do
    Enum.each(file_cases, fn {input, expected_output} ->
      test "#{input}" do
        [unordered_transform, id] = String.split(unquote(input), "/")
        map = to_map(unordered_transform)
        request_url = to_request_url(%{map: map, bucket: unquote(bucket), id: id})

        assert request_url |> URI.decode() ==
                 "http://imaginary:9000#{unquote(expected_output)}" |> URI.decode()
      end
    end)
  end
end
