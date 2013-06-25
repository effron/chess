# encoding: UTF-8
require 'set'
load './chess_pieces.rb'

def parse(str)
  chars = str.split(//)
  [chars[1].to_i-1,chars[0].ord - 97]
end


class Board
  attr_accessor :pieces

  SIZE = 8
  def initialize
    spawn_pieces!
  end

  def spawn_pieces!
    @pieces = Set.new
    @pieces << Queen.new([7,3], :white, self)
    @pieces << Queen.new([0,3], :black, self)
    @pieces << King.new([7,4], :white, self)
    @pieces << King.new([0,4], :black, self)
    @pieces << Bishop.new([7,2], :white, self)
    @pieces << Bishop.new([7,5], :white, self)
    @pieces << Bishop.new([0,2], :black, self)
    @pieces << Bishop.new([0,5], :black, self)
    @pieces << Rook.new([7,0], :white, self)
    @pieces << Rook.new([7,7], :white, self)
    @pieces << Rook.new([0,0], :black, self)
    @pieces << Rook.new([0,7], :black, self)
    @pieces << Knight.new([7,1], :white, self)
    @pieces << Knight.new([7,6], :white, self)
    @pieces << Knight.new([0,1], :black, self)
    @pieces << Knight.new([0,6], :black, self)

    SIZE.times { |i| @pieces << Pawn.new([6,i],:white,self)}
    SIZE.times { |i| @pieces << Pawn.new([1,i],:black,self)}

  end

  def move_piece(startpoint, endpoint)
    piece = what_is_at(startpoint)
    end_piece = what_is_at(endpoint)
    #puts "Not empty or opposite" unless empty_or_opposite_color?(piece.color, endpoint)
    if empty_or_opposite_color?(piece.color, endpoint) && \
      (piece.is_a?(Knight) || empty_path?(startpoint,endpoint))
      piece.move(endpoint) && kill(end_piece)
    end
  end

  def what_is_at(pos)
    @pieces.find do |piece|
      piece.position == pos
    end
  end

  def display_board
    display = (0...SIZE).map do |i|
      (0...SIZE).map do |j|
        convert_to_unicode(what_is_at([i,j]))
      end
    end

    display.each do |row|
      puts row.join("  ")
    end
    nil
  end

  def dup
    new_board = Board.new
    new_board.pieces = Set.new(@pieces.map{|piece| piece.dup})
    new_board
  end

  def coord_on_board?(coord)
    y, x = coord
    y.between?(0, SIZE - 1) && x.between?(0, SIZE - 1)
  end

  def kill(piece)
    @pieces.delete(piece)
  end

  def empty_or_opposite_color?(color, endpoint)
    endpoint_piece = what_is_at(endpoint)
    endpoint_piece.nil? || endpoint_piece.color != color
  end

  def empty_path?(startpoint, endpoint)
    begin
      path = path(startpoint, endpoint)
    rescue ArgumentError => e
      #puts e.message
      return false
    end
      path.all?{|pos| what_is_at(pos).nil?}
  end

  def path(startpoint, endpoint)

    path = []
    y1, x1 = startpoint
    y2, x2 = endpoint
    step = [y2 - y1, x2 - x1]
    unless step.include?(0) || step[0].abs == step[1].abs
      #p "Argument raised"
      raise ArgumentError.new "Path must call horiz, vert, or diagonal line"
    end
    magnitude = step.find {|substep| substep != 0}.abs

    step.map!{ |substep| substep / magnitude}
    (magnitude - 1).times do |step_size|
      path << [y1 + (step_size + 1) * step[0], x1 + (step_size + 1) * step[1]]
    end

    path

  end

  def convert_to_unicode(piece)
    color = piece ? piece.color : nil
    case [piece.class, color]
    when [Queen, :white]
      "♕"
    when [Queen, :black]
      "♛"
    when [Rook, :white]
      "♖"
    when [Rook, :black]
      "♜"
    when [Bishop, :white]
      "♗"
    when [Bishop, :black]
      "♝"
    when [King, :white]
      "♔"
    when [King, :black]
      "♚"
    when [Knight, :white]
      "♘"
    when [Knight, :black]
      "♞"
    when [Pawn, :white]
      "♙"
    when [Pawn, :black]
      "♟"
    when [NilClass, nil]
      "_"# "□"
    end
  end

  def in_check?(king_color)
    k_pos = @pieces.find{|piece| piece.color == king_color && piece.class == King}.position
    other_color = king_color == :black ? :white : :black
    @pieces.select{|piece| piece.color == other_color}.any? do |piece|
      temp_board = self.dup
      temp_board.move_piece(piece.position, k_pos)
      !temp_board.pieces.any?{|x| x.class == King && x.color == king_color}
    end
  end

  def in_checkmate?(king_color)
    @pieces.select {|piece| piece.color == king_color }.all? do |piece|
      piece.possible_moves.all? do |possible_move|
        #create piece-level possible_moves method
        temp_board = self.dup
        temp_board.move_piece(piece.position, possible_move)
        temp_board.in_check?(king_color)
      end
    end
  end

end

board = Board.new
board.move_piece(parse("e2"),parse("e4"))
board.display_board
puts
board.move_piece(parse("d1"),parse("h5"))
board.display_board
puts
board.move_piece(parse("f1"),parse("c4"))
board.display_board
puts
board.move_piece(parse("h5"),parse("f7"))
board.display_board
puts

puts board.in_checkmate?(:white)
puts board.in_checkmate?(:black)

# p board.move_piece([6,0], [4,0])
# puts
# puts
# p board.move_piece([7,0],[8,0])
# board.move_piece([6,0], [4,0])
# board.display_board
# board.move_piece([4,0], [3,0])
# board.display_board
# board.move_piece([3,0], [2,0])
# board.display_board
# board.move_piece([2,0], [1,1])
# board.display_board
# board.move_piece([1,1], [2,1])
