boardSize = 9
subSize = 3

class Sudoku
  constructor: (cells) ->
    if cells
      @cell = cells
      console.assert @cell.length == boardSize, "#{boardSize} rows"
      for row in @cell
        console.assert row.length == boardSize, "Row #{row} has #{boardSize} columns"
    else
      for i in [0...boardSize]
        for j in [0...boardSize]
          null

  toString: ->
    s = ''
    for i in [0...boardSize]
      for j in [0...boardSize]
        s += '[' if j % subSize == 0
        s += @cell[i][j]
        s += ']' if j % subSize == subSize-1
        s += ' '
      s += '\n'
      s += '\n' if i % subSize == subSize-1 unless i == boardSize-1
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
    for jj in [0...boardSize]
      if @cell[i][jj] == v
        return false
    # column constraint
    for ii in [0...boardSize]
      if @cell[ii][j] == v
        return false
    # 3x3 subgrid constraint
    sub_i = (i // subSize) * subSize
    sub_j = (j // subSize) * subSize
    for ii in [sub_i ... sub_i+subSize]
      for jj in [sub_j ... sub_j+subSize]
        if @cell[ii][jj] == v
          return false
    true

  validBoard: ->
    ## Does the entire board satisfy all Sudoku no-duplication constraints?
    # row constraint
    for i in [0...boardSize]
      seen = {}
      for v in @cell[i]
        if seen[v]
          return false
        seen[v] = true
    # column constraint
    for j in [0...boardSize]
      seen = {}
      for i in [0...boardSize]
        v = @cell[i][j]
        if seen[v]
          return false
        seen[v] = true
    # 3x3 subgrid constraint
    for sub_i in [0 ... boardSize // subSize]
      for sub_j in [0 ... boardSize // subSize]
        seen = {}
        for i in [sub_i ... sub_i + subSize]
          for j in [sub_j ... sub_j + subSize]
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
      for i in [0...boardSize]
        for j in [0...boardSize]
          # Consider all blank cells
          continue unless @cell[i][j] == 0
          used = {}
          # row constraint
          for jj in [0...boardSize]
            used[@cell[i][jj]] = true
          # column constraint
          for ii in [0...boardSize]
            used[@cell[ii][j]] = true
          # 3x3 subgrid constraint
          sub_i = (i // subSize) * subSize
          sub_j = (j // subSize) * subSize
          for ii in [sub_i ... sub_i + subSize]
            for jj in [sub_j ... sub_j + subSize]
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
    for i in [0...boardSize]
      for j in [0...boardSize]
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

  solutions: () ->
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
      for v in [1..9]
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

module.exports = {Sudoku}
