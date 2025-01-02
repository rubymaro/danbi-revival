module MUI
  class WindowWith3x3Pieces < WindowBase
    module PieceIndices
      LEFT = 0; HORIZONTAL_CENTER = 1; RIGHT = 2
      UPPER = 0
      VERTICAL_CENTER = 1
      LOWER = 2
    end

  public
    def initialize(x:, y:, width:, height:, skin_key: :white_skin_window_3x3)
      super(x: x, y: y, width: width, height: height, skin_key: skin_key, piece_row_count: 3, piece_column_count: 3)
      resize(width: width, height: height)
      adjust_position
    end

    def frame_width
      return @skin.bitmap_pieces[PieceIndices::UPPER][PieceIndices::LEFT].width + @width + @skin.bitmap_pieces[PieceIndices::UPPER][PieceIndices::RIGHT].width
    end

    def frame_height
      return @skin.bitmap_pieces[PieceIndices::UPPER][PieceIndices::LEFT].height + @height + @skin.bitmap_pieces[PieceIndices::LOWER][PieceIndices::LEFT].height
    end

    def resize(width:, height:)
      is_resized = super(width: width, height: height)
      if is_resized
        @button_close.x = frame_width - @button_close.width - @skin.bitmap_pieces[PieceIndices::UPPER][PieceIndices::RIGHT].width
        @button_close.y = (relative_content_y - @button_close.height).abs / 2
      end

      return is_resized
    end

  protected
    def render_frame
      upper_left   = @skin.bitmap_pieces[PieceIndices::UPPER][PieceIndices::LEFT]
      upper_mid    = @skin.bitmap_pieces[PieceIndices::UPPER][PieceIndices::HORIZONTAL_CENTER]
      upper_right  = @skin.bitmap_pieces[PieceIndices::UPPER][PieceIndices::RIGHT]
      center_left  = @skin.bitmap_pieces[PieceIndices::VERTICAL_CENTER][PieceIndices::LEFT]
      center_mid   = @skin.bitmap_pieces[PieceIndices::VERTICAL_CENTER][PieceIndices::HORIZONTAL_CENTER]
      center_right = @skin.bitmap_pieces[PieceIndices::VERTICAL_CENTER][PieceIndices::RIGHT]
      lower_left   = @skin.bitmap_pieces[PieceIndices::LOWER][PieceIndices::LEFT]
      lower_mid    = @skin.bitmap_pieces[PieceIndices::LOWER][PieceIndices::HORIZONTAL_CENTER]
      lower_right  = @skin.bitmap_pieces[PieceIndices::LOWER][PieceIndices::RIGHT]

      bitmap = @sprite_frame.bitmap
      # upper
      y = 0
      bitmap.blt(0, y, upper_left, upper_left.rect)
      bitmap.stretch_blt(Rect.new(upper_left.width, y, @width, upper_mid.height), upper_mid, upper_mid.rect)
      bitmap.blt(upper_left.width + @width, y, upper_right, upper_right.rect)
      # center
      y += upper_left.height
      bitmap.stretch_blt(Rect.new(0, y, center_left.width, @height), center_left, center_left.rect)
      bitmap.stretch_blt(Rect.new(center_left.width, y, @width, @height), center_mid, center_mid.rect)
      bitmap.stretch_blt(Rect.new(center_left.width + @width, y, center_right.width, @height), center_right, center_right.rect)
      # lower
      y += @height
      bitmap.blt(0, y, lower_left, lower_left.rect)
      bitmap.stretch_blt(Rect.new(lower_left.width, y, @width, lower_mid.height), lower_mid, lower_mid.rect)
      bitmap.blt(lower_left.width + @width, y, lower_right, lower_right.rect)
    end

    def relative_content_x
      return @skin.bitmap_pieces[PieceIndices::UPPER][PieceIndices::LEFT].width
    end

    def relative_content_y
      return @skin.bitmap_pieces[PieceIndices::UPPER][PieceIndices::LEFT].height
    end
  end
end