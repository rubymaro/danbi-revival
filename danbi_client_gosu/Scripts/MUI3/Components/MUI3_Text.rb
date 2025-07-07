class MUI3::Text < MUI3::Component
  def initialize(x:, y:, text:, font_size:)
    @font = Gosu::Font.new(font_size, name: "Malgun Gothic")
    width = @font.text_width(text)
    super(x: x, y: y, width: width, height: font_size)
    @text = text
  end

  def update
    super
  end

  def draw(x:, y:)
    @font.draw_text(@text, x + @x, y + @y, 0, 1.0, 1.0, Gosu::Color::BLACK)
  end
end