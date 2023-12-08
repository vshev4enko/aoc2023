defmodule Aok2023.Day1 do
  @input_path "./input/day1"

  def part1 do
    @input_path
    |> File.stream!()
    |> debug(label: "stage 1")
    |> Stream.map(fn str -> Regex.replace(~r/\D+/, str, "") end)
    |> debug(label: "stage 2")
    |> Stream.map(fn dig ->
      byte_size = byte_size(dig)

      cond do
        byte_size == 1 -> String.duplicate(dig, 2)
        byte_size == 2 -> dig
        true -> String.at(dig, 0) <> String.at(dig, byte_size - 1)
      end
    end)
    |> debug(label: "stage 3")
    |> Stream.map(fn dig -> String.to_integer(dig) end)
    |> debug(label: "stage 4")
    |> Enum.sum()
  end

  @expression ~r/(?:one|two|three|four|five|six|seven|eight|nine|\d)/

  def part2 do
    @input_path
    |> File.stream!()
    |> debug(label: "stage 1")
    |> Stream.map(fn line -> line |> String.replace("\n", "") |> String.split("", trim: true) end)
    |> debug(label: "stage 2")
    |> Stream.map(fn row ->
      first = Enum.reduce_while(row, "", &reduce_beginning/2)
      last = Enum.reduce_while(Enum.reverse(row), "", &reduce_ending/2)
      [first, last]
    end)
    |> debug(label: "stage 3")
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

  defp match(line) do
    case Regex.run(@expression, line) do
      nil -> {:cont, line}
      [match] -> {:halt, match}
    end
  end

  defp debug(stream, opts) do
    Stream.map(stream, fn data -> IO.inspect(data, opts) end)
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
end
