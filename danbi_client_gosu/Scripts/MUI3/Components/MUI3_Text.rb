class MUI3::Text < MUI3::Component
  def initialize(x:, y:, width:, font_size:, text: "MUI3::Text")
    super(x: x, y: y, width: width, height: font_size)
    @text = text
    @image_text = Gosu::Image.from_text(@text, @height, {:width => @width, :font => "Malgun Gothic"})
  end

  def update
    super
  end

  def draw(x:, y:)
    @image_text.draw(x + @x, y + @y, 0, 1, 1, Gosu::Color::BLACK)
  end
end