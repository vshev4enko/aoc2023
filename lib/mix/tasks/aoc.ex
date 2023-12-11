defmodule Mix.Tasks.Aoc do
  use Mix.Task

  @shortdoc "Executes the challenge"

  @aliases [
    d: :day,
    p: :part
  ]

  @switches [
    day: :string,
    part: :string,
    test: :boolean
  ]

  @moduledoc """
  Executes advent of code solution.

  ## Examples

      $ mix aoc --day 1 --part 1

  This command will execute `Aoc2023.Day1.part1/0` function.
  """

  @impl true
  def run(args) do
    {opts, _} = OptionParser.parse!(args, strict: @switches, aliases: @aliases)

    day = opts[:day] || Mix.raise("mix aoc expects the day to be given as -d 1")
    part = opts[:part] || Mix.raise("mix aoc expects the part to be given as -p 1")

    module = Module.concat([Aoc2023, :"Day#{day}"])

    path = (opts[:test] && "./input/test#{day}") || "./input/day#{day}"

    apply(module, :"part#{part}", [apply(module, :parse_data, [path])])
    |> IO.inspect(label: "result")
  end
end
