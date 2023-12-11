defmodule Aoc2023.Day4 do
  @behaviour Aoc2023

  @impl true
  def part1(cards) do
    Enum.reduce(cards, 0, fn card, acc ->
      res =
        case number_of_matching(card) do
          0 -> 0
          1 -> 1
          n -> Enum.reduce(1..(n - 1), 1, fn _, acc -> acc * 2 end)
        end

      res + acc
    end)
  end

  @impl true
  def part2(cards) do
    cards_map = Enum.into(cards, %{}, fn card -> {card.id, card} end)

    Stream.resource(fn -> 0 end, fn n -> {[n + 1], n + 1} end, fn n -> n end)
    |> Enum.reduce_while({0, cards}, fn
      _id, {count, []} ->
        {:halt, count}

      _id, {count, [card | cards]} ->
        count = count + 1
        number_of_matching = number_of_matching(card)

        if number_of_matching == 0 do
          {:cont, {count, cards}}
        else
          card_id = card.id
          copies_ids = Enum.to_list((card_id + 1)..(card_id + number_of_matching))

          copies = Map.take(cards_map, copies_ids) |> Map.values()
          {:cont, {count, copies ++ cards}}
        end
    end)
  end

  defp number_of_matching(card) do
    length(card.having) - length(card.having -- card.winning)
  end

  @impl true
  def parse_data(path) do
    path
    |> File.stream!()
    |> Stream.map(fn line -> String.replace(line, "\n", "") end)
    |> Enum.into([], fn line ->
      ["Card " <> card_id, rest] = String.split(line, ":")
      [winning, having] = String.split(rest, "|")

      decode = fn str ->
        str
        |> String.split(" ", trim: true)
        |> Enum.map(&String.to_integer/1)
      end

      card_id = card_id |> String.trim() |> String.to_integer()
      %{id: card_id, winning: decode.(winning), having: decode.(having)}
    end)
  end
end
