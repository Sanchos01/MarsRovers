defmodule MarsRovers.FileParse do
  alias MarsRovers.State.{Movement, Position, Plateau}
  alias MarsRovers.State

  def format_and_validate(file) do
    lines = String.split(file, "\n")
      |> Enum.reduce([], fn line, acc ->
        case Regex.run(~r/[^#.]*/, line)
              |> hd()
              |> String.trim("\r")
              |> String.trim(" ")
              |> String.split(" ") do
          [""] -> acc
          some -> [some | acc]
        end
      end)
      |> Enum.reverse()
    with true                    <- length(lines) == 5,
         {:ok, plateau, rest}    <- parse_plateau(lines),
         {:ok, first_pos, rest}  <- parse_pos(rest, plateau),
         {:ok, first_mov, rest}  <- parse_mov(rest),
         {:ok, second_pos, rest} <- parse_pos(rest, plateau),
         {:ok, second_mov, []}   <- parse_mov(rest)
    do
      {:ok, %State{plateau: plateau, first_pos: first_pos, first_mov: first_mov, second_pos: second_pos, second_mov: second_mov}}
    else
      false -> :wrong_format_file
      error -> error
    end
  end

  defp parse_plateau([head | rest]) do
    with true            <- length(head) == 2,
         ^head           <- [x, y] = head,
         {plateau_x, ""} <- Integer.parse(x),
         {plateau_y, ""} <- Integer.parse(y),
         plateau         <- %Plateau{x: plateau_x, y: plateau_y},
         true            <- Plateau.validate(plateau)
    do
      {:ok, plateau, rest}
    else
      _ ->
        IO.puts "some error on plateau parsing"
        :plateau_error
    end
  end

  defp parse_pos([head | rest], plateau) do
    with true        <- length(head) == 3,
         ^head       <- [x, y, f] = head,
         {pos_x, ""} <- Integer.parse(x),
         {pos_y, ""} <- Integer.parse(y),
         pos         <- %Position{x: pos_x, y: pos_y, f: f, error: nil},
         true        <- Position.validate(pos, plateau)
    do
      {:ok, pos, rest}
    else
      {:param, false, pos} -> {:error, pos}
      {:pos, false, pos}   -> {:ok, pos, rest}
      _                    ->
        IO.puts "some error on pos parsing"
        :position_error
    end
  end

  defp parse_mov([head | rest]) do
    with true  <- length(head) == 1,
         ^head <- [commands] = head,
         mov   <- %Movement{commands: commands},
         true  <- Movement.validate(mov)
    do
      {:ok, mov, rest}
    else
      _ ->
        IO.puts "some error on mov parsing"
        :movement_error
    end
  end
end