{Sudoku} = require './sudoku'
{font} = require './font'

generate = (letter) ->
  sudoku = new Sudoku font[letter]
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
      console.log JSON.stringify solution.cell
      console.log "#{solution}"
      break

if module? and module == require?.main
  loop
    for letter of font
      if process.argv.length > 2
        continue unless letter in process.argv
      #continue if letter in ['D', 'M', 'N', 'Q', 'W']
      console.log "# #{letter}"
      generate letter
