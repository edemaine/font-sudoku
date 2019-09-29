boardSize = 9
subSize = 3

class Sudoku
  constructor: (cells) ->
    @cell = cells or
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
    sub_i = (i // 3) * 3
    sub_j = (j // 3) * 3
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
          sub_i = (i // 3) * 3
          sub_j = (j // 3) * 3
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
            #if validSetting grid, i, j, unused
            @cell[i][j] = unused
            implied.push [i, j]
            anotherRound = true
    implied

  undoImplied: (implied) ->
    for [i, j] in implied
      @cell[i][j] = 0

  firstEmptyCell: ->
    for i in [0...boardSize]
      for j in [0...boardSize]
        if @cell[i][j] == 0
          return [i, j]
    null

  solve: ->
    implied = @fillImplied()
    cell = @firstEmptyCell()
    # Check for filled in puzzle
    unless cell?
      return @
    [i, j] = cell
    for v in [1..9]
      if @validSetting i, j, v
        @cell[i][j] = v
        if @solve()
          return @
        @cell[i][j] = 0
    @undoImplied implied
    null

module.exports = {Sudoku}
