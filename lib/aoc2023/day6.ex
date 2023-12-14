defmodule Aoc2023.Day6 do
  @behaviour Aoc2023

  @impl true
  def part1(lines) do
    numbers =
      lines
      |> Enum.into([], fn line ->
        line |> String.split(":") |> Enum.at(1) |> parse_numbers()
      end)
      |> List.zip()

    numbers
    |> Enum.into([], fn {time, distance} ->
      ways_to_win(time, distance)
    end)
    |> Enum.product()
  end

  @impl true
  def part2(lines) do
    [time, distance] =
      Enum.into(lines, [], fn line ->
        line
        |> String.split(":")
        |> Enum.at(1)
        |> String.replace(" ", "")
        |> String.to_integer()
      end)

    ways_to_win(time, distance)
  end

  defp ways_to_win(time, record_distance) do
    1..(time - 1)
    |> Enum.reduce(0, fn speed, acc ->
      distance = speed * (time - speed)

      if distance > record_distance do
        acc + 1
      else
        acc
      end
    end)
  end

  @impl true
  def parse_data(path) do
    path
    |> File.read!()
    |> String.split("\n")
  end

  defp parse_numbers(line) do
    line
    |> String.split(" ", trim: true)
    |> Enum.map(&String.to_integer/1)
  end
end
