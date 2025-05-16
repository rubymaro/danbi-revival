class MUI3::Form < MUI3::Component
  def initialize(x:, y:, width:, height:, style: MUI3::Style::WhiteForm)
    super(x: x, y: y, width: width, height: height)
    @skin = style.create(width: width, height: height)
  end

  def update

  end

  def draw
    @skin.draw(x: @x, y: @y)
  end
end