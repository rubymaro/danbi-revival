class MUI3::Text < MUI3::Component
  def initialize(x:, y:, text:)
    @font = Gosu::Font.new(20, name: "NanumGothic")
    width = @font.text_width(text)
    super(x: x, y: y, width: width, height: 20)
    @text = text
  end

  def update
    super()
  end

  def draw(parent_x, parent_y)
    @font.draw_text(@text, parent_x + @x, parent_y + @y, 0, 1.0, 1.0, Gosu::Color::BLACK)
  end
end