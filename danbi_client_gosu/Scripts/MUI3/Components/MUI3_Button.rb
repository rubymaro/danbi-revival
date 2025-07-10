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
    @text_caption = MUI3::Text.new(x: 0, y: 0, text: text)
    add_child(component: @text_caption)
  end

  def update
    if @mouse_on
      @image_buttonset.subimage!(x: 0, y: @height * MOUSE_OVER, width: @width, height: @height)
    else
      @image_buttonset.subimage!(x: 0, y: @height * DEFAULT, width: @width, height: @height)
    end
  end

  def draw
  end
end