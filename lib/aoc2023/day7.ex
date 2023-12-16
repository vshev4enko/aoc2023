defmodule Aoc2023.Day7 do
  @behaviour Aoc2023

  @p1_weights %{
    "A" => 14,
    "K" => 13,
    "Q" => 12,
    "J" => 11,
    "T" => 10,
    "9" => 9,
    "8" => 8,
    "7" => 7,
    "6" => 6,
    "5" => 5,
    "4" => 4,
    "3" => 3,
    "2" => 2
  }

  @impl true
  def part1(data) do
    data
    |> Enum.map(fn {cards, frequencies, bid} ->
      weight = frequencies |> Keyword.values() |> weight()
      {cards, weight, bid}
    end)
    |> Enum.sort_by(& &1, &sorter(&1, &2, @p1_weights))
    |> Enum.with_index(1)
    |> Enum.map(fn {{_, _, bid}, id} -> bid * id end)
    |> Enum.sum()
  end

  @p2_weights %{
    "A" => 14,
    "K" => 13,
    "Q" => 12,
    "T" => 10,
    "9" => 9,
    "8" => 8,
    "7" => 7,
    "6" => 6,
    "5" => 5,
    "4" => 4,
    "3" => 3,
    "2" => 2,
    "J" => 1
  }

  @impl true
  def part2(data) do
    data
    |> Enum.map(fn {cards, frequencies, bid} ->
      jokers = :proplists.get_value("J", frequencies, 0)
      frequencies = :proplists.delete("J", frequencies)

      weight =
        case Keyword.values(frequencies) do
          [h | t] -> weight([h + jokers | t])
          [] -> weight([jokers])
        end

      {cards, weight, bid}
    end)
    |> Enum.sort_by(& &1, &sorter(&1, &2, @p2_weights))
    |> Enum.with_index(1)
    |> Enum.map(fn {{_, _, bid}, id} -> bid * id end)
    |> Enum.sum()
  end

  defp sorter({l_hand, weight, _}, {r_hand, weight, _}, weights) do
    Enum.zip(l_hand, r_hand)
    |> Enum.reduce_while(false, fn
      {card, card}, acc ->
        {:cont, acc}

      {l_card, r_card}, _acc ->
        {:halt, weights[l_card] < weights[r_card]}
    end)
  end

  defp sorter({_, l_weight, _}, {_, r_weight, _}, _weights) do
    l_weight < r_weight
  end

  # Five of a kind
  defp weight([5]), do: 6
  # Four of a kind
  defp weight([4, 1]), do: 5
  # Full house
  defp weight([3, 2]), do: 4
  # Three of a kind
  defp weight([3, 1, 1]), do: 3
  # Two pair
  defp weight([2, 2, 1]), do: 2
  # One pair
  defp weight([2, 1, 1, 1]), do: 1
  # High card
  defp weight([1, 1, 1, 1, 1]), do: 0

  @impl true
  def parse_data(path) do
    path
    |> File.read!()
    |> String.split("\n")
    |> Enum.map(fn pair ->
      [cards, bid] = String.split(pair, " ")

      cards =
        cards
        |> String.split("", trim: true)
        |> Enum.to_list()

      frequencies =
        cards
        |> Enum.frequencies()
        |> Enum.to_list()
        |> Enum.sort_by(&elem(&1, 1), :desc)

      {cards, frequencies, String.to_integer(bid)}
    end)
  end
end
