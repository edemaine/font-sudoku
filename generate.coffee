{Sudoku} = require './sudoku.coffee'
{font} = require './font.coffee'

generate = (letter, permissive = false) ->
  ###
  If permissive == false: Find a solution with no extra +-1 connections
  hanging off of letter pixels.
  If permissive == true: Find a solution with no more than single +-1
  connections hanging off of letter pixels, and no such from degree-1 pixels.
  ###
  sudoku = new Sudoku font[letter]
  solver = sudoku.clone()
  solver.prune = ->
    for [i1, j1] from sudoku.filledCells()
      for [i2, j2] from sudoku.neighboringCells i1, j1
        if sudoku.cell[i2][j2] == 0 # transition between blank and filled in input
          if solver.cell[i2][j2] != 0 and 1 == Math.abs solver.cell[i1][j1] - solver.cell[i2][j2]
            return true unless permissive
            # permissive mode:
            degree = 0
            for [i3, j3] from sudoku.neighboringCells i1, j1
              if sudoku.cell[i3][j3] != 0 and 1 == Math.abs sudoku.cell[i1][j1] - sudoku.cell[i3][j3]
                degree++
            return true if degree == 1
            for [i3, j3] from sudoku.neighboringCells i2, j2
              continue if i1 == i3 and j1 == j3
              if solver.cell[i3][j3] != 0 and 1 == Math.abs solver.cell[i2][j2] - solver.cell[i3][j3]
                return true
    false
  count = 0
  for solution from solver.solutions()
    console.log JSON.stringify solution.cell
    console.log "#{solution}"
    count++
  console.log "# #{count} solutions for #{letter}"

if module? and module == require?.main
  for letter of font
    if process.argv.length > 2
      continue unless letter in process.argv
    console.log "# #{letter}"
    generate letter, letter in ['M', 'N', 'Q', 'W']
