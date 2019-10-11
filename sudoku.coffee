# These widths must match the widths in design.html
minorWidth = 0.05
majorWidth = 0.15

class Sudoku
  constructor: (cells) ->
    # Pass in subSize (e.g. 3 for standard Sudoku) or an array of arrays
    # representing the grid, where 0 means a blank cell.
    if typeof cells == 'number'
      @subSize = Math.floor cells
      @boardSize = @subSize * @subSize
      @cell =
        for i in [0...@boardSize]
          for j in [0...@boardSize]
            0
    else
      @cell = cells
      @boardSize = @cell.length
      for row in @cell
        console.assert row.length == @boardSize, "Row #{row} has #{@boardSize} columns"
      @subSize = Math.floor Math.sqrt @cell.length
      console.assert @subSize * @subSize == @boardSize
    # This flag controls whether to randomize the choices made by the solver.
    # Set to false for lexically ordered solutions.
    @randomize = true

  toString: ->
    s = ''
    for i in [0...@boardSize]
      for j in [0...@boardSize]
        s += '[' if j % @subSize == 0
        s += @cell[i][j]
        s += ']' if j % @subSize == @subSize-1
        s += ' '
      s += '\n'
      s += '\n' if i % @subSize == @subSize-1 unless i == @boardSize-1
    s

  clone: ->
    new Sudoku(
      for row in @cell
        row[..]
    )

  validSetting: (i, j, v) ->
    ## Would setting [i,j] to v not violate any Sudoku constraints?
    ## Existing setting for [i,j] should be null, to avoid false detection.
    # row constraint
    for jj in [0...@boardSize]
      if @cell[i][jj] == v
        return false
    # column constraint
    for ii in [0...@boardSize]
      if @cell[ii][j] == v
        return false
    # 3x3 subgrid constraint
    sub_i = (i // @subSize) * @subSize
    sub_j = (j // @subSize) * @subSize
    for ii in [sub_i ... sub_i+@subSize]
      for jj in [sub_j ... sub_j+@subSize]
        if @cell[ii][jj] == v
          return false
    true

  validBoard: ->
    ## Does the entire board satisfy all Sudoku no-duplication constraints?
    # row constraint
    for i in [0...@boardSize]
      seen = {}
      for v in @cell[i]
        if seen[v]
          return false
        seen[v] = true
    # column constraint
    for j in [0...@boardSize]
      seen = {}
      for i in [0...@boardSize]
        v = @cell[i][j]
        if seen[v]
          return false
        seen[v] = true
    # 3x3 subgrid constraint
    for sub_i in [0 ... @boardSize // @subSize]
      for sub_j in [0 ... @boardSize // @subSize]
        seen = {}
        for i in [sub_i ... sub_i + @subSize]
          for j in [sub_j ... sub_j + @subSize]
            v = @cell[i][j]
            if seen[v]
              return false
            seen[v] = true
    True

  fillImplied: ->
    implied = []
    anotherRound = true
    while anotherRound
      anotherRound = false
      for i in [0...@boardSize]
        for j in [0...@boardSize]
          # Consider all blank cells
          continue unless @cell[i][j] == 0
          used = {}
          # row constraint
          for jj in [0...@boardSize]
            used[@cell[i][jj]] = true
          # column constraint
          for ii in [0...@boardSize]
            used[@cell[ii][j]] = true
          # 3x3 subgrid constraint
          sub_i = (i // @subSize) * @subSize
          sub_j = (j // @subSize) * @subSize
          for ii in [sub_i ... sub_i + @subSize]
            for jj in [sub_j ... sub_j + @subSize]
              used[@cell[ii][jj]] = true
          # check for unique unused value
          unused = null
          for v in [1..9]
            unless used[v]
              if unused? # double unused
                unused = null
                break
              unused = v
          if unused?
            #if @validSetting i, j, unused
            @cell[i][j] = unused
            implied.push [i, j]
            anotherRound = true
    implied

  undoImplied: (implied) ->
    for [i, j] in implied
      @cell[i][j] = 0

  cellsSatisfying: (condition) ->
    for i in [0...@boardSize]
      for j in [0...@boardSize]
        if condition @cell[i][j]
          yield [i, j]

  filledCells: ->
    @cellsSatisfying (v) -> v != 0

  countCellsSatisfying: (condition) ->
    count = 0
    for cell from @cellsSatisfying condition
      count++
    count

  countFilledCells: ->
    @countCellsSatisfying (v) -> v != 0

  firstCellSatisfying: (condition) ->
    for cell from @cellsSatisfying condition
      return cell
    null

  firstEmptyCell: ->
    @firstCellSatisfying (v) -> v == 0

  cellOptions: ->
    options = [1..@boardSize]
    if @randomize  # random permutation
      for k in [0...options.length-1]
        r = k + Math.floor (options.length-k) * Math.random()
        [options[k], options[r]] = [options[r], options[k]]
    options

  solutions: ->
    ###
    Generator for all solutions to a puzzle, yielding itself as it modifies
    into each solution.
    Clone each result or use `allSolutions` to store all solutions.
    ###
    implied = @fillImplied()
    cell = @firstEmptyCell()
    # Check for filled-in puzzle
    unless cell?
      yield @
    else
      [i, j] = cell
      for v in @cellOptions()
        if @validSetting i, j, v
          @cell[i][j] = v
          yield from @solutions()
          @cell[i][j] = 0
    @undoImplied implied
    return

  solve: ->
    ###
    Modify puzzle into a solution and return it, or null upon failure.
    Use clone() first if you want a copy instead of in-place modification.
    ###
    for solution from @solutions()
      return solution
    null

  allSolutions: ->
    ###
    Return list of all solutions to the puzzle, as separate clones,
    leaving the puzzle intact.
    ###
    for solution from @solutions()
      solution.clone()

  uniqueSolution: ->
    ###
    Does this puzzle have a unique solution, i.e., exactly one solutions?
    ###
    ## Less efficient test:
    #@allSolutions().length == 1
    solutions = @clone().solutions()
    one = solutions.next()
    return false if one.done
    two = solutions.next()
    return false unless two.done
    true

  reduceImplied: ->
    loop
      cells = Array.from @filledCells()
      while cells.length
        index = Math.floor Math.random() * cells.length
        [i,j] = cells[index]
        old = @cell[i][j]
        @cell[i][j] = 0
        (refilled = @clone()).fillImplied()
        break if refilled.cell[i][j] == old
        @cell[i][j] = old
        last = cells.pop()
        cells[index] = last if cells.length
      break unless cells.length
    @

  reduceUnique: ->
    console.assert @uniqueSolution(), "Puzzle should have unique solution"
    loop
      cells = Array.from @filledCells()
      while cells.length
        index = Math.floor Math.random() * cells.length
        [i,j] = cells[index]
        old = @cell[i][j]
        @cell[i][j] = 0
        break if @uniqueSolution()
        @cell[i][j] = old
        last = cells.pop()
        cells[index] = last if cells.length
      break unless cells.length
    @

exports = {Sudoku}
(window ? module.exports)[key] = value for key, value of exports

## GENERIC GUI

# Use CSS to specify fonts
SVG?.defaults.attrs['font-family'] = null
SVG?.defaults.attrs['font-size'] = null

class SudokuGUI
  constructor: (@svg, @sudoku) ->
    @edgesGroup = @svg.group()
    .addClass 'edges'
    @gridGroup = @svg.group()
    .addClass 'grid'
    @numbersGroup = @svg.group()
    .addClass 'numbers'
    @drawGrid()
    @drawNumbers()

  coord: (i, line = false) ->
    ci = i + i // @sudoku.subSize * (majorWidth - minorWidth)
    if line and i % @sudoku.subSize == 0
      ci -= 0.5 * (majorWidth - minorWidth)
    ci

  drawGrid: ->
    @gridGroup.clear()
    for i in [1..@sudoku.boardSize].concat [0] # put border at end/top
      for coords in [[0, i, @sudoku.boardSize, i]
                     [i, 0, i, @sudoku.boardSize]]
        l = @gridGroup.line (@coord(x, true) for x in coords)
        if i % @sudoku.subSize == 0
          l.addClass 'major'
        if i % @sudoku.boardSize == 0
          l.addClass 'border'
    @svg.viewbox
      x: @coord(0, true) - majorWidth/2
      y: @coord(0, true) - majorWidth/2
      width: @coord(@sudoku.boardSize, true) - @coord(0, true) + majorWidth
      height: @coord(@sudoku.boardSize, true) - @coord(0, true) + majorWidth

  drawNumbers: ->
    @edgesGroup.clear()
    @numbersGroup.clear()
    for i in [0...@sudoku.boardSize]
      for j in [0...@sudoku.boardSize]
        number = @sudoku.cell[i][j]
        continue unless number
        ci = @coord i
        cj = @coord j
        @numbersGroup.text "#{number}"
        .move cj+0.5, ci+0.15
        if i > 0 and @sudoku.cell[i-1][j] and
           1 == Math.abs number - @sudoku.cell[i-1][j]
          @edgesGroup.line cj+0.5, ci+0.5, cj+0.5, ci-0.5
        if j > 0 and @sudoku.cell[i][j-1] and
           1 == Math.abs number - @sudoku.cell[i][j-1]
          @edgesGroup.line cj+0.5, ci+0.5, cj-0.5, ci+0.5

## Based on meouw's answer on http://stackoverflow.com/questions/442404/retrieve-the-position-x-y-of-an-html-element
getOffset = (el) ->
  x = y = 0
  while el and not isNaN(el.offsetLeft) and not isNaN(el.offsetTop)
    x += el.offsetLeft - el.scrollLeft
    y += el.offsetTop - el.scrollTop
    el = el.offsetParent
  x: x
  y: y

resize = (id) ->
  offset = getOffset document.getElementById id
  height = Math.max 100, window.innerHeight - offset.y
  document.getElementById(id).style.height = "#{height}px"

## DESIGNER GUI

designUpdate = ->

designGui = ->
  designSVG = SVG 'design'
  resultSVG = SVG 'result'
  #sudoku = new Sudoku 3
  sudoku = new Sudoku font.A
  sudoku.solve()
  gui = new SudokuGUI designSVG, sudoku

  furls = new Furls()
  .addInputs()
  .on 'stateChange', designUpdate
  .syncState()

###
  document.getElementById 'clear'
  .addEventListener 'click', -> designer.clear()
  document.getElementById('downloadSVG')?.addEventListener 'click', ->
    explicit = svgExplicit svg
    document.getElementById('svglink').href = URL.createObjectURL \
      new Blob [explicit], type: "image/svg+xml"
    document.getElementById('svglink').download = 'chiaroscuro.svg'
    document.getElementById('svglink').click()

  for event in ['input', 'change']
    do (event) ->
      for checkbox in checkboxes
        document.getElementById(checkbox).addEventListener event,
          -> designer.setState event == 'change'
      for range in ranges
        document.getElementById(range).addEventListener event, ->
          designer.setState event == 'change'
          designer.patternChange()
###

  window.addEventListener 'resize', -> resize 'gui'
  resize 'gui'

## FONT GUI

updateText = (changed) ->
  state = @getState()
  Box = SudokuGUI

  charBoxes = {}
  output = document.getElementById 'output'
  output.innerHTML = '' ## clear previous children
  for line in state.text.split '\n'
    output.appendChild outputLine = document.createElement 'p'
    outputLine.setAttribute 'class', 'line'
    outputLine.appendChild outputWord = document.createElement 'span'
    outputWord.setAttribute 'class', 'word'
    for char, c in line
      char = char.toUpperCase()
      if char of window.font
        letter = window.font[char]
        svg = SVG outputWord
        box = new Box svg, new Sudoku letter
        charBoxes[char] ?= []
        charBoxes[char].push box
        box.linked = charBoxes[char]
      else if char == ' '
        #space = document.createElement 'span'
        #space.setAttribute 'class', 'space'
        #outputLine.appendChild space
        outputLine.appendChild outputWord = document.createElement 'span'
        outputWord.setAttribute 'class', 'word'
      else
        console.log "Unknown character '#{char}'"

sizeUpdate = ->
  size = document.getElementById('size').value
  while document.getElementById('svgSize').sheet.cssRules.length > 0
    document.getElementById('svgSize').sheet.deleteRule 0
  document.getElementById('svgSize').sheet.insertRule(
    "svg { width: #{0.9*size}px; margin: #{size*0.05}px; }", 0)
  document.getElementById('svgSize').sheet.insertRule(
    ".word + .word { margin-left: #{0.4*size}px; }", 1)

fontGui = ->
  furls = new Furls()
  .addInputs()
  .on 'stateChange', updateText
  .syncState()

  window.addEventListener 'resize', ->
    resize 'output'
    document.getElementById('size').max =
      document.getElementById('size').scrollWidth - 30 - 2
  resize 'output'
  for event in ['input', 'propertychange']
    document.getElementById('size').addEventListener event, sizeUpdate
  sizeUpdate()

## GUI MAIN

window?.onload = ->
  #if window.showMe?
  #  showMe()
  if document.getElementById 'text'
    fontGui()
  else if document.getElementById 'design'
    designGui()
