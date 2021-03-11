module MUI  
  class Label < Control

    attr_accessor :text
    attr_accessor :alignment
    attr_reader :font
    attr_accessor :background_color
    attr_accessor :is_multiline

    def initialize(x:, y:, width:, height:, text: "#{self.class}", is_multiline: false)
      super(x: x, y: y, width: width, height: height)
      @text = text
      @is_multiline = is_multiline
      @font = Font.new("NanumGothic")
      @font.color = Colors::BLACK.dup
      @background_color = Colors::TRANSPARENT.dup
      @alignment = AlignmentFlags::UPPER | AlignmentFlags::LEFT
    end

    def on_creating(window:, viewport:)
      super(window: window, viewport: viewport)
      width = @width
      height = @height
      @width = -1 # for calling resize successfully
      resize(width: width, height: height)
    end

    def resize(**args)
      width_or_nil = args[:width]
      height_or_nil = args[:height]

      if nil != width_or_nil && nil != height_or_nil
        is_resized = super(width: width_or_nil, height: height_or_nil)
        if is_resized
          @bitmap.dispose if nil != @bitmap && !@bitmap.disposed?
          @bitmap = nil
          if @is_multiline
            @out_ranges = []
            @bitmap = Bitmap.create(@out_ranges, @text, @font, width_or_nil, height_or_nil)
          else
            @bitmap = Bitmap.new(width_or_nil, height_or_nil)
          end
        else
          return false
        end
      else
        @bitmap.dispose if nil != @bitmap && !@bitmap.disposed?
        @bitmap = nil

        if @is_multiline
          @out_ranges = []
          @bitmap = Bitmap.create(@out_ranges, @text, @font, width_or_nil, height_or_nil)
          width_or_nil ||= @bitmap.width
          height_or_nil ||= @bitmap.height
        else
          rect = Bitmap.text_size(@text, @font)
          width_or_nil ||= rect.width
          height_or_nil ||= rect.height
          @bitmap = Bitmap.new(width_or_nil, height_or_nil)
        end

        super(width: width_or_nil, height: height_or_nil)
      end

      @bitmap.font = @font
      render
      @sprite.bitmap = @bitmap

      return true
    end

    def horizontal_alignment
      return @alignment & 0b11
    end

    def vertical_alignment
      return @alignment & 0b1100
    end

    def text=(string)
      @text = string
      @out_ranges = []
      if @is_multiline
        @bitmap.dispose if nil != @bitmap && !@bitmap.disposed?
        @bitmap = nil
        @bitmap = Bitmap.create(@out_ranges, @text, @font, @width, @height)
        @sprite.bitmap = @bitmap if nil != @sprite
      end
    end

    def font=(font)
      @font = font
      @bitmap.font = font
    end

    def text_width
      return @bitmap.text_size(@text).width
    end

    def text_height
      return @font.size
    end

    def render
      @bitmap.font = @font
      @bitmap.clear
      @bitmap.fill_rect(0, 0, @width, @height, @background_color)

      if @is_multiline
        determined_height = @font.size * @out_ranges.length
        y = case vertical_alignment
        when AlignmentFlags::UPPER
          0
        when AlignmentFlags::VERTICAL_CENTER
          (@bitmap.height - determined_height) / 2
        when AlignmentFlags::LOWER
          @bitmap.height - determined_height
        else
          raise "invalid alignment (#{vertical_alignment})"
        end
        for range in @out_ranges
          if y + @font.size > 0 && y < @bitmap.height
            @bitmap.draw_text(0, y, @bitmap.width, @font.size, @text[range], horizontal_alignment)
          end
          y += @font.size
        end

      else
        y = case vertical_alignment
        when AlignmentFlags::UPPER
          0
        when AlignmentFlags::VERTICAL_CENTER
          (@height - @font.size) / 2
        when AlignmentFlags::LOWER
          @height - @font.size
        else
          raise "invalid alignment (#{vertical_alignment})"
        end
        @bitmap.draw_text(0, y, @width, @font.size, @text, horizontal_alignment)
      end
    end
  end
end