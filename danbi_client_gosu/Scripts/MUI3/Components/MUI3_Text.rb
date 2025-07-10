class MUI3::Text < MUI3::Component
  def initialize(x:, y:, width: nil, height: nil, text: "MUI3::Text#{self.object_id}", font_name: "Malgun Gothic", font_height: 20, font_color: Gosu::Color::BLACK)
    @font = Gosu::Font.new(font_height, {:name => font_name})
    width = @font.text_width(text) if width.nil?
    height = font_height if height.nil?
    super(x: x, y: y, width: width, height: height)
    @text = text
    @font_color = font_color
    @gosu_image_text = Gosu::Image.from_text(@text, @font.height, {:width => @width, :font => @font.name})
  end

  def update
  end

  def draw
    @gosu_image_text.draw(@real_x, @real_y, @z, 1, 1, @font_color)
  end
end