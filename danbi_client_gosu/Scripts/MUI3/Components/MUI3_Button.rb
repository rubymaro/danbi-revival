class MUI3::Button < MUI3::Component
  DEFAULT = 0
  MOUSE_OVER = 1
  MOUSE_PRESSED = 2
  DISABLED = 3

  def initialize(x:, y:, width:, height:, text:, style: MUI3::Style::BasicButton)
    super(x: x, y: y, width: width, height: height)
    @text = text
    @state_styles = [
      style.create(x: 0, y: 0, width: width, height: height, index: DEFAULT),
      style.create(x: 0, y: 0, width: width, height: height, index: MOUSE_OVER),
      style.create(x: 0, y: 0, width: width, height: height, index: MOUSE_PRESSED),
      style.create(x: 0, y: 0, width: width, height: height, index: DISABLED)
    ]
    for style in @state_styles
      add_child(component: style)
    end
  end

  def update
    super
  end

  def draw
    if @mouse_on
      @state_styles[MOUSE_OVER].draw
    else
      @state_styles[DEFAULT].draw
    end
    super
  end
end