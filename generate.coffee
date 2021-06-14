fs = require 'fs'
{Sudoku} = require './sudoku.coffee'
{font} = require './font.coffee'

if module? and module == require?.main
  out = ['(window || module.exports).fontGen = {']
  num = 81 #9*9
  start = new Date
  for letter of font
    if process.argv.length > 2
      continue unless letter in process.argv
    console.log "# #{letter}"
    letterStart = new Date
    sudoku = new Sudoku font[letter]
    [longestPath] = sudoku.longestPaths()
    out.push "  '#{letter}': {",
             "    path: #{JSON.stringify longestPath},"
    count = 0
    solutions = (solution for solution from sudoku.generate(
      switch letter
        when 'N'
          'longest'
        when 'Q'
          'permissive'
        else
          'strict'
    , num))
    if solutions.length < num
      console.log "Only #{count} solutions found! :-("
    out.push "    gen: [" + (
      for solution in solutions
        JSON.stringify(solution.cell).replace /\s/g, ''
    ).join(', ') + "],"
    out.push "    puzzle: [" + (
      for solution in solutions
        solution.reduceImplied()
        JSON.stringify(solution.cell).replace /\s/g, ''
    ).join(', ') + "]"
    out.push "  },"
    letterEnd = new Date
    console.log letterEnd.getTime() - letterStart.getTime(), "seconds"
  # remove final comma
  out.pop()
  out.push "  }"
  out.push "};", ""
  end = new Date
  console.log "Total time:", end.getTime() - start.getTime(), "seconds"
  #fs.writeFileSync 'fontGen.js', out.join '\n' if process.argv.length <= 2
  console.log "Wrote #{num} solutions to fontGen.js"
