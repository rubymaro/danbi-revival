class MUI3::Text < MUI3::Component
  attr_accessor(:text)

  def initialize(x:, y:, width: nil, text: "MUI3::Text#{self.object_id}",
    font_name: Config::FONT_NAME, font_height: Config::FONT_HEIGHT, font_color: Gosu::Color::BLACK, align: :left)
    @gosu_font = Gosu::Font.new(font_height, {:name => font_name})
    width ||= @gosu_font.text_width(text)
    @align = align
    @text = text
    @font_color = font_color
    @min_char_width = [@gosu_font.text_width(".") - 1, 1].max
    super(x: x, y: y, width: width, height: font_height)
    update_image_text
  end

  def update
  end

  def update_image_text
    # TODO: optimize text rendering width by reducing text length
    reduced_text = @text[-(@width / @min_char_width).to_i..-1] || @text
    @gosu_image_text = Gosu::Image.from_text(reduced_text, @gosu_font.height, {:font => @gosu_font.name})
    if @gosu_image_text.width <= 0 || @gosu_image_text.height <= 0
      @gosu_subimage_text = @gosu_image_text
      return
    end
    
    case @align
    when :left
      if @gosu_image_text.width <= @width
        @gosu_subimage_text = @gosu_image_text.subimage(0, 0, [@width, @gosu_image_text.width].min, @gosu_font.height)
      else
        @gosu_subimage_text = @gosu_image_text.subimage([@gosu_image_text.width - @width, 0].max, 0, @width, @gosu_font.height)
      end
      
    when :right
      @gosu_subimage_text = @gosu_image_text.subimage([@gosu_image_text.width - @width, 0].max, 0, @width, @gosu_font.height)

    when :center
      if @gosu_image_text.width >= @width
        @gosu_subimage_text = @gosu_image_text.subimage((@gosu_image_text.width - @width) / 2, 0, @width, @gosu_font.height)
      else
        @gosu_image_text = Gosu::Image.from_text(reduced_text, @gosu_font.height, {:width => @width, :font => @gosu_font.name, :align => @align})
        @gosu_subimage_text = @gosu_image_text
      end
    end
  end

  def draw
    @gosu_subimage_text.draw(@real_x, @real_y, @z, 1, 1, @font_color)
  end
end