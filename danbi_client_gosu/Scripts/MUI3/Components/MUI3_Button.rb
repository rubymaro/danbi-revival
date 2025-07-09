class MUI3::Button < MUI3::Component
  def initialize(x:, y:, width:, height:, text:, style: MUI3::Style::BasicButton)
    super(x: x, y: y, width: width, height: height)
    @text = text
    @state_styles = [
      style.create(width: width, height: height, index: style::DEFAULT),
      style.create(width: width, height: height, index: style::MOUSE_OVER),
      style.create(width: width, height: height, index: style::MOUSE_PRESSED),
      style.create(width: width, height: height, index: style::DISABLED)
    ]
  end

  def update
    super
  end

  def draw(x:, y:)
    for i in 0...@state_styles.size
      @state_styles[i].draw(x: x + @x, y: y + @y + i * @height)
    end
  end
end