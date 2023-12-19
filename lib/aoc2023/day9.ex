defmodule Aoc2023.Day9 do
  @behaviour Aoc2023

  @impl true
  def part1(data) do
    data
    |> Enum.map(fn list -> list |> Enum.map(&List.last/1) |> Enum.sum() end)
    |> Enum.sum()
  end

  @impl true
  def part2(data) do
    data
    |> Enum.map(fn list ->
      list
      |> Enum.map(&List.first/1)
      |> Enum.reduce(&Kernel.-(&1, &2))
    end)
    |> Enum.sum()
  end

  @impl true
  def parse_data(path) do
    path
    |> File.read!()
    |> String.split("\n")
    |> Enum.map(fn line -> line |> String.split(" ") |> Enum.map(&String.to_integer/1) end)
    |> Enum.map(fn sequence ->
      0
      |> Stream.iterate(&(&1 + 1))
      |> Enum.reduce_while([sequence], fn _, [sequence | _] = acc ->
        new_sequence = generate_diff(sequence)

        new_acc = [new_sequence | acc]

        if Enum.all?(new_sequence, fn i -> i == 0 end) do
          {:halt, new_acc}
        else
          {:cont, new_acc}
        end
      end)
    end)
  end

  defp generate_diff([_]), do: []

  defp generate_diff([f, s | t]) do
    [s - f | generate_diff([s | t])]
  end
end
