defmodule Aoc2023.Utils do
  @doc """
  Utility functions.
  """

  def debug(%{} = stream, opts) do
    Stream.map(stream, fn data -> IO.inspect(data, opts) end)
  end
end
