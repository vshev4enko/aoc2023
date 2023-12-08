defmodule Aoc2023.Day3 do
  @file_path "./input/day3"

  def part1 do
    {symbols, numbers, _} = parse_data()

    symbols
    |> Enum.map(&find_around(&1, numbers))
    |> List.flatten()
    |> Enum.sum()
  end

  def part2 do
    {symbols, numbers, _} = parse_data()

    for %{symbol: s} = symbol <- symbols, s == "*" do
      find_around(symbol, numbers)
    end
    |> Enum.filter(&(length(&1) == 2))
    |> Enum.map(fn [f, s] -> f * s end)
    |> Enum.sum()
  end

  defp find_around(symbol, numbers) do
    %{x_pos: x_pos, y_pos: y_pos} = symbol

    from_y = max(y_pos - 1, 0)
    from_x = max(x_pos - 1, 0)

    to_y = y_pos + 1
    to_x = x_pos + 1

    Enum.reduce(from_y..to_y, [], fn y_pos, acc ->
      Enum.reduce(from_x..to_x, acc, fn x_pos, acc ->
        case get_in(numbers, [y_pos, x_pos]) do
          nil -> acc
          num -> [num | acc]
        end
      end)
    end)
    |> Enum.uniq()
  end

  defp is_symbol("." <> _), do: false
  defp is_symbol(str), do: not is_num(str)

  defp is_num(str) do
    case Integer.parse(str) do
      {_int, ""} -> true
      :error -> false
    end
  end

  defp parse_data do
    @file_path
    |> File.stream!()
    |> Stream.map(fn line -> String.replace(line, "\n", "") end)
    |> Stream.map(fn line -> Regex.scan(~r/(?:\.+|\d+|\D)/, line) |> List.flatten() end)
    |> Stream.with_index()
    |> Enum.reduce({[], %{}, 0}, fn {row, y_index}, acc ->
      row
      |> Enum.with_index()
      |> Enum.reduce(acc, fn {item, x_index}, {symbols, numbers, x_pos} ->
        x_pos = (x_index == 0 && 0) || x_pos

        size = byte_size(item)

        next_x_pos = x_pos + size

        cond do
          is_symbol(item) ->
            symbols = [%{symbol: item, x_pos: x_pos, y_pos: y_index} | symbols]
            {symbols, numbers, next_x_pos}

          is_num(item) ->
            numbers =
              Enum.reduce(x_pos..(x_pos + size - 1), numbers, fn x_pos, acc ->
                num = String.to_integer(item)

                Map.update(acc, y_index, %{x_pos => num}, fn existing ->
                  Map.put(existing, x_pos, num)
                end)
              end)

            {symbols, numbers, next_x_pos}

          true ->
            {symbols, numbers, next_x_pos}
        end
      end)
    end)
  end
end
