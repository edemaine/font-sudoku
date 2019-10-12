{Sudoku} = require './sudoku.coffee'
{font} = require './font.coffee'

generate = (letter) ->
  sudoku = new Sudoku font[letter]
  solver = sudoku.clone()
  solver.prune = ->
    bad = false
    for [i1, j1] from sudoku.filledCells()
      for [i2, j2] from sudoku.neighboringCells i1, j1
        if sudoku.cell[i2][j2] == 0 # transition between blank and filled in input
          if solver.cell[i2][j2] != 0 and 1 == Math.abs solver.cell[i1][j1] - solver.cell[i2][j2]
            console.log "#{solver}"
            console.log i1, j1, i2, j2
            return true
    false
  for solution from solver.solutions()
    console.log JSON.stringify solution.cell
    console.log "#{solution}"

if module? and module == require?.main
  for letter of font
    if process.argv.length > 2
      continue unless letter in process.argv
    #continue if letter in ['D', 'M', 'N', 'Q', 'W']
    console.log "# #{letter}"
    generate letter
