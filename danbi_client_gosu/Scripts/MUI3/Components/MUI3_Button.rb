class MUI3::Button < MUI3::Component
  DEFAULT = 0
  MOUSE_OVER = 1
  MOUSE_PRESSED = 2
  DISABLED = 3

  def initialize(x:, y:, width:, height:, text:, image_style: MUI3::Image::BasicButtonSet)
    super(x: x, y: y, width: width, height: height)
    @text = text
    @image_buttonset = image_style.create(x: 0, y: 0, width: width, height: height)
    add_child(component: @image_buttonset)
  end

  def update
    super
  end

  def draw
    super
  end
end