defmodule MarsRovers do
  alias MarsRovers.FileParse
  alias MarsRovers.State
  alias MarsRovers.State.{Movement, Position}

  def start(path \\ "start.txt") do
    with {:ok, file}  <- File.read(path),
         {:ok, state} <- FileParse.format_and_validate(file)
    do
      moving(state)
    else
      some_error -> IO.puts("#{inspect some_error}")
    end
  end

  defp moving(state = %State{plateau: plateau, first_pos: f_pos, first_mov: f_mov, second_pos: s_pos, second_mov: s_mov}) do
    {new_f_pos, new_f_mov} = new_pos_and_mov(plateau, f_pos, f_mov, s_pos)
    {new_s_pos, new_s_mov} = new_pos_and_mov(plateau, s_pos, s_mov, f_pos)
    new_state = %{state | first_pos: new_f_pos, first_mov: new_f_mov, second_pos: new_s_pos, second_mov: new_s_mov}
    case state == new_state do
      false -> moving(new_state)
      true ->
        f_result = result(f_pos)
        s_result = result(s_pos)
        IO.puts("#{inspect f_result}")
        IO.puts("#{inspect s_result}")
        "#{inspect f_result}\n\n#{inspect s_result}"
    end
  end

  defp new_pos_and_mov(_plateau, pos = %{error: :out_of_plateau}, mov, _s_pos), do: {pos, mov}
  defp new_pos_and_mov(_plateau, pos, mov = %{commands: ""}, _s_pos), do: {pos, mov}
  defp new_pos_and_mov(_plateau, %{x: x, y: y, f: "N"}, %{commands: "L" <> rest_mov}, _s_pos), do: {%Position{x: x, y: y, f: "W"}, %Movement{commands: rest_mov}}
  defp new_pos_and_mov(_plateau, %{x: x, y: y, f: "N"}, %{commands: "R" <> rest_mov}, _s_pos), do: {%Position{x: x, y: y, f: "E"}, %Movement{commands: rest_mov}}
  defp new_pos_and_mov(_plateau, %{x: x, y: y, f: "E"}, %{commands: "L" <> rest_mov}, _s_pos), do: {%Position{x: x, y: y, f: "N"}, %Movement{commands: rest_mov}}
  defp new_pos_and_mov(_plateau, %{x: x, y: y, f: "E"}, %{commands: "R" <> rest_mov}, _s_pos), do: {%Position{x: x, y: y, f: "S"}, %Movement{commands: rest_mov}}
  defp new_pos_and_mov(_plateau, %{x: x, y: y, f: "S"}, %{commands: "L" <> rest_mov}, _s_pos), do: {%Position{x: x, y: y, f: "E"}, %Movement{commands: rest_mov}}
  defp new_pos_and_mov(_plateau, %{x: x, y: y, f: "S"}, %{commands: "R" <> rest_mov}, _s_pos), do: {%Position{x: x, y: y, f: "W"}, %Movement{commands: rest_mov}}
  defp new_pos_and_mov(_plateau, %{x: x, y: y, f: "W"}, %{commands: "L" <> rest_mov}, _s_pos), do: {%Position{x: x, y: y, f: "S"}, %Movement{commands: rest_mov}}
  defp new_pos_and_mov(_plateau, %{x: x, y: y, f: "W"}, %{commands: "R" <> rest_mov}, _s_pos), do: {%Position{x: x, y: y, f: "N"}, %Movement{commands: rest_mov}}
  defp new_pos_and_mov(%{y: plateau_y}, pos = %{x: x, y: y, f: "N"}, mov = %{commands: "M" <> rest_mov}, %{x: another_x, y: another_y}) do
    new_y = y + 1
    cond do
      new_y > plateau_y                    -> {%{pos | error: :out_of_plateau}, mov}
      {x, new_y} == {another_x, another_y} -> {%{pos | error: :path_blocked}, mov}
      true                                 -> {%{pos | y: new_y, error: nil}, %{mov | commands: rest_mov}}
    end
  end
  defp new_pos_and_mov(%{x: plateau_x}, pos = %{x: x, y: y, f: "E"}, mov = %{commands: "M" <> rest_mov}, %{x: another_x, y: another_y}) do
    new_x = x + 1
    cond do
      new_x > plateau_x                    -> {%{pos | error: :out_of_plateau}, mov}
      {new_x, y} == {another_x, another_y} -> {%{pos | error: :path_blocked}, mov}
      true                                 -> {%{pos | x: new_x, error: nil}, %{mov | commands: rest_mov}}
    end
  end
  defp new_pos_and_mov(_plateau, pos = %{x: x, y: y, f: "S"}, mov = %{commands: "M" <> rest_mov}, %{x: another_x, y: another_y}) do
    new_y = y - 1
    cond do
      new_y < 0                            -> {%{pos | error: :out_of_plateau}, mov}
      {x, new_y} == {another_x, another_y} -> {%{pos | error: :path_blocked}, mov}
      true                                 -> {%{pos | y: new_y, error: nil}, %{mov | commands: rest_mov}}
    end
  end
  defp new_pos_and_mov(_plateau, pos = %{x: x, y: y, f: "W"}, mov = %{commands: "M" <> rest_mov}, %{x: another_x, y: another_y}) do
    new_x = x - 1
    cond do
      new_x < 0                            -> {%{pos | error: :out_of_plateau}, mov}
      {new_x, y} == {another_x, another_y} -> {%{pos | error: :path_blocked}, mov}
      true                                 -> {%{pos | x: new_x, error: nil}, %{mov | commands: rest_mov}}
    end
  end

  defp result(%{x: x, y: y, f: f, error: nil}), do: "#{x} #{y} #{f}"
  defp result(%{x: x, y: y, f: f, error: error}), do: {:error, error, {x, y, f}}
end
