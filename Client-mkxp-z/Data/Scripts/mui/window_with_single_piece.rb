module MUI
  class WindowWithSinglePiece < WindowBase
    module PieceIndices
      SINGLE = 0
    end

  public
    def initialize(x:, y:, width:, height:, skin_key:)
      super(x: x, y: y, width: width, height: height, skin_key: skin_key, piece_row_count: 1, piece_column_count: 1)
      resize(width: width, height: height)
      adjust_position
    end

    def resize(width:, height:)
      is_resized = super(width: width, height: height)
      if is_resized
        close_button_offset = (title_height - @button_close.height).abs / 2
        @button_close.x = frame_width - @button_close.width - close_button_offset
        @button_close.y = close_button_offset
      end
      
      return is_resized
    end
    
    def frame_width
      return @width
    end

    def frame_height
      return @height
    end

  protected
    def render_frame
      one_image = @skin.bitmap_pieces[PieceIndices::SINGLE][PieceIndices::SINGLE]
      @sprite_frame.bitmap.stretch_blt(Rect.new(0, 0, @width, @height), one_image, one_image.rect)
    end

    def title_height
      return 24
    end

    def relative_content_x
      return 0
    end

    def relative_content_y
      return 0
    end
  end
end