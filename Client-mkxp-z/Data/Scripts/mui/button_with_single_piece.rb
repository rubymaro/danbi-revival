module MUI
  class ButtonWithSinglePiece < ButtonBase
    module PieceIndices
      SINGLE = 0
    end

  public
    def initialize(x:, y:, width:, height:, skin_key:)
      super(x: x, y: y, width: width, height: height, skin_key: skin_key, piece_row_count: 1, piece_column_count: 1)
    end

    def resize(width:, height:)
      return if @width == width && @height == height
      
      super(width: width, height: height)
      render
    end

  private
    def render
      for i in 0...State::Length
        y = @height * i
        one_image = @skins[i].bitmap_pieces[PieceIndices::SINGLE][PieceIndices::SINGLE]
        @bitmap.stretch_blt(Rect.new(0, y, @width, @height), one_image, one_image.rect)
      end
    end
  end
end