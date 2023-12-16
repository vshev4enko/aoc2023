defmodule Aoc2023.Day8 do
  @behaviour Aoc2023

  @impl true
  def part1({instructions, network}) do
    do_walk(network, "AAA", instructions, &match?("ZZZ", &1))
  end

  @impl true
  def part2({instructions, network}) do
    starting_positions = network |> Map.keys() |> Enum.filter(&String.ends_with?(&1, "A"))

    halt_fun = fn
      <<_::size(16), "Z">> -> true
      _ -> false
    end

    starting_positions
    |> Enum.map(&do_walk(network, &1, instructions, halt_fun))
    |> Enum.sort()
    |> Enum.reduce(fn current, previous ->
      2
      |> Stream.iterate(&(&1 + 1))
      |> Enum.reduce_while(current, fn i, acc ->
        if rem(acc, previous) == 0 do
          {:halt, acc}
        else
          {:cont, current * i}
        end
      end)
    end)
  end

  defp do_walk(network, position, instructions, halt_fun) do
    1
    |> Stream.iterate(&(&1 + 1))
    |> Enum.reduce_while({position, instructions}, fn step, {position, rem_instructions} ->
      [instruction | rem_instructions] =
        (Enum.empty?(rem_instructions) && instructions) || rem_instructions

      next_position = get_in(network, [position, instruction])

      if halt_fun.(next_position) do
        {:halt, step}
      else
        {:cont, {next_position, rem_instructions}}
      end
    end)
  end

  @impl true
  def parse_data(path) do
    [instructions, lines] =
      path
      |> File.read!()
      |> String.split("\n\n")

    network =
      lines
      |> String.split("\n")
      |> Map.new(fn line ->
        [key, pair] = String.split(line, " = ")
        [left, right] = pair |> String.replace(["(", ")"], "") |> String.split(", ")
        {key, %{"L" => left, "R" => right}}
      end)

    {String.split(instructions, "", trim: true), network}
  end
end
