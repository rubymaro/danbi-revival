module MUI
  class ButtonWith3x3Pieces < ButtonBase
    module PieceIndices
      LEFT = 0; HORIZONTAL_CENTER = 1; RIGHT = 2
      UPPER = 0
      VERTICAL_CENTER = 1
      LOWER = 2
    end

  public
    def initialize(x:, y:, width:, height:, skin_key: :white_skin_button_4x3)
      super(x: x, y: y, width: width, height: height, skin_key: skin_key, piece_row_count: 3, piece_column_count: 3)
    end

  protected
    def render
      for i in 0...State::Length
        skin = @skins[i]
        upper_left   = skin.bitmap_pieces[PieceIndices::UPPER][PieceIndices::LEFT]
        upper_mid    = skin.bitmap_pieces[PieceIndices::UPPER][PieceIndices::HORIZONTAL_CENTER]
        upper_right  = skin.bitmap_pieces[PieceIndices::UPPER][PieceIndices::RIGHT]
        center_left  = skin.bitmap_pieces[PieceIndices::VERTICAL_CENTER][PieceIndices::LEFT]
        center_mid   = skin.bitmap_pieces[PieceIndices::VERTICAL_CENTER][PieceIndices::HORIZONTAL_CENTER]
        center_right = skin.bitmap_pieces[PieceIndices::VERTICAL_CENTER][PieceIndices::RIGHT]
        lower_left   = skin.bitmap_pieces[PieceIndices::LOWER][PieceIndices::LEFT]
        lower_mid    = skin.bitmap_pieces[PieceIndices::LOWER][PieceIndices::HORIZONTAL_CENTER]
        lower_right  = skin.bitmap_pieces[PieceIndices::LOWER][PieceIndices::RIGHT]

        # upper
        y = @height * i
        @bitmap.blt(0, y, upper_left, upper_left.rect)
        @bitmap.stretch_blt(Rect.new(upper_left.width, y, @width - upper_left.width - upper_right.width, upper_mid.height), upper_mid, upper_mid.rect)
        @bitmap.blt(@width - upper_right.width, y, upper_right, upper_right.rect)
        # center
        y += upper_left.height
        @bitmap.stretch_blt(Rect.new(0, y, center_left.width, @height - upper_left.height - lower_left.height), center_left, center_left.rect)
        @bitmap.stretch_blt(Rect.new(center_left.width, y, @width - center_left.width - center_right.width, @height - upper_mid.height - lower_mid.height), center_mid, center_mid.rect)
        @bitmap.stretch_blt(Rect.new(@width - center_right.width, y, center_right.width, @height - upper_right.height - lower_right.height), center_right, center_right.rect)
        # lower
        y += @height - upper_left.height - lower_left.height
        @bitmap.blt(0, y, lower_left, lower_left.rect)
        @bitmap.stretch_blt(Rect.new(lower_left.width, y, @width - lower_left.width - lower_right.width, lower_mid.height), lower_mid, lower_mid.rect)
        @bitmap.blt(@width - lower_right.width, y, lower_right, lower_right.rect)
      end
    end
  end
end