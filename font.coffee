{Sudoku} = require './sudoku.coffee' unless window?

font =
  A: [[0,0,0, 0,0,0, 0,0,0]
      [0,0,0, 0,0,0, 0,0,0]
      [0,9,8, 7,6,0, 0,0,0]
      [0,8,0, 0,5,0, 0,0,0]
      [0,7,6, 3,4,0, 0,0,0]
      [0,4,5, 2,1,0, 0,0,0]
      [0,3,0, 0,2,0, 0,0,0]
      [0,2,0, 0,3,0, 0,0,0]
      [0,0,0, 0,0,0, 0,0,0]]
  B: [[0,0,0, 0,0,0, 0,0,0]
      [0,0,0, 0,0,0, 0,0,0]
      [0,0,0, 9,8,7, 6,0,0]
      [0,0,0, 8,0,0, 5,0,0]
      [0,0,0, 7,0,3, 4,0,0]
      [0,0,0, 6,0,4, 3,0,0]
      [0,0,0, 5,0,0, 2,0,0]
      [0,0,0, 4,3,2, 1,0,0]
      [0,0,0, 0,0,0, 0,0,0]]
  #B: [[0,0,0, 0,0,0, 0,0,0]
  #    [0,0,0, 4,3,2, 1,0,0]
  #    [0,0,0, 5,6,0, 2,0,0]
  #    [0,0,0, 6,5,4, 3,0,0]
  #    [0,0,0, 7,2,3, 4,0,0]
  #    [0,0,0, 8,0,0, 5,0,0]
  #    [0,0,0, 9,8,7, 6,0,0]
  #    [0,0,0, 0,0,0, 0,0,0]
  #    [0,0,0, 0,0,0, 0,0,0]]
  C: [[0,0,0, 0,0,0, 0,0,0]
      [0,0,9, 8,7,6, 0,0,0]
      [0,0,8, 0,0,0, 0,0,0]
      [0,0,7, 0,0,0, 0,0,0]
      [0,0,6, 0,0,0, 0,0,0]
      [0,0,5, 0,0,0, 0,0,0]
      [0,0,4, 3,2,1, 0,0,0]
      [0,0,0, 0,0,0, 0,0,0]
      [0,0,0, 0,0,0, 0,0,0]]
  D: [[0,0,0, 0,0,0, 0,0,0]
      [0,0,1, 2,3,0, 0,0,0]
      [0,0,2, 0,4,5, 0,0,0]
      [0,0,3, 0,0,6, 0,0,0]
      [0,0,8, 0,0,7, 0,0,0]
      [0,0,7, 0,9,8, 0,0,0]
      [0,0,6, 7,8,0, 0,0,0]
      [0,0,0, 0,0,0, 0,0,0]
      [0,0,0, 0,0,0, 0,0,0]]
  # This D is a cycle and has no solution without extra edges:
  #D: [[0,0,0, 0,0,0, 0,0,0]
  #    [0,0,1, 2,3,0, 0,0,0]
  #    [0,0,2, 0,4,5, 0,0,0]
  #    [0,0,3, 0,0,6, 0,0,0]
  #    [0,0,4, 0,0,7, 0,0,0]
  #    [0,0,5, 0,9,8, 0,0,0]
  #    [0,0,6, 7,8,0, 0,0,0]
  #    [0,0,0, 0,0,0, 0,0,0]
  #    [0,0,0, 0,0,0, 0,0,0]]
  E: [[0,0,0, 0,0,0, 0,0,0]
      [0,0,0, 0,0,6, 5,4,0]
      [0,0,0, 0,8,7, 0,0,0]
      [0,0,0, 0,9,8, 7,0,0]
      [0,0,0, 0,4,5, 6,0,0]
      [0,0,0, 0,3,2, 0,0,0]
      [0,0,0, 0,0,1, 2,3,0]
      [0,0,0, 0,0,0, 0,0,0]
      [0,0,0, 0,0,0, 0,0,0]]
  F: [[0,0,0, 0,0,0, 0,0,0]
      [0,0,0, 0,0,0, 0,0,0]
      [0,0,6, 7,8,9, 0,0,0]
      [0,0,5, 0,0,0, 0,0,0]
      [0,0,4, 3,0,0, 0,0,0]
      [0,0,1, 2,0,0, 0,0,0]
      [0,0,2, 0,0,0, 0,0,0]
      [0,0,3, 0,0,0, 0,0,0]
      [0,0,0, 0,0,0, 0,0,0]]
  G: [[0,0,0, 0,0,0, 0,0,0]
      [0,0,4, 3,2,1, 0,0,0]
      [0,0,5, 0,0,0, 0,0,0]
      [0,0,6, 0,0,0, 0,0,0]
      [0,0,7, 0,3,4, 0,0,0]
      [0,0,8, 0,0,5, 0,0,0]
      [0,0,9, 8,7,6, 0,0,0]
      [0,0,0, 0,0,0, 0,0,0]
      [0,0,0, 0,0,0, 0,0,0]]
  H: [[0,0,0, 0,0,0, 0,0,0]
      [0,0,4, 3,0,5, 6,0,0]
      [0,0,5, 2,0,4, 7,0,0]
      [0,0,6, 1,2,3, 8,0,0]
      [0,0,7, 0,0,8, 9,0,0]
      [0,0,8, 0,0,7, 4,0,0]
      [0,0,9, 0,0,6, 5,0,0]
      [0,0,0, 0,0,0, 0,0,0]
      [0,0,0, 0,0,0, 0,0,0]]
  I: [[0,0,0, 0,0,0, 0,0,0]
      [0,0,0, 0,0,0, 0,0,0]
      [0,0,0, 0,0,3, 4,0,0]
      [0,0,0, 0,0,4, 5,0,0]
      [0,0,0, 0,0,5, 6,0,0]
      [0,0,0, 0,0,6, 7,0,0]
      [0,0,0, 0,0,7, 8,0,0]
      [0,0,0, 0,0,8, 9,0,0]
      [0,0,0, 0,0,0, 0,0,0]]
  J: [[0,0,0, 0,0,0, 0,0,0]
      [0,0,0, 0,0,0, 0,1,0]
      [0,0,0, 0,0,0, 0,2,0]
      [0,0,0, 0,0,0, 0,3,0]
      [0,0,0, 0,7,0, 0,4,0]
      [0,0,0, 0,8,0, 0,5,0]
      [0,0,0, 0,9,8, 7,6,0]
      [0,0,0, 0,0,0, 0,0,0]
      [0,0,0, 0,0,0, 0,0,0]]
  K: [[0,0,0, 0,0,0, 0,0,0]
      [0,0,6, 5,0,1, 0,0,0]
      [0,0,7, 4,3,2, 0,0,0]
      [0,0,8, 7,0,0, 0,0,0]
      [0,0,5, 6,0,0, 0,0,0]
      [0,0,4, 1,2,3, 0,0,0]
      [0,0,3, 2,0,4, 0,0,0]
      [0,0,0, 0,0,0, 0,0,0]
      [0,0,0, 0,0,0, 0,0,0]]
  L: [[0,0,0, 0,0,0, 0,0,0]
      [0,0,0, 0,0,0, 0,0,0]
      [0,0,1, 2,0,0, 0,0,0]
      [0,0,2, 3,0,0, 0,0,0]
      [0,0,3, 4,0,0, 0,0,0]
      [0,0,4, 5,0,0, 0,0,0]
      [0,0,5, 6,0,0, 0,0,0]
      [0,0,6, 7,8,9, 0,0,0]
      [0,0,0, 0,0,0, 0,0,0]]
  M: [[0,0,0, 0,0,0, 0,0,0]
      [0,0,0, 0,0,0, 0,0,0]
      [0,0,1, 2,3,6, 7,8,0]
      [0,0,2, 0,4,5, 0,7,0]
      [0,0,3, 0,0,0, 0,6,0]
      [0,0,4, 0,0,0, 0,5,0]
      [0,0,5, 0,0,0, 0,4,0]
      [0,0,6, 0,0,0, 0,3,0]
      [0,0,0, 0,0,0, 0,0,0]]
  ## Not completable with longest path:
  #M: [[0,0,0, 0,0,0, 0,0,0]
  #    [0,0,0, 2,3,8, 7,0,0]
  #    [0,0,2, 1,4,7, 6,5,0]
  #    [0,0,3, 0,5,6, 0,4,0]
  #    [0,0,4, 0,0,0, 0,3,0]
  #    [0,0,5, 0,0,0, 0,2,0]
  #    [0,0,6, 0,0,0, 0,1,0]
  #    [0,0,0, 0,0,0, 0,0,0]
  #    [0,0,0, 0,0,0, 0,0,0]]
  #M: [[0,0,0, 0,0,0, 0,0,0]
  #    [0,0,0, 0,0,0, 0,0,0]
  #    [0,6,7, 0,0,2, 3,0,0]
  #    [0,5,8, 9,2,1, 4,0,0]
  #    [0,4,0, 8,3,0, 5,0,0]
  #    [0,3,0, 7,4,0, 6,0,0]
  #    [0,2,0, 6,5,0, 7,0,0]
  #    [0,1,0, 0,0,0, 8,0,0]
  #    [0,0,0, 0,0,0, 0,0,0]]
  #N: [[0,0,0, 0,0,0, 0,0,0]
  #    [0,0,6, 7,0,0, 8,0,0]
  #    [0,0,5, 8,9,0, 7,0,0]
  #    [0,0,4, 0,8,0, 6,0,0]
  #    [0,0,3, 0,7,6, 5,0,0]
  #    [0,0,2, 0,0,5, 4,0,0]
  #    [0,0,1, 0,0,4, 3,0,0]
  #    [0,0,0, 0,0,0, 0,0,0]
  #    [0,0,0, 0,0,0, 0,0,0]]
  #N: [[0,0,0, 0,0,0, 0,0,0]
  #    [0,0,9, 8,0,0, 5,0,0]
  #    [0,0,8, 7,6,0, 4,0,0]
  #    [0,0,7, 0,5,0, 3,0,0]
  #    [0,0,6, 0,4,3, 2,0,0]
  #    [0,0,5, 0,0,2, 1,0,0]
  #    [0,0,4, 0,0,0, 0,0,0]
  #    [0,0,0, 0,0,0, 0,0,0]
  #    [0,0,0, 0,0,0, 0,0,0]]
  #N: [[0,0,0, 0,0,0, 0,0,0]
  #    [0,7,8, 9,0,0, 0,0,0]
  #    [0,6,0, 8,0,0, 3,0,0]
  #    [0,5,0, 7,0,0, 4,0,0]
  #    [0,4,0, 6,0,0, 5,0,0]
  #    [0,3,0, 5,0,0, 6,0,0]
  #    [0,2,0, 4,5,6, 7,0,0]
  #    [0,0,0, 0,0,0, 0,0,0]
  #    [0,0,0, 0,0,0, 0,0,0]]
  ## Height-5:
  N: [[0,0,0, 0,0,0, 0,0,0]
      [0,0,0, 0,0,0, 0,0,0]
      [0,0,1, 2,3,0, 5,0,0]
      [0,0,2, 0,4,0, 6,0,0]
      [0,0,3, 0,5,0, 7,0,0]
      [0,0,4, 0,6,7, 8,0,0]
      [0,0,5, 0,0,8, 9,0,0]
      [0,0,0, 0,0,0, 0,0,0]
      [0,0,0, 0,0,0, 0,0,0]]
  O: [[0,0,0, 0,0,0, 0,0,0]
      [0,0,0, 0,0,0, 0,0,0]
      [0,0,0, 1,2,3, 4,0,0]
      [0,0,0, 2,0,0, 5,0,0]
      [0,0,0, 3,0,0, 6,0,0]
      [0,0,0, 4,0,0, 7,0,0]
      [0,0,0, 5,0,0, 8,0,0]
      [0,0,0, 6,7,8, 9,0,0]
      [0,0,0, 0,0,0, 0,0,0]]
  P: [[0,0,0, 0,0,0, 0,0,0]
      [0,0,0, 0,0,0, 0,0,0]
      [0,0,6, 7,8,9, 0,0,0]
      [0,0,5, 0,0,8, 0,0,0]
      [0,0,4, 5,6,7, 0,0,0]
      [0,0,3, 0,0,0, 0,0,0]
      [0,0,2, 0,0,0, 0,0,0]
      [0,0,1, 0,0,0, 0,0,0]
      [0,0,0, 0,0,0, 0,0,0]]
  #Q: [[0,0,0, 0,0,0, 0,0,0]
  #    [0,0,0, 0,0,0, 0,0,0]
  #    [0,0,0, 6,7,8, 9,0,0]
  #    [0,0,0, 5,0,0, 8,0,0]
  #    [0,0,0, 4,0,0, 7,0,0]
  #    [0,0,0, 3,0,0, 6,0,0]
  #    [0,0,0, 2,1,4, 5,0,0]
  #    [0,0,0, 0,6,5, 0,0,0]
  #    [0,0,0, 0,0,0, 0,0,0]]
  Q: [[0,0,0, 0,0,0, 0,0,0]
      [0,0,0, 0,0,0, 0,0,0]
      [0,0,0, 6,7,8, 9,0,0]
      [0,0,0, 5,0,0, 8,0,0]
      [0,0,0, 4,0,0, 7,0,0]
      [0,0,0, 3,0,0, 6,0,0]
      [0,0,0, 2,1,4, 5,0,0]
      [0,0,0, 0,0,3, 2,0,0]
      [0,0,0, 0,0,0, 0,0,0]]
  R: [[0,0,0, 0,0,0, 0,0,0]
      [0,0,0, 0,0,0, 0,0,0]
      [0,6,7, 8,9,0, 0,0,0]
      [0,5,0, 0,8,0, 0,0,0]
      [0,4,0, 6,7,0, 0,0,0]
      [0,3,0, 5,0,0, 0,0,0]
      [0,2,0, 4,3,0, 0,0,0]
      [0,1,0, 0,2,0, 0,0,0]
      [0,0,0, 0,0,0, 0,0,0]]
  S: [[0,0,0, 0,0,0, 0,0,0]
      [0,0,0, 4,3,2, 1,0,0]
      [0,0,0, 5,0,0, 0,0,0]
      [0,0,0, 6,7,8, 9,0,0]
      [0,0,0, 0,0,0, 8,0,0]
      [0,0,0, 0,0,0, 7,0,0]
      [0,0,0, 3,4,5, 6,0,0]
      [0,0,0, 0,0,0, 0,0,0]
      [0,0,0, 0,0,0, 0,0,0]]
  T: [[0,0,0, 0,0,0, 0,0,0]
      [0,0,0, 0,0,0, 0,0,0]
      [0,0,0, 0,1,2, 3,4,0]
      [0,0,0, 0,2,3, 4,5,0]
      [0,0,0, 0,0,4, 9,0,0]
      [0,0,0, 0,0,5, 8,0,0]
      [0,0,0, 0,0,6, 7,0,0]
      [0,0,0, 0,0,7, 6,0,0]
      [0,0,0, 0,0,0, 0,0,0]]
  U: [[0,0,0, 0,0,0, 0,0,0]
      [0,0,1, 0,0,4, 0,0,0]
      [0,0,2, 0,0,5, 0,0,0]
      [0,0,3, 0,0,6, 0,0,0]
      [0,0,4, 0,0,7, 0,0,0]
      [0,0,5, 0,0,8, 0,0,0]
      [0,0,6, 7,8,9, 0,0,0]
      [0,0,0, 0,0,0, 0,0,0]
      [0,0,0, 0,0,0, 0,0,0]]
  V: [[0,0,0, 0,0,0, 0,0,0]
      [0,4,0, 0,1,0, 0,0,0]
      [0,5,0, 0,2,0, 0,0,0]
      [0,6,7, 0,3,0, 0,0,0]
      [0,0,8, 0,4,0, 0,0,0]
      [0,0,9, 8,5,0, 0,0,0]
      [0,0,0, 7,6,0, 0,0,0]
      [0,0,0, 0,0,0, 0,0,0]
      [0,0,0, 0,0,0, 0,0,0]]
  W: [[0,0,0, 0,0,0, 0,0,0]
      [0,0,6, 0,0,0, 0,3,0]
      [0,0,5, 0,0,0, 0,4,0]
      [0,0,4, 0,0,0, 0,5,0]
      [0,0,3, 0,0,0, 0,6,0]
      [0,0,2, 0,4,5, 0,7,0]
      [0,0,1, 2,3,6, 7,8,0]
      [0,0,0, 0,0,0, 0,0,0]
      [0,0,0, 0,0,0, 0,0,0]]
  X: [[0,0,0, 0,0,0, 0,0,0]
      [0,0,0, 0,0,7, 6,0,0]
      [0,0,0, 0,0,8, 5,0,0]
      [0,0,0, 7,8,9, 4,3,2]
      [0,0,0, 6,5,4, 0,0,0]
      [0,0,0, 0,0,3, 0,0,0]
      [0,0,0, 0,0,2, 0,0,0]
      [0,0,0, 0,0,0, 0,0,0]
      [0,0,0, 0,0,0, 0,0,0]]
  Y: [[0,0,0, 0,0,0, 0,0,0]
      [0,0,0, 7,0,0, 4,0,0]
      [0,0,0, 8,0,0, 3,0,0]
      [0,0,0, 9,8,1, 2,0,0]
      [0,0,0, 0,7,2, 0,0,0]
      [0,0,0, 0,6,3, 0,0,0]
      [0,0,0, 0,5,4, 0,0,0]
      [0,0,0, 0,0,0, 0,0,0]
      [0,0,0, 0,0,0, 0,0,0]]
  Z: [[0,0,0, 0,0,0, 0,0,0]
      [0,0,0, 0,0,0, 0,0,0]
      [0,0,1, 2,3,4, 0,0,0]
      [0,0,0, 0,6,5, 0,0,0]
      [0,0,0, 8,7,0, 0,0,0]
      [0,0,8, 9,0,0, 0,0,0]
      [0,0,7, 0,0,0, 0,0,0]
      [0,0,6, 7,8,9, 0,0,0]
      [0,0,0, 0,0,0, 0,0,0]]
  0: [[0,0,0, 0,0,0, 0,0,0]
      [0,0,0, 0,0,0, 0,0,0]
      [0,0,0, 0,0,0, 0,0,0]
      [0,0,0, 0,0,0, 0,0,0]
      [0,0,0, 0,0,0, 0,0,0]
      [0,0,0, 0,0,0, 0,0,0]
      [0,0,0, 0,0,0, 0,0,0]
      [0,0,0, 0,0,0, 0,0,0]
      [0,0,0, 0,0,0, 0,0,0]]

window?.font = font
exports?.font = font

if module? and module == require?.main
  reduceUnique = false
  reduceImplied = true
  for letter, puzzle of font
    if process.argv.length > 2
      continue unless letter in process.argv
    console.log "====== #{letter}\n"
    sudoku = new Sudoku puzzle
    console.log "#{sudoku}"
    #solutions = sudoku.allSolutions()
    #console.log "#{solutions.length} SOLUTIONS"
    #continue unless solutions.length
    #console.log "Considering first solution:" if solutions.length > 1
    #solution = solutions[0]
    solution = sudoku.clone().solve()
    console.log "SOLUTION:"
    console.log "\n#{solution}"
    continue unless solution?
    if reduceImplied
      console.log "REDUCED BY IMPLICATION:"
      console.log "\n#{i = solution.clone().reduceImplied()}"
      console.log "(#{i.countFilledCells()} filled cells)\n"
    if reduceUnique
      console.log "REDUCED BY UNIQUENESS:"
      console.log "\n#{u = solution.clone().reduceUnique()}"
      console.log "(#{u.countFilledCells()} filled cells)\n"
    #console.log "... #{u.allSolutions().length} solutions"
