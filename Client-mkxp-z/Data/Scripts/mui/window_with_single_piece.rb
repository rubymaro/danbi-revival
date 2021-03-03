module MUI
  class WindowWithSinglePiece < WindowBase
    module PieceIndices
      SINGLE = 0
    end

  public
    def initialize(x:, y:, width:, height:, skin_key:)
      super(x: x, y: y, width: width, height: height, skin_key: skin_key, piece_row_count: 1, piece_column_count: 1)
      resize
      adjust_position
      create_bitmap
      render_frame
      hide
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
      bitmap = @sprite_frame.bitmap
      bitmap.stretch_blt(Rect.new(0, 0, @width, @height), one_image, one_image.rect)
    end

    def resize
      @viewport_frame.rect.width = @width
      @viewport_frame.rect.height = @height
      @viewport_content.rect.width = @width
      @viewport_content.rect.height = @height
    end

    def adjust_position
      @viewport_frame.rect.x = @x
      @viewport_frame.rect.y = @y
      @viewport_content.rect.x = @x
      @viewport_content.rect.y = @y
    end

    def title_height
      return @skin.bitmap_pieces[PieceIndices::SINGLE][PieceIndices::SINGLE].height
    end
  end
end