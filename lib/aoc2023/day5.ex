defmodule Aoc2023.Day5 do
  @behaviour Aoc2023

  @path ~w(seed-to-soil soil-to-fertilizer fertilizer-to-water water-to-light light-to-temperature temperature-to-humidity humidity-to-location)a

  @impl true
  def part1(data) do
    data.seeds
    |> Enum.map(fn seed ->
      Enum.reduce(@path, seed, fn key, seed ->
        data |> Map.get(key) |> translate_number(seed) || seed
      end)
    end)
    |> Enum.min()
  end

  defp translate_number(mappers, number) do
    with {src, dst} <- Enum.find(mappers, fn {src, _dst} -> number in src end) do
      dst.first + (number - src.first)
    end
  end

  @impl true
  def part2(data) do
    ranges =
      data.seeds
      |> Enum.chunk_every(2)
      |> Enum.map(fn [from, len] -> from..(from + len - 1) end)

    @path
    |> Enum.reduce(ranges, &translate_ranges(Map.fetch!(data, &1), &2))
    |> Enum.min_by(& &1.first)
    |> Map.get(:first)
  end

  defp translate_ranges(mappers, ranges) do
    Enum.flat_map_reduce(mappers, ranges, fn {source, _} = mapper, rest_ranges ->
      {covered_ranges, rest_ranges} = split_ranges(rest_ranges, source)
      {Enum.map(covered_ranges, &translate_range(&1, mapper)), rest_ranges}
    end)
    |> then(fn {l1, l2} -> l1 ++ l2 end)
  end

  defp split_ranges(ranges, source) do
    split_ranges(ranges, source, {[], []})
  end

  defp split_ranges([range | ranges], source, {covered_ranges, rest_ranges}) do
    case split_range(range, source) do
      {nil, rest} ->
        split_ranges(ranges, source, {covered_ranges, rest ++ rest_ranges})

      {covered, nil} ->
        split_ranges(ranges, source, {covered ++ covered_ranges, rest_ranges})

      {covered, rest} ->
        split_ranges(ranges, source, {covered ++ covered_ranges, rest ++ rest_ranges})
    end
  end

  defp split_ranges([], _source, acc), do: acc

  defp split_range(_ra..rz = range, sa.._sz) when rz < sa do
    {nil, [range]}
  end

  defp split_range(ra.._rz = range, _sa..sz) when ra > sz do
    {nil, [range]}
  end

  defp split_range(ra..rz = range, sa..sz) when ra >= sa and rz <= sz do
    {[range], nil}
  end

  defp split_range(ra..rz, sa..sz) when sa >= ra and sz >= rz do
    {[sa..rz], [ra..(sa - 1)]}
  end

  defp split_range(ra..rz, sa..sz) when sa <= ra and sz <= rz do
    {[ra..sz], [(sz + 1)..rz]}
  end

  defp split_range(ra..rz, sa..sz) when sa >= ra and sz <= rz do
    {[sa..sz], [ra..(sa - 1), (sz + 1)..rz]}
  end

  defp translate_range(range, {source, dest}) do
    diff = dest.first - source.first
    Range.shift(range, diff)
  end

  @impl true
  def parse_data(path) do
    path
    |> File.read!()
    |> String.split("\n\n")
    |> Map.new(fn line ->
      case String.split(line, ":") do
        ["seeds", line] ->
          {:seeds, parse_numbers(line)}

        [key, line] ->
          {key |> String.replace(" map", "") |> String.to_atom(), parse_ranges(line)}
      end
    end)
  end

  defp parse_numbers(line) do
    line
    |> String.split(" ", trim: true)
    |> Enum.map(&String.to_integer/1)
  end

  defp parse_ranges(lines) do
    lines |> String.split("\n", trim: true) |> Enum.map(&parse_range/1)
  end

  defp parse_range(line) do
    [dst, src, len] = parse_numbers(line)
    {src..(src + len - 1), dst..(dst + len - 1)}
  end
end
