defmodule MarsRovers do
  alias MarsRovers.FileParse
  alias MarsRovers.State
  alias MarsRovers.State.Movement

  @doc ~S"""
  Start to explore Mars!
  Options: [:stop_on_blocked], if true when stop. Forever.
  ## Examples
      iex> MarsRovers.start("test/fixtures/first.txt", stop_on_blocked: false)
      "\"1 3 N\"\n\n\"5 1 E\""
  """
  def start(path \\ "start.txt", opts \\ []) do
    with {:ok, file}  <- File.read(path),
         {:ok, state} <- FileParse.format_and_validate(file)
    do
      stop_on_blocked = opts[:stop_on_blocked] || false
      moving(state, stop_on_blocked)
    else
      error -> error
    end
  end

  defp moving(state = %State{plateau: plateau, first_pos: f_pos, first_mov: f_mov, second_pos: s_pos, second_mov: s_mov}, stop_on_blocked) do
    {new_f_pos, new_f_mov} = new_pos_and_mov(plateau, f_pos, f_mov, s_pos, s_mov, stop_on_blocked)
    {new_s_pos, new_s_mov} = new_pos_and_mov(plateau, s_pos, s_mov, new_f_pos, new_f_mov, stop_on_blocked)
    new_state = %{state | first_pos: new_f_pos, first_mov: new_f_mov, second_pos: new_s_pos, second_mov: new_s_mov}
    case state == new_state do
      false -> moving(new_state, stop_on_blocked)
      true ->
        f_result = result(f_pos)
        s_result = result(s_pos)
        IO.puts("#{inspect f_result}")
        IO.puts("#{inspect s_result}")
        "#{inspect f_result}\n\n#{inspect s_result}"
    end
  end

  defp new_pos_and_mov(_plateau, pos = %{error: :path_blocked}, mov, _s_pos, _s_mov, true), do: {pos, mov}
  defp new_pos_and_mov(_plateau, pos = %{error: error}, mov, _s_pos, _s_mov, _stop_on_blocked) when not (error in ~w(nil path_blocked)a), do: {pos, mov}
  defp new_pos_and_mov(_plateau, pos, mov = %{commands: ""}, _s_pos, _s_mov, _stop_on_blocked), do: {pos, mov}
  defp new_pos_and_mov(_plateau, pos, mov = %{commands: <<command::bytes-size(1), rest_mov::binary>>}, _s_pos, _s_mov, _stop_on_blocked) when command in ~w(L R), do: {new_pos(pos, mov), %Movement{commands: rest_mov}}
  defp new_pos_and_mov(plateau, pos, mov = %{commands: "M" <> rest_mov}, s_pos = %{x: s_x, y: s_y}, s_mov, _stop_on_blocked) do
    %{x: new_x, y: new_y} = new_pos = new_pos(pos, "M")
    %{x: new_s_x, y: new_s_y} = new_pos(s_pos, s_mov, true)
    cond do
      not_in_plateau(new_pos, plateau)                                           -> {%{pos | error: :out_of_plateau}, mov}
      (new_x == s_x and new_y == s_y) or (new_x == new_s_x and new_y == new_s_y) -> {%{pos | error: :path_blocked}, mov}
      true                                                                       -> {%{new_pos | error: nil}, %{mov | commands: rest_mov}}
    end
  end

  defp new_pos(pos, mov, stop_on_error \\ false)
  defp new_pos(pos = %{error: error}, _mov, true) when error != nil, do: pos
  defp new_pos(pos, %Movement{commands: <<cmd::bytes-size(1), _rest::binary>>}, _), do: new_pos(pos, cmd)
  defp new_pos(pos, %Movement{}, _), do: pos
  defp new_pos(pos = %{f: "N"}, "L", _), do: %{pos | f: "W"}
  defp new_pos(pos = %{f: "N"}, "R", _), do: %{pos | f: "E"}
  defp new_pos(pos = %{f: "E"}, "L", _), do: %{pos | f: "N"}
  defp new_pos(pos = %{f: "E"}, "R", _), do: %{pos | f: "S"}
  defp new_pos(pos = %{f: "S"}, "L", _), do: %{pos | f: "E"}
  defp new_pos(pos = %{f: "S"}, "R", _), do: %{pos | f: "W"}
  defp new_pos(pos = %{f: "W"}, "L", _), do: %{pos | f: "S"}
  defp new_pos(pos = %{f: "W"}, "R", _), do: %{pos | f: "N"}
  defp new_pos(pos = %{y: y, f: "N"}, "M", false), do: %{pos | y: y + 1}
  defp new_pos(pos = %{x: x, f: "E"}, "M", false), do: %{pos | x: x + 1}
  defp new_pos(pos = %{y: y, f: "S"}, "M", false), do: %{pos | y: y - 1}
  defp new_pos(pos = %{x: x, f: "W"}, "M", false), do: %{pos | x: x - 1}

  defp not_in_plateau(%{x: x}, %{x: plateau_x}) when x < 0 or x > plateau_x, do: true
  defp not_in_plateau(%{y: y}, %{y: plateau_y}) when y < 0 or y > plateau_y, do: true
  defp not_in_plateau(_, _), do: false

  defp result(%{x: x, y: y, f: f, error: nil}), do: "#{x} #{y} #{f}"
  defp result(%{x: x, y: y, f: f, error: error}), do: {:error, error, {x, y, f}}
end
