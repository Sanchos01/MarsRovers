defmodule MarsRoversTest do
  use ExUnit.Case
  doctest MarsRovers

  test "first" do
    # 5 5
    # 1 2 N
    # LMLMLMLMM
    # 3 3 E
    # MMRMMRMRRM
    assert "\"1 3 N\"\n\n\"5 1 E\"" == MarsRovers.start("test/first.txt")
  end

  test "second" do
    # 5 5
    # 3 0 N
    # MMRMLMRM
    # 5 0 N
    # MMLMRMLM
    assert "\"5 3 E\"\n\n\"3 3 W\"" == MarsRovers.start("test/second.txt")
  end

  test "blocked_path" do
    # 5 5
    # 3 0 E
    # MMMM
    # 5 0 N
    # LRLR
    assert "{:error, :path_blocked, {4, 0, \"E\"}}\n\n\"5 0 N\"" == MarsRovers.start("test/blocked_path.txt")
  end

  test "wrong position" do
    # 5 5
    # 6 1 E
    # MRMMLM
    # 4 2 W
    # MRMMRL
    assert "{:error, :out_of_plateau, {6, 1, \"E\"}}\n\n\"3 4 N\"" == MarsRovers.start("test/wrong_position.txt")
  end
end
