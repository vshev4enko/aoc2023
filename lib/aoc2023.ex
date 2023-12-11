defmodule Aoc2023 do
  @moduledoc """
  Documentation for `Aoc2023`.
  """

  @callback part1(data :: term()) :: number()
  @callback part2(data :: term()) :: number()
  @callback parse_data(path :: String.t()) :: term()
end
