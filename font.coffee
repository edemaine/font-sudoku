{Sudoku} = require './sudoku'

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

for letter, puzzle of font
  console.log "====== #{letter}\n"
  sudoku = new Sudoku puzzle
  console.log "#{sudoku}"
  #solutions = sudoku.allSolutions()
  #console.log "#{solutions.length} SOLUTIONS"
  #continue unless solutions.length
  #console.log "Considering first solution:" if solutions.length > 1
  #solution = solutions[0]
  solution = sudoku.clone().solve()
  console.log "\n#{solution}"
  console.log "REDUCED BY IMPLICATION:"
  console.log "\n#{solution.clone().reduceImplied()}"
  console.log "REDUCED BY UNIQUENESS:"
  console.log "\n#{u = solution.clone().reduceUnique()}"
  #console.log "... #{u.allSolutions().length} solutions"
