defmodule Aoc2023.Day2 do
  @behaviour Aoc2023

  import Aoc2023.Utils

  @bag_contains %{"red" => 12, "green" => 13, "blue" => 14}

  @impl true
  def part2(path) do
    path
    |> File.stream!()
    |> Stream.map(fn line -> String.replace(line, "\n", "") end)
    |> Stream.map(fn line -> parse_game(line) end)
    # |> debug(label: "stage 2")
    # |> Stream.filter(fn %{rounds: rounds} ->
    #   rounds |> Enum.map(&possible?/1) |> Enum.all?()
    # end)
    |> Stream.map(fn %{rounds: rounds} = data ->
      Map.put(data, :minimal_set, parse_minimal_set(rounds))
    end)
    |> Stream.map(fn %{minimal_set: minimal_set} = data ->
      Map.put(data, :power_of_set, minimal_set |> Map.values() |> Enum.reduce(&(&1 * &2)))
    end)
    |> debug(label: "stage 3")
    |> Stream.map(& &1.power_of_set)
    |> Enum.sum()
  end

  defp parse_game(line) do
    ["Game " <> game_id, game_data] = String.split(line, ": ")

    rounds =
      game_data
      |> String.split("; ")
      |> Enum.map(&parse_round(&1))

    # |> Enum.reduce(%{}, fn round_data, acc -> parse_round(round_data, acc) end)

    %{id: String.to_integer(game_id), rounds: rounds}
  end

  defp parse_round(round_data, acc \\ %{}) do
    round_data
    |> String.split(", ")
    |> Enum.reduce(acc, fn i, acc ->
      [num, color] = String.split(i, " ")
      num = String.to_integer(num)
      Map.update(acc, color, num, &(&1 + num))
    end)
  end

  defp parse_minimal_set(rounds) do
    Enum.reduce(rounds, fn round, acc ->
      Enum.reduce(round, acc, fn {color, amount}, acc ->
        # i |> IO.inspect()
        # acc |> IO.inspect()
        Map.update(acc, color, amount, fn existing -> max(existing, amount) end)
      end)
    end)
  end

  def possible?(subset) do
    Enum.reduce_while(subset, true, fn {color, amount}, acc ->
      max_cubes = Map.get(@bag_contains, color)

      if max_cubes >= amount do
        {:cont, acc}
      else
        {:halt, false}
      end
    end)
  end

  @impl true
  def parse_data(path) do
    path
  end
end
