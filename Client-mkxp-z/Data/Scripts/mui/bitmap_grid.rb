module MUI
  class BitmapGrid
    attr_reader :row_count
    attr_reader :column_count

    def initialize(row_count:, column_count:, offset_x:, offset_y:, rects:)
      raise "row_count는 양수만 가능합니다." if row_count <= 0
      raise "column_count는 양수만 가능합니다." if column_count <= 0
      raise "rect의 현재 개수(#{rects.length})가 필요 개수(#{row_count * column_count})보다 적습니다." if rects.length < row_count * column_count
      raise "rect의 현재 개수(#{rects.length})가 필요 개수(#{row_count * column_count})보다 많습니다." if rects.length > row_count * column_count

      @row_count = row_count
      @column_count = column_count
      @offset_x = offset_x
      @offset_y = offset_y
      @rects = rects
    end

    def create_splitted_bitmaps(bitmap_src:)
      bitmaps = Array.new(@row_count) { Array.new(@column_count) }
      for i in 0...@rects.length
        r = i / @column_count
        c = i % @column_count
        rect = @rects[i]
        new_bitmap = Bitmap.new(rect.width, rect.height)
        new_bitmap.blt(0, 0, bitmap_src, Rect.new(@offset_x + rect.x, @offset_y + rect.y, rect.width, rect.height))
        bitmaps[r][c] = new_bitmap
      end

      return bitmaps
    end
  end
end