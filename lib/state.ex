defmodule MarsRovers.State do

  defmodule Plateau do
    @enforce_keys ~w(x y)a
    defstruct ~w(x y)a

    def validate(plateau = %Plateau{}), do: is_integer(plateau.x) and is_integer(plateau.y)
    def validate(_), do: false
  end

  defmodule Position do
    @enforce_keys ~w(x y f)a
    defstruct x: 0, y: 0, f: "N", error: nil
    @available_f ~w(N E S W)s

    def validate(pos = %Position{x: x, y: y, f: f}, %{x: plateau_x, y: plateau_y}) do
      with {:param, true} <- {:param, is_integer(x) and is_integer(y) and (f in @available_f)},
           {:pos, true}   <- {:pos, x > 0 and y > 0 and x <= plateau_x and y <= plateau_y}
      do
        true
      else
        {:pos, false} -> {:pos, false, %{pos | error: :cant_land}}
        error         -> error
      end
    end
    def validate(_), do: false
  end

  defmodule Movement do
    @enforce_keys [:commands]
    defstruct [:commands]
    @available_commands ~w(L M R)s

    def validate(%Movement{commands: commands}), do: validate_commands(commands)
    def validate(_), do: false

    defp validate_commands(""), do: true
    defp validate_commands(<<command::bytes-size(1), rest::binary>>) when command in @available_commands do
      validate_commands(rest)
    end
    defp validate_commands(_), do: false
  end

  @enforce_keys ~w(plateau first_pos first_mov second_pos second_mov)a
  defstruct plateau: Plateau.__struct__,
            first_pos: Position.__struct__,
            first_mov: Movement.__struct__,
            second_pos: Position.__struct__,
            second_mov: Movement.__struct__
end