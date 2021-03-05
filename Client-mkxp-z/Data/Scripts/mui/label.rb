module MUI  
  class Label < Control
    module AlignmentFlags
      LEFT = 0; HORIZONTAL_CENTER = 1; RIGHT = 2
      UPPER = 0
      VERTICAL_CENTER = 4
      LOWER = 8
    end

    attr_accessor :text
    attr_accessor :alignment
    attr_reader :font
    attr_accessor :background_color

    def initialize(x:, y:, width:, height:, text: "#{self.class}")
      super(x: x, y: y, width: width, height: height)
      @text = text
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

    def resize(width:, height:)
      is_resized = super(width: width, height: height)
      if is_resized
        @bitmap.dispose if nil != @bitmap && !@bitmap.disposed?
        @bitmap = nil
        @bitmap = Bitmap.new(width, height)
        @bitmap.font = @font
        render
        @sprite.bitmap = @bitmap
        @sprite.src_rect.set(0, 0, @width, @height)
      end

      return is_resized
    end

    def horizontal_alignment
      return @alignment & 0b11
    end

    def vertical_alignment
      return @alignment & 0b1100
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
      @bitmap.clear
      @bitmap.fill_rect(0, 0, @width, @height, @background_color)
      @bitmap.font = @font
      @bitmap.draw_text(0, y, @width, @font.size, @text, horizontal_alignment)
    end
  end
end