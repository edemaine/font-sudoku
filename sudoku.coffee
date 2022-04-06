# These widths must match the widths in design.html
minorWidth = 0.05
majorWidth = 0.15

animStepDelay =
  0: 750
  1: 75
  2: 750
  3: 2750
  4: 4000
animStepDuration =
  1: 500
  3: 2000
  4: 2000

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
    copy = new Sudoku(
      for row in @cell
        row[..]
    )
    copy.prune = @prune if @prune?
    copy

  complete: ->
    for i in [0...@boardSize]
      for j in [0...@boardSize]
        if @cell[i][j] == 0
          return false
    true

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

  invalidCells: ->
    ## Does the entire board satisfy all Sudoku no-duplication constraints?
    ## If not, return array of [i,j] cell coordinates with duplicate values.
    bad = []
    # row constraint
    for i in [0...@boardSize]
      seen = {}
      for v, j in @cell[i]
        if seen[v]?
          bad.push [i, seen[v]]
          bad.push [i, j]
        else if v
          seen[v] = j
    # column constraint
    for j in [0...@boardSize]
      seen = {}
      for i in [0...@boardSize]
        v = @cell[i][j]
        if seen[v]?
          bad.push [seen[v], j]
          bad.push [i, j]
        else if v
          seen[v] = i
    # 3x3 subgrid constraint
    for sub_i in [0 ... @boardSize // @subSize]
      sub_i *= @subSize
      for sub_j in [0 ... @boardSize // @subSize]
        sub_j *= @subSize
        seen = {}
        for i in [sub_i ... sub_i + @subSize]
          for j in [sub_j ... sub_j + @subSize]
            v = @cell[i][j]
            if seen[v]?
              bad.push seen[v]
              bad.push [i, j]
            else if v
              seen[v] = [i, j]
    bad

  available: (i, j) ->
    # Returns list of values available for use for empty cell (i, j)
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
    # flip used vs. unused
    for v in [1..9]
      continue if used[v]
      v

  hints: ->
    # Returns list of coordinates of blank squares with unique fill-in
    hints = []
    for i in [0...@boardSize]
      for j in [0...@boardSize]
        # Consider all blank cells
        if @cell[i][j] == 0
          available = @available i, j
          if available.length == 1
            hints.push [i, j]
    hints

  fillImplied: ->
    implied = []
    anotherRound = true
    while anotherRound
      anotherRound = false
      # Check for a blank cell that can be filled by at most one number
      @unused =
        for i in [0...@boardSize]
          break if dead
          for j in [0...@boardSize]
            # Consider all blank cells
            if @cell[i][j] == 0
              unused = @available i, j
              if unused.length == 0
                dead = true
                break
              else if unused.length == 1
                #if @validSetting i, j, unused
                @cell[i][j] = unused[0]
                implied.push [i, j]
                anotherRound = true
              unused
            else
              null
      if dead
        @undoImplied implied
        return 'dead'
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

  bestEmptyCell: ->
    for row, i in @unused
      for cell, j in row when cell?
        if not best? or cell.length < best
          best = cell.length
          iBest = i
          jBest = j
    if best?
      [iBest, jBest]
    else
      null

  neighboringCells: (i, j) ->
    cell for cell in [
      [i-1, j]
      [i+1, j]
      [i, j-1]
      [i, j+1]
    ] when 0 <= cell[0] < @boardSize and 0 <= cell[1] < @boardSize

  consecutiveNeighboringCells: (i, j) ->
    return [] if @cell[i][j] == 0
    [ii, jj] for [ii, jj] in @neighboringCells i, j \
    when @cell[ii][jj] != 0 and 1 == Math.abs @cell[ii][jj] - @cell[i][j]

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
    Add additional pruning rules by adding @prune function.
    ###
    implied = @fillImplied()
    return if implied == 'dead'
    # Custom pruning rules
    if @prune?()
      return @undoImplied implied
    #cell = @firstEmptyCell()
    cell = @bestEmptyCell()
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

  generate: (mode = 'strict', num) ->
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
    letterLength = @countFilledCells()
    degree = {}
    for [i1, j1] from @filledCells()
      degree[[i1,j1]] = 0
      for [i2, j2] from @consecutiveNeighboringCells i1, j1
        degree[[i1,j1]]++
    original = @
    solver = @clone()
    solver.prune = -> # @ = solved state
      for [i1, j1] from original.filledCells()
        console.assert @cell[i1][j1] != 0, "Missing clue #{i1},#{j1} = #{original.cell[i1][j1]} in solved state"
        for [i2, j2] from @consecutiveNeighboringCells i1, j1
          if original.cell[i2][j2] == 0 # transition between blank and filled in input
            switch mode
              when 'strict'
                return true
              when 'permissive'
                # Avoid extending the ends:
                return true if degree[[i1,j1]] == 1
                # Avoid extending neighbors of ends:
                for [i3, j3] from original.consecutiveNeighboringCells i1, j1
                  return true if degree[[i3,j3]] == 1
                # Avoid double-extending other pixels:
                for [i3, j3] from @consecutiveNeighboringCells i2, j2
                  continue if i1 == i3 and j1 == j3
                  return true
              #when 'longest'
      longests = @longestPaths()
      #console.log "#{@}"
      #console.log longests
      #console.log "#{longests[0].length} vs. #{letterLength}; #{longests.length} vs. 2"
      console.assert longests.length > 0, "No longest paths?"
      console.assert longests[0].length >= letterLength,
        "Path too short: #{longests[0].length} should be >= #{letterLength}"
      return true if longests[0].length != letterLength
      for longest in longests
        for [i, j] in longest
          return true if original.cell[i][j] == 0 # path uses non-original cell
      false
    count = 0
    if num?
      seen = {}
      while count < num
        solution = solver.clone().solve()
        break unless solution?
        continue if solution.cell of seen
        seen[solution.cell] = true
        yield solution
        count++
    else
      for solution from solver.solutions()
        yield solution.clone()
        count++
    count

  longestPaths: ->
    longests = [] # all longest paths so far
    path = []     # current path (grown incrementally)
    onPath = {}   # map for fast detection of which vertices are on path
    recurse = (cell) =>
      return if cell of onPath # avoid repeating vertices
      path.push cell
      onPath[cell] = true
      if longests.length == 0 or path.length > longests[0].length
        longests = [path[..]]
      else if path.length == longests[0].length
        longests.push path[..]
      for neighbor from @consecutiveNeighboringCells cell...
        recurse neighbor
      delete onPath[cell]
      path.pop()
    for cell from @filledCells()
      recurse cell
    longests

exports = {Sudoku}
(window ? module.exports)[key] = value for key, value of exports

## GENERIC GUI

selected = null

class SudokuGUI
  constructor: (@svg, @sudoku, @path, @puzzle, @user) ->
    # Intent:
    # * @sudoku is the generated full solution compatible with @path;
    # * @path is the longest path that forms the letter; and
    # * @puzzle is the generated puzzle with enough clues to be unique.
    # * @user consists of @puzzle plus the user-input clues
    # However, @sudoku can be a partial solution in case of designer.
    @inPath = {}
    for i in [0...@path.length]
      @inPath[[@path[i], @path[(i+1) % @path.length]]] = true
      @inPath[[@path[(i+1) % @path.length], @path[i]]] = true
    @user ?= @puzzle.clone()
    @squaresGroup = @svg.group()
    .addClass 'squares'
    @edgesGroup = @svg.group()
    .addClass 'solved'
    .addClass 'edges'
    @userEdgesGroup = @svg.group()
    .addClass 'user'
    .addClass 'edges'
    @gridGroup = @svg.group()
    .addClass 'grid'
    @numbersGroup = @svg.group()
    .addClass 'numbers'
    @drawGrid()
    @drawNumbers()
    @updateUser()

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
    @squaresGroup.clear()
    @squares = {}
    @puzzleNumbers = {}
    @solutionNumbers = {}
    for i in [0...@sudoku.boardSize]
      for j in [0...@sudoku.boardSize]
        number = @sudoku.cell[i][j]
        continue unless number
        ci = @coord i
        cj = @coord j
        t = @numbersGroup.text "#{number}"
        #.move cj+0.5, ci+0.15
        .attr 'x', cj+0.5
        .attr 'y', ci-0.05
        @squares[[i,j]] = square = @squaresGroup.rect 1, 1
        .move cj, ci
        if @puzzle?.cell[i][j] != 0
          #t.addClass 'puzzle'
          @puzzleNumbers[[i,j]] = t
          #@solutionNumbers[[i,j]] = t
          square.addClass 'puzzle'
        else
          t.addClass 'solution'
          @solutionNumbers[[i,j]] = t
          @puzzleNumbers[[i,j]] = @numbersGroup.text "#{@user.cell[i][j] or ''}"
          .attr 'x', cj+0.5
          .attr 'y', ci-0.05
          .addClass 'user'
          do (i, j) =>
            square.click click = => @select i, j
            @puzzleNumbers[[i,j]].click click
        if i > 0 and @sudoku.cell[i-1][j] and
           1 == Math.abs number - @sudoku.cell[i-1][j]
          l = @edgesGroup.line cj+0.5, ci+0.5, cj+0.5, ci-0.5
          l.addClass 'path' if [i,j, i-1,j] of @inPath
          l.addClass 'puzzle' if @puzzle?.cell[i][j] and @puzzle?.cell[i-1][j]
        if j > 0 and @sudoku.cell[i][j-1] and
           1 == Math.abs number - @sudoku.cell[i][j-1]
          l = @edgesGroup.line cj+0.5, ci+0.5, cj-0.5, ci+0.5
          l.addClass 'path' if [i,j, i,j-1] of @inPath
          l.addClass 'puzzle' if @puzzle?.cell[i][j] and @puzzle?.cell[i][j-1]

  updateUser: ->
    # Detect invalid squares
    for element in @svg.find '.invalid'
      element.removeClass 'invalid'
    for bad in invalid = @user.invalidCells()
      @puzzleNumbers[bad].addClass 'invalid'

    # Detect hints (uniquely fillable squares)
    for element in @svg.find '.hint'
      element.removeClass 'hint'
    for hint in @user.hints()
      @squares[hint].addClass 'hint'

    # Draw lines
    @userEdgesGroup.clear()
    for i in [0...@user.boardSize]
      for j in [0...@user.boardSize]
        number = @user.cell[i][j]
        continue unless number
        ci = @coord i
        cj = @coord j
        if i > 0 and @user.cell[i-1][j] and
           1 == Math.abs number - @user.cell[i-1][j]
          l = @userEdgesGroup.line cj+0.5, ci+0.5, cj+0.5, ci-0.5
          l.addClass 'path' if [i,j, i-1,j] of @inPath
        if j > 0 and @user.cell[i][j-1] and
           1 == Math.abs number - @user.cell[i][j-1]
          l = @userEdgesGroup.line cj+0.5, ci+0.5, cj-0.5, ci+0.5
          l.addClass 'path' if [i,j, i,j-1] of @inPath

    # Check whether completely solved
    if invalid.length == 0 and @user.complete()
      @svg.addClass 'solved'
    else
      @svg.removeClass 'solved'

  set: ([i, j], value) ->
    #console.log 'setting', i, j, value
    @user.cell[i][j] = value
    @puzzleNumbers[[i,j]].text "#{@user.cell[i][j] or ''}"
    @updateUser()

  select: (i, j) ->
    # Selects cell (i,j) in this Sudoku GUI.  Selection needs to be
    # page-global (because editing is controlled by keyboard and global
    # buttons), so we need to deselect everything in all Sudoku GUIs.
    for element in document.getElementsByClassName 'selected'
      element.classList.remove 'selected'
    @squares[[i,j]].addClass 'selected'
    @selected = [i, j]
    selected = @
  selectMove: (di, dj) ->
    return unless @selected? and selected == @
    [i, j] = @selected
    loop
      i = (i + di) %% @sudoku.boardSize
      j = (j + dj) %% @sudoku.boardSize
      break if @puzzle?.cell[i][j] == 0
    @select i, j

  animInit: ->
    @animEnd()
    @anim = @puzzle.clone()
    for key, dom of @solutionNumbers
      dom.opacity 0
    @edgesGroup.opacity 0
  animStep: ->
    hints = @anim.hints()
    return true unless hints.length
    hint = hints[0]
    [i, j] = hint
    @anim.cell[i][j] = @sudoku.cell[i][j]
    @solutionNumbers[hint].animate(animStepDuration[1]).opacity 1
    false
  animEdges: ->
    @edgesGroup.find 'line.path'
    .css 'stroke', '#cac'
    .css 'stroke-width', 0.333
    @edgesGroup.animate(animStepDuration[3]).opacity 1
  animPath: ->
    @edgesGroup.find 'line.path'
    .animate animStepDuration[4]
    .css 'stroke', '#b8b'
    .css 'stroke-width', 0.666
  animEnd: ->
    for key, dom of @solutionNumbers
      dom.timeline().finish()
      dom.opacity 1
    @edgesGroup.timeline().finish()
    @edgesGroup.opacity 1
    @edgesGroup.find 'line.path'
    .each (dom) ->
      dom.timeline().finish()
      dom.attr 'style', null

numberInput = ->
  window.addEventListener 'keyup', (e) ->
    return unless selected?
    num = null
    if '0' <= e.key <= '9'
      num = e.key.charCodeAt() - '0'.charCodeAt()
    else if e.key in ['Delete', 'Backspace']
      num = 0
    stop = true
    if num?
      selected.set selected.selected, num
    else
      switch e.key
        when 'a', 'h', 'ArrowLeft'
          selected.selectMove 0, -1
        when 'd', 'l', 'ArrowRight'
          selected.selectMove 0, +1
        when 's', 'j', 'ArrowDown'
          selected.selectMove +1, 0
        when 'w', 'k', 'ArrowUp'
          selected.selectMove -1, 0
        else
          stop = false
    if stop
      e.preventDefault()
      e.stopPropagation()
  for num in [0..9]
    do (num) ->
      document.getElementById("number#{num}")?.addEventListener 'click', (e) ->
        return unless selected?
        e.preventDefault()
        e.stopPropagation()
        selected.set selected.selected, num

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

designGui = ->
  designSVG = SVG().addTo '#design'
  resultSVG = SVG().addTo '#result'
  sudoku = new Sudoku 3
  gui = new SudokuGUI designSVG, sudoku

  furls = new Furls()
  .addInputs()
  .on 'stateChange', ->
    state = @getState()
    setClass 'design', state
    setClass 'result', state
    resultSVG.clear()
    result = sudoku.clone()
    try
      switch state.solve
        when 'any'
          result.solve()
        when 'strict'
          [result] = result.generate 'strict', 1
        when 'permissive'
          [result] = result.generate 'permissive', 1
        when 'longest'
          [result] = result.generate 'longest', 1
      if result?
        new SudokuGUI resultSVG, result, sudoku
      else
        resultSVG.text "no solution"
        resultSVG.viewbox {x: 0, y: -10, width: 80, height: 20}
    catch e
      console.error e
  .syncState()

  document.getElementById 'resolve'
  .addEventListener 'click', -> furls.trigger 'stateChange'

  document.getElementById 'loadFont'
  .appendChild select = document.createElement 'select'
  select.appendChild option = document.createElement 'option'
  option.setAttribute 'selected', true
  for char of window.font
    select.appendChild option = document.createElement 'option'
    option.setAttribute 'value', char
    option.appendChild document.createTextNode char
  select.addEventListener 'change', (e) ->
    return unless e.target.value of window.font
    sudoku = new Sudoku window.font[e.target.value]
    designSVG.clear()
    gui = new SudokuGUI designSVG, sudoku
    furls.trigger 'stateChange'

###
  document.getElementById 'clear'
  .addEventListener 'click', -> designer.clear()
  document.getElementById('downloadSVG')?.addEventListener 'click', ->
    explicit = svgExplicit svg
    document.getElementById('svglink').href = URL.createObjectURL \
      new Blob [explicit], type: "image/svg+xml"
    document.getElementById('svglink').download = 'chiaroscuro.svg'
    document.getElementById('svglink').click()
###

  window.addEventListener 'resize', -> resize 'gui'
  resize 'gui'

## FONT GUI

setClass = (id, state) ->
  document.getElementById id
  .setAttribute 'class',
    (checkbox for checkbox in ['edges', 'path', 'mistakes', 'hints'] \
              when state[checkbox])
    .concat [state.mode, 'root']
    .join ' '

animation = 0
boxes = []

updateLink = (state) ->
  if (link = document.getElementById 'link') and
     (href = link.getAttribute 'data-href')
    href = href.replace /TEXT/, state.text
    link.setAttribute 'href', href

updateText = (changed) ->
  state = @getState()
  updateLink state
  Box = SudokuGUI
  setClass 'output', state

  if changed.text
    selected = null
    charBoxes = {}
    output = document.getElementById 'output'
    output.innerHTML = '' ## clear previous children
    boxes = []
    for line in state.text.split '\n'
      output.appendChild outputLine = document.createElement 'p'
      outputLine.setAttribute 'class', 'line'
      outputLine.appendChild outputWord = document.createElement 'span'
      outputWord.setAttribute 'class', 'word'
      for char, c in line
        char = char.toUpperCase()
        if char of window.fontGen
          letter = window.fontGen[char]
          which = Math.floor letter.gen.length * Math.random()
          svg = SVG().addTo outputWord
          box = new Box svg, (new Sudoku letter.gen[which]),
            letter.path, (new Sudoku letter.puzzle[which])
          boxes.push box
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

  animation++
  if state.mode == 'anim'
    thisAnimation = animation
    stage = 0
    step = =>
      return unless thisAnimation == animation
      delay = animStepDelay[stage] # before stage changes
      switch stage
        when 0  # clear and reset
          box.animInit() for box in boxes
          stage++
        when 1  # fill in Sudoku puzzles in hint order
          done = 0
          for box in boxes
            done += box.animStep()
          stage++ if done == boxes.length
        when 2  # pause
          stage++
          stage += 2 unless @getState().edges
        when 3  # draw consecutive edges
          box.animEdges() for box in boxes
          stage++
          stage++ unless @getState().path
        when 4  # draw path
          box.animPath() for box in boxes
          stage++
        when 5  # pause
          stage = 0
      setTimeout step, delay
    step()
  else
    box.animEnd() for box in boxes

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
  .syncClass()

  document.getElementById 'nohud'
  ?.addEventListener 'click', ->
    furls.set 'hud', false

  document.getElementById 'randomize'
  .addEventListener 'click', -> updateText.call furls, text: true # force

  if document.getElementById 'size'
    window.addEventListener 'resize', size = ->
      document.getElementById('size').max =
        document.getElementById('size').scrollWidth - 30 - 2
    size()
    for event in ['input', 'propertychange']
      document.getElementById('size').addEventListener event, sizeUpdate
    sizeUpdate()
  numberInput()

## GUI MAIN

window?.onload = ->
  #if window.showMe?
  #  showMe()
  if document.getElementById 'text'
    fontGui()
  else if document.getElementById 'design'
    designGui()
