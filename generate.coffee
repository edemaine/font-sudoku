fs = require 'fs'
{Sudoku} = require './sudoku.coffee'
{font} = require './font.coffee'

generate = (letter, mode = 'strict', num) ->
  ###
  In 'strict' mode: Find a solution with no extra +-1 connections
  hanging off of letter pixels.
  In 'permissive' mode: Find a solution with no more than single +-1
  connections hanging off of letter pixels, and there are no such connections
  from degree-1 pixels or their neighbors (thereby guaranteeing longest path).
  In 'longest' mode: Find any solution with unique longest path through the
  letter pixels.  Actually, this is checked in all modes, to make sure there
  isn't some other giant component.

  If num is undefined (default), then generate all solutions exhaustively.
  (Useful for checking whether there is a solution.)  Otherwise, generate the
  specified number randomly, avoiding duplicates.
  ###
  sudoku = new Sudoku font[letter]
  letterLength = sudoku.countFilledCells()
  degree = {}
  for [i1, j1] from sudoku.filledCells()
    degree[[i1,j1]] = 0
    for [i2, j2] from sudoku.neighboringCells i1, j1
      if sudoku.cell[i2][j2] != 0 and 1 == Math.abs sudoku.cell[i1][j1] - sudoku.cell[i2][j2]
        degree[[i1,j1]]++
  solver = sudoku.clone()
  solver.prune = ->
    for [i1, j1] from sudoku.filledCells()
      for [i2, j2] from sudoku.neighboringCells i1, j1
        if sudoku.cell[i2][j2] == 0 # transition between blank and filled in input
          if solver.cell[i2][j2] != 0 and 1 == Math.abs solver.cell[i1][j1] - solver.cell[i2][j2]
            switch mode
              when 'strict'
                return true
              when 'permissive'
                # Avoid extending the ends:
                return true if degree[[i1,j1]] == 1
                # Avoid extending neighbors of ends:
                for [i3, j3] from sudoku.neighboringCells i1, j1
                  return true if sudoku.cell[i3][j3] != 0 and degree[[i3,j3]] == 1 and 1 == Math.abs sudoku.cell[i1][j1] - sudoku.cell[i3][j3]
                # Avoid double-extending other pixels:
                for [i3, j3] from sudoku.neighboringCells i2, j2
                  continue if i1 == i3 and j1 == j3
                  if solver.cell[i3][j3] != 0 and 1 == Math.abs solver.cell[i2][j2] - solver.cell[i3][j3]
                    return true
              #when 'longest'
    longest = solver.longestPath()
    #console.log "#{solver}"
    #console.log longest
    #console.log "#{longest.length} vs. #{letterLength}; #{longest.count} vs. 2"
    console.assert longest.length >= letterLength,
      "Path too short: #{longest.length} should be >= #{letterLength}"
    return true if longest.length != letterLength
    console.assert longest.count >= 2,
      "#{longest.count} instances of longest path?!"
    return true if longest.count != 2
    false
  count = 0
  if num?
    seen = {}
    while count < num
      solution = solver.clone().solve()
      continue if solution.cell of seen
      seen[solution.cell] = true
      yield solution
      count++
  else
    for solution from solver.solutions()
      yield solution.clone()
      count++
    console.log "# #{count} solutions for #{letter}"
  console.log JSON.stringify solution.cell
  console.log "#{solution}"

if module? and module == require?.main
  out = ['(window || module.exports).fontGen = {']
  num = 128
  for letter of font
    if process.argv.length > 2
      continue unless letter in process.argv
    console.log "# #{letter}"
    out.push "  '#{letter}': {",
             "    base: #{JSON.stringify font[letter]},"
    out.push "    gen: [" +
      (for solution from generate(letter,
        switch letter
          when 'N'
            'longest'
          when 'Q'
            'permissive'
          else
            'strict'
      , num)
        JSON.stringify(solution.cell).replace /\s/g, ''
      ).join(', ') + "]"
    out.push "  },"
  # remove final comma
  out.pop()
  out.push "  }"
  out.push "};", ""
  fs.writeFileSync 'fontGen.js', out.join '\n'
  console.log "Wrote #{num} solutions to fontGen.js"
