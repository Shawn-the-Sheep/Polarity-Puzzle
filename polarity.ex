defmodule Remove do
  def removeFirstLast(list), do: removeFirstLast(list, [], 0, length(list))
  defp removeFirstLast([], acc, _, _), do: acc
  defp removeFirstLast([_ | t], acc, index, len) when index == 0 or index == len - 1, do: removeFirstLast(t, acc, index + 1, len)
  defp removeFirstLast([h | t], acc, index, len) when not (index == 0 or index == len - 1), do: removeFirstLast(t, acc ++ [h], index + 1, len)
end

defmodule Convert do
  def convertNestedLists(tup), do: convertNestedLists(Tuple.to_list(tup), [])
  defp convertNestedLists([], acc), do: acc
  defp convertNestedLists([h | t], acc) do
    next_entry = h |> String.split("") |> Remove.removeFirstLast()
    convertNestedLists(t, acc ++ [next_entry])
  end

  def convertStrTup(list), do: convertStrTup(list, [])
  defp convertStrTup([], acc), do: List.to_tuple(acc)
  defp convertStrTup([h | t], acc), do: convertStrTup(t, acc ++ [to_string(h)])
end

defmodule Polarity do
  def polarity(board, specs), do: polarity(Convert.convertNestedLists(board), specs, Convert.convertNestedLists(board), length(Convert.convertNestedLists(board)), length(Enum.at(Convert.convertNestedLists(board), 0)), 0, 0)
  defp polarity(_, _, sol, num_rows, num_cols, i, j) when i == num_rows - 1 and j == num_cols - 1, do: Convert.convertStrTup(sol)
  defp polarity(board, specs, sol, num_rows, num_cols, i, j) do
    curr_row = Enum.at(board, i)
    curr_elem = Enum.at(curr_row, j)

    cond do
      curr_elem == "L" ->
        (
          new_row = List.replace_at(Enum.at(sol, i), j, "+")
          new_row = List.replace_at(new_row, j + 1, "-")
          new_sol = List.replace_at(sol, i, new_row)
          returned_sol = if validPartial?(new_sol, specs, i, j) do
            polarity(board, specs, new_sol, num_rows, num_cols, i, j + 1)
          else
            nil
          end
          if returned_sol != nil do
            returned_sol
          else
            new_row = List.replace_at(Enum.at(sol, i), j, "-")
            new_row = List.replace_at(new_row, j + 1, "+")
            new_sol = List.replace_at(sol, i, new_row)
            returned_sol = if validPartial?(new_sol, specs, i, j) do
              polarity(board, specs, new_sol, num_rows, num_cols, i, j + 1)
            else
              nil
            end
            if returned_sol != nil do
              returned_sol
            else
              new_row = List.replace_at(Enum.at(sol, i), j, "X")
              new_row = List.replace_at(new_row, j + 1, "X")
              new_sol = List.replace_at(sol, i, new_row)
              returned_sol = if validPartial?(new_sol, specs, i, j) do
                polarity(board, specs, new_sol, num_rows, num_cols, i, j + 1)
              else
                nil
              end
            end
          end
        )
      curr_elem == "T" ->
        (
          new_row1 = List.replace_at(Enum.at(sol, i), j, "+")
          new_row2 = List.replace_at(Enum.at(sol, i + 1), j, "-")
          new_sol = List.replace_at(sol, i, new_row1)
          new_sol = List.replace_at(new_sol, i + 1, new_row2)
          returned_sol = if validPartial?(new_sol, specs, i, j) do
            if j < length(Enum.at(board, 0)) - 1 do
              polarity(board, specs, new_sol, num_rows, num_cols, i, j + 1)
            else
              polarity(board, specs, new_sol, num_rows, num_cols, i + 1, 0)
            end
          else
            nil
          end
          if returned_sol != nil do
            returned_sol
          else
            new_row1 = List.replace_at(Enum.at(sol, i), j, "-")
            new_row2 = List.replace_at(Enum.at(sol, i + 1), j, "+")
            new_sol = List.replace_at(sol, i, new_row1)
            new_sol = List.replace_at(new_sol, i + 1, new_row2)
            returned_sol = if validPartial?(new_sol, specs, i, j) do
              if j < length(Enum.at(board, 0)) - 1 do
                polarity(board, specs, new_sol, num_rows, num_cols, i, j + 1)
              else
                polarity(board, specs, new_sol, num_rows, num_cols, i + 1, 0)
              end
            else
              nil
            end
            if returned_sol != nil do
              returned_sol
            else
              new_row1 = List.replace_at(Enum.at(sol, i), j, "X")
              new_row2 = List.replace_at(Enum.at(sol, i + 1), j, "X")
              new_sol = List.replace_at(sol, i, new_row1)
              new_sol = List.replace_at(new_sol, i + 1, new_row2)
              returned_sol = if validPartial?(new_sol, specs, i, j) do
                if j < length(Enum.at(board, 0)) - 1 do
                  polarity(board, specs, new_sol, num_rows, num_cols, i, j + 1)
                else
                  polarity(board, specs, new_sol, num_rows, num_cols, i + 1, 0)
                end
              else
                nil
              end
            end
          end
        )
      true ->
        (
          if j < length(Enum.at(board, 0)) - 1 do
            if validPartial?(sol, specs, i, j) do
              polarity(board, specs, sol, num_rows, num_cols, i, j + 1)
            end
          else
            if validPartial?(sol, specs, i, j) do
              polarity(board, specs, sol, num_rows, num_cols, i + 1, 0)
            end
          end
        )
    end
  end

  # New function to check for adjacent identical poles
  defp no_adjacent_identical_poles?(partial_sol) do
    num_rows = length(partial_sol)
    num_cols = length(Enum.at(partial_sol, 0))
    Enum.all?(0..num_rows-1, fn row ->
      Enum.all?(0..num_cols-1, fn col ->
        curr = Enum.at(Enum.at(partial_sol, row), col)
        if curr in ["+", "-"] do
          right_valid = col >= num_cols - 1 or Enum.at(Enum.at(partial_sol, row), col + 1) != curr
          below_valid = row >= num_rows - 1 or Enum.at(Enum.at(partial_sol, row + 1), col) != curr
          right_valid and below_valid
        else
          true
        end
      end)
    end)
  end

  defp validPartial?(partial_sol, specs, i, j) do
    # Row checks
    left_specs  = Map.get(specs, "left")    # expected positives per row
    right_specs = Map.get(specs, "right")   # expected negatives per row
    curr_row = Enum.at(partial_sol, i)
    expected_num_positive = elem(left_specs, i)
    expected_num_negative = elem(right_specs, i)
    {num_pos, num_neg} = determineNumPos(curr_row)
    row_complete = j == length(Enum.at(partial_sol, 0)) - 1
    row_valid? =
      if row_complete do
        (expected_num_positive == -1 or num_pos == expected_num_positive) and
          (expected_num_negative == -1 or num_neg == expected_num_negative)
      else
        (expected_num_positive == -1 or num_pos <= expected_num_positive) and
          (expected_num_negative == -1 or num_neg <= expected_num_negative)
      end

    # Column checks
    top_specs    = Map.get(specs, "top")      # expected positives per column
    bottom_specs = Map.get(specs, "bottom")   # expected negatives per column
    curr_column = getColumn(partial_sol, j)
    expected_num_positive_col = elem(top_specs, j)
    expected_num_negative_col = elem(bottom_specs, j)  # Note: 'custom_specs' seems to be a typo; should be 'bottom_specs'
    {col_num_pos, col_num_neg} = determineNumPos(curr_column)
    col_complete = i == length(partial_sol) - 1
    col_valid? = 
      if col_complete do
        (expected_num_positive_col == -1 or col_num_pos == expected_num_positive_col) and
          (expected_num_negative_col == -1 or col_num_neg == expected_num_negative_col)
      else
        (expected_num_positive_col == -1 or col_num_pos <= expected_num_positive_col) and
          (expected_num_negative_col == -1 or col_num_neg <= expected_num_negative_col)
      end

    # Combine all checks, including the new adjacency check
    row_valid? and col_valid? and no_adjacent_identical_poles?(partial_sol)
  end

  defp getColumn(partial_sol, j), do: getColumn(partial_sol, j, [])
  defp getColumn([], _, column), do: column
  defp getColumn([h | t], j, column) do
    curr_elem = Enum.at(h, j)
    new_column = column ++ [curr_elem]
    getColumn(t, j, new_column)
  end

  defp determineNumPos(row), do: determineNumPos(row, 0, 0)
  defp determineNumPos([], num_pos, num_neg), do: {num_pos, num_neg}
  defp determineNumPos([h | t], num_pos, num_neg) when h == "+", do: determineNumPos(t, num_pos + 1, num_neg)
  defp determineNumPos([h | t], num_pos, num_neg) when h == "-", do: determineNumPos(t, num_pos, num_neg + 1)
  defp determineNumPos([h | t], num_pos, num_neg) when not (h == "+" or h == "-"), do: determineNumPos(t, num_pos, num_neg)
end

