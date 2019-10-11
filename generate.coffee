{Sudoku} = require './sudoku'
{font} = require './font'

for letter, array of font
  continue if letter in ['D', 'M', 'N', 'Q', 'W']
  console.log "#{letter}"
  sudoku = new Sudoku array
  bad = true
  while bad
    solution = sudoku.clone().solve()
    bad = false
    for [i1, j1] from sudoku.filledCells()
      for [i2, j2] from sudoku.neighboringCells i1, j1
        if sudoku.cell[i2][j2] == 0 # transition between blank and filled in input
          if 1 == Math.abs solution.cell[i1][j1] - solution.cell[i2][j2]
            bad = true
            break
      break if bad
    unless bad
      console.log "#{solution}"
      break
