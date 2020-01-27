# University of Washington, Programming Languages, Homework 6, hw6runner.rb

# This is the only file you turn in, so do not modify the other files as
# part of your solution.

class MyPiece < Piece
  # The constant All_My_Pieces should be declared here
  All_My_Pieces = All_Pieces + [[[[0, 0], [-1, 0], [1, 0], [2, 0], [-2, 0]], # 5-bar
                                 [[0, 0], [0, -1], [0, 1], [0, 2], [0, -2]]],
                                rotations([[0, 0], [1, 0], [0, 1]]), # small L
                                rotations([[0, 0], [-1, 0], [1, 0], [0, 1], [-1, 1]])] # d piece
                               
  # your enhancements here
  def initialize(point_array, board)
    super
  end

    def self.next_piece (board)
    MyPiece.new(All_My_Pieces.sample, board)
  end  
end

class MyBoard < Board
  # your enhancements here
  attr_accessor :cheat_flag
  
  def initialize (game)
    @grid = Array.new(num_rows) {Array.new(num_columns)}
    @current_block = MyPiece.next_piece(self)
    @score = 0
    @game = game
    @delay = 500

    @cheat_flag = false
  end

  def rotate_180
     if !game_over? and @game.is_running?
       @current_block.move(0, 0, 1)
       @current_block.move(0, 0, 1)
    end
    draw
  end

  def next_piece
    if !@cheat_flag
      @current_block = MyPiece.next_piece(self)
    else
      @current_block = MyPiece.new([[[0, 0]]], self)
      @score -= 100
      @cheat_flag = false
    end
    @current_pos = nil
  end


  # gets the information from the current piece about where it is and uses this
  # to store the piece on the board itself.  Then calls remove_filled.
  def store_current
    locations = @current_block.current_rotation
    displacement = @current_block.position
    (0..(locations.size - 1)).each{|index| 
      current = locations[index];
      @grid[current[1]+displacement[1]][current[0]+displacement[0]] = 
      @current_pos[index]
    }
    remove_filled
    @delay = [@delay - 2, 80].max
  end
end

class MyTetris < Tetris
  # your enhancements here
  def initialize
    super
    more_key_bindings
  end

  def set_board
    @canvas = TetrisCanvas.new
    @board = MyBoard.new(self)
    @canvas.place(@board.block_size * @board.num_rows + 3,
                  @board.block_size * @board.num_columns + 6, 24, 80)
    @board.draw
  end

  def more_key_bindings  
    @root.bind('u', proc {@board.rotate_180})
    @root.bind('c', proc {if @board.score >= 100 && !@board.cheat_flag; @board.cheat_flag = true; end})
  end

end


