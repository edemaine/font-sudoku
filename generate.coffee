fs = require 'fs'
{Sudoku} = require './sudoku.coffee'
{font} = require './font.coffee'

if module? and module == require?.main
  out = ['(window || module.exports).fontGen = {']
  num = 128
  for letter of font
    if process.argv.length > 2
      continue unless letter in process.argv
    console.log "# #{letter}"
    out.push "  '#{letter}': {",
             "    base: #{JSON.stringify font[letter]},"
    sudoku = new Sudoku font[letter]
    out.push "    gen: [" +
      (for solution from sudoku.generate(
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
