defmodule MarsRoversTest do
  use ExUnit.Case
  doctest MarsRovers

  test "first" do
    # 5 5
    # 1 2 N
    # LMLMLMLMM
    # 3 3 E
    # MMRMMRMRRM
    assert "\"1 3 N\"\n\n\"5 1 E\"" == MarsRovers.start("test/fixtures/first.txt")
  end

  test "second" do
    # 5 5
    # 3 0 N
    # MMRMLMRM
    # 5 0 N
    # MMLMRMLM
    assert "\"5 3 E\"\n\n\"3 3 W\"" == MarsRovers.start("test/fixtures/second.txt")
  end

  test "second with stopping on :path_blocked" do
    # 5 5
    # 3 0 N
    # MMRMLMRM
    # 5 0 N
    # MMLMRMLM
    assert "{:error, :path_blocked, {3, 2, \"E\"}}\n\n\"3 3 W\"" == MarsRovers.start("test/fixtures/second.txt", stop_on_blocked: true)
  end

  test "blocked_path" do
    # 5 5
    # 3 0 E
    # MMMM
    # 5 0 N
    # LRLR
    assert "{:error, :path_blocked, {4, 0, \"E\"}}\n\n\"5 0 N\"" == MarsRovers.start("test/fixtures/blocked_path.txt")
  end

  test "wrong position" do
    # 5 5
    # 6 1 E
    # MRMMLM
    # 4 2 W
    # MRMMRL
    assert "{:error, :cant_land, {6, 1, \"E\"}}\n\n\"3 4 N\"" == MarsRovers.start("test/fixtures/wrong_position.txt")
  end

  test "parse error(wrong pos)" do
    # 5 5
    # 4 1 R
    # MRMLMRML
    # 3 2 C
    # MLMRMLMR
    assert "{:error, :wrong_position, {4, 1, \"R\"}}\n\n{:error, :wrong_position, {3, 2, \"C\"}}" = MarsRovers.start("test/fixtures/wrong_pos.txt")
  end

  test "errors in file" do
    # 5 5 3 - ERROR
    # 3 5 E
    # RLMMLR
    # 4 1 W
    # LMLMMR
    assert :plateau_error == MarsRovers.start("test/fixtures/wrong_file1.txt")
    # 5 5
    # 3 5 E W - ERROR
    # RLMMLR
    # 4 1 W
    # LMLMMR
    assert :position_error == MarsRovers.start("test/fixtures/wrong_file2.txt")
    # 5 5
    # 3 5 E
    # RLMMLR RLM - ERROR
    # 4 1 W
    # LMLMMR
    assert :movement_error == MarsRovers.start("test/fixtures/wrong_file3.txt")
    # 5 5
    # 3 5 E
    # 3 5 E - ERROR
    # RLMMLR
    # 4 1 W
    # LMLMMR
    assert :wrong_format_file == MarsRovers.start("test/fixtures/wrong_file4.txt")
  end
end
