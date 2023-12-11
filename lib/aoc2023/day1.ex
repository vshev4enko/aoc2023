defmodule Aoc2023.Day1 do
  @behaviour Aoc2023

  @impl true
  def part1(path) do
    path
    |> File.stream!()
    |> Stream.map(fn str -> Regex.replace(~r/\D+/, str, "") end)
    |> Stream.map(fn dig ->
      byte_size = byte_size(dig)

      cond do
        byte_size == 1 -> String.duplicate(dig, 2)
        byte_size == 2 -> dig
        true -> String.at(dig, 0) <> String.at(dig, byte_size - 1)
      end
    end)
    |> Stream.map(fn dig -> String.to_integer(dig) end)
    |> Enum.sum()
  end

  @impl true
  def part2(path) do
    path
    |> File.stream!()
    |> Stream.map(fn line -> line |> String.replace("\n", "") |> String.split("", trim: true) end)
    |> Stream.map(fn row ->
      first = Enum.reduce_while(row, "", &reduce_beginning/2)
      last = Enum.reduce_while(Enum.reverse(row), "", &reduce_ending/2)
      [first, last]
    end)
    |> Stream.map(fn row -> Enum.map(row, &resolve/1) end)
    |> Stream.map(fn dig -> List.first(dig) <> List.last(dig) end)
    |> Stream.map(fn dig -> String.to_integer(dig) end)
    |> Enum.sum()
  end

  defp reduce_beginning(char, line) do
    match(line <> char)
  end

  defp reduce_ending(char, line) do
    match(char <> line)
  end

  @expression ~r/(?:one|two|three|four|five|six|seven|eight|nine|\d)/

  defp match(line) do
    case Regex.run(@expression, line) do
      nil -> {:cont, line}
      [match] -> {:halt, match}
    end
  end

  defp resolve("one"), do: "1"
  defp resolve("two"), do: "2"
  defp resolve("three"), do: "3"
  defp resolve("four"), do: "4"
  defp resolve("five"), do: "5"
  defp resolve("six"), do: "6"
  defp resolve("seven"), do: "7"
  defp resolve("eight"), do: "8"
  defp resolve("nine"), do: "9"
  defp resolve(number), do: number

  @impl true
  def parse_data(path) do
    path
  end
end
