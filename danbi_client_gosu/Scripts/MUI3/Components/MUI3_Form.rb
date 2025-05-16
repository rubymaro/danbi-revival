class MUI3::Form < MUI3::Component
  def initialize(x:, y:, width:, height:)
    super(x: x, y: y, width: width, height: height)
    @skin = MUI3::Style::WhiteForm.create(width: width, height: height)
  end

  def update

  end

  def draw
    @skin.draw(x: @x, y: @y)
  end
end