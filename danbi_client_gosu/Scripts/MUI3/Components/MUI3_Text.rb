class MUI3::Text < MUI3::Component
  def initialize(x:, y:, width: nil, height: nil, text: "MUI3::Text#{self.object_id}", font_name: "Malgun Gothic", font_size: 20, font_color: Gosu::Color::BLACK)
    @font = Gosu::Font.new(font_size, {:name => font_name})
    width = @font.text_width(text) if width.nil?
    height = font_size if height.nil?
    super(x: x, y: y, width: width, height: height)
    @text = text
    @font_color = font_color

    @image_text = Gosu::Image.from_text(@text, @height, {:width => @width, :font => @font.name})
  end

  def update
  end

  def draw
    @image_text.draw(@real_x, @real_y, @z, 1, 1, @font_color)
    super
  end
end