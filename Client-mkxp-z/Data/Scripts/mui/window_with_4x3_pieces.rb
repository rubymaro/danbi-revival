module MUI
  class WindowWith4x3Pieces < WindowBase
    module PieceIndices
      LEFT = 0; HORIZONTAL_CENTER = 1; RIGHT = 2
      TITLE = 0
      UPPER = 1
      VERTICAL_CENTER = 2
      LOWER = 3
    end

  public
    def initialize(x:, y:, width:, height:, skin_key: :default_4x3)
      super(x: x, y: y, width: width, height: height, skin_key: skin_key, piece_row_count: 4, piece_column_count: 3)
      resize(width: width, height: height)
      adjust_position
    end

    def frame_width
      return @skin.bitmap_pieces[PieceIndices::TITLE][PieceIndices::LEFT].width + @width + @skin.bitmap_pieces[PieceIndices::TITLE][PieceIndices::RIGHT].width
    end

    def frame_height
      return @skin.bitmap_pieces[PieceIndices::TITLE][PieceIndices::LEFT].height + @skin.bitmap_pieces[PieceIndices::UPPER][PieceIndices::LEFT].height + @height + @skin.bitmap_pieces[PieceIndices::LOWER][PieceIndices::LEFT].height
    end

    def resize(width:, height:)
      is_resized = super(width: width, height: height)
      if is_resized
        @button_close.x = frame_width - @button_close.width - @skin.bitmap_pieces[PieceIndices::TITLE][PieceIndices::RIGHT].width
        @button_close.y = (title_height - @button_close.height).abs / 2
      end

      return is_resized
    end

  protected
    def render_frame
      title_left   = @skin.bitmap_pieces[PieceIndices::TITLE][PieceIndices::LEFT]
      title_mid    = @skin.bitmap_pieces[PieceIndices::TITLE][PieceIndices::HORIZONTAL_CENTER]
      title_right  = @skin.bitmap_pieces[PieceIndices::TITLE][PieceIndices::RIGHT]
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
      # title
      y = 0
      bitmap.blt(0, y, title_left, title_left.rect)
      bitmap.stretch_blt(Rect.new(title_left.width, y, @width, title_mid.height), title_mid, title_mid.rect)
      bitmap.blt(title_left.width + @width, y, title_right, title_right.rect)
      # upper
      y += title_left.height
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

    def title_height
      return @skin.bitmap_pieces[PieceIndices::TITLE][PieceIndices::LEFT].height
    end

    def relative_content_x
      return @skin.bitmap_pieces[PieceIndices::TITLE][PieceIndices::LEFT].width
    end

    def relative_content_y
      return @skin.bitmap_pieces[PieceIndices::TITLE][PieceIndices::LEFT].height + @skin.bitmap_pieces[PieceIndices::UPPER][PieceIndices::LEFT].height
    end
  end
end