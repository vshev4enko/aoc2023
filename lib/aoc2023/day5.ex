defmodule Aoc2023.Day5 do
  @behaviour Aoc2023

  @impl true
  def part1(data) do
    data
    |> Map.get("seeds")
    |> Enum.map(fn seed ->
      soil = data |> Map.get("seed-to-soil") |> find_value(seed)
      fertilizer = data |> Map.get("soil-to-fertilizer") |> find_value(soil)
      water = data |> Map.get("fertilizer-to-water") |> find_value(fertilizer)
      light = data |> Map.get("water-to-light") |> find_value(water)
      temperature = data |> Map.get("light-to-temperature") |> find_value(light)
      humidity = data |> Map.get("temperature-to-humidity") |> find_value(temperature)
      data |> Map.get("humidity-to-location") |> find_value(humidity)
    end)
    |> Enum.min()
  end

  @parts 10

  @impl true
  def part2(data) do
    data
    |> Map.get("seeds")
    |> Stream.chunk_every(2)
    |> Stream.flat_map(fn [from, count] ->
      remainder = rem(count, @parts)
      part_amount = div(count - remainder, @parts)

      {acc, max} =
        Enum.reduce(1..@parts, {[], from}, fn _, {acc, max} ->
          {[[max, part_amount] | acc], max + part_amount}
        end)

      [[max, remainder] | acc]
    end)
    |> Task.async_stream(
      fn [from, count] ->
        Enum.reduce(from..(from + count - 1), nil, fn seed, min ->
          soil = data |> Map.get("seed-to-soil") |> find_value(seed)
          fertilizer = data |> Map.get("soil-to-fertilizer") |> find_value(soil)
          water = data |> Map.get("fertilizer-to-water") |> find_value(fertilizer)
          light = data |> Map.get("water-to-light") |> find_value(water)
          temperature = data |> Map.get("light-to-temperature") |> find_value(light)
          humidity = data |> Map.get("temperature-to-humidity") |> find_value(temperature)
          location = data |> Map.get("humidity-to-location") |> find_value(humidity)
          (min && min(min, location)) || location
        end)
      end,
      ordered: false,
      timeout: :infinity
    )
    |> Enum.min_by(&elem(&1, 1))
  end

  defp find_value(mapping, key) do
    with {src, dst, len} <- Enum.find(mapping, fn {src, _, _} -> src <= key end),
         true <- src + len > key do
      dst + (key - src)
    else
      _ -> key
    end
  end

  @impl true
  def parse_data(path) do
    path
    |> File.stream!()
    |> Stream.map(fn line -> String.replace(line, "\n", "") end)
    |> Stream.reject(fn line -> line == "" end)
    |> Enum.reduce({%{}, nil}, fn line, {acc, last_key} ->
      {key, data} =
        case String.split(line, " ") do
          ["seeds:" | seeds] ->
            {"seeds", Enum.map(seeds, &String.to_integer/1)}

          [key, "map:"] ->
            {key, []}

          numbers ->
            [dst, src, len] = Enum.map(numbers, &String.to_integer/1)
            {last_key, [{src, dst, len}]}
        end

      {Map.update(acc, key, data, fn existing -> data ++ existing end), key}
    end)
    |> elem(0)
    |> Enum.into(%{}, fn {key, value} ->
      if key == "seeds" do
        {key, value}
      else
        {key, Enum.sort_by(value, fn {src, _dst, _len} -> src end, :desc)}
      end
    end)
  end
end
