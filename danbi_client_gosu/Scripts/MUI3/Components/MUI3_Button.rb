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
    @text_caption = MUI3::Text.new(x: 0, y: 0, text: text, width: width, align: :center, font_color: Gosu::Color::WHITE)
    @text_caption.y += (@height - @text_caption.height) / 2
    add_child(component: @text_caption)
    register_event_handler(type: :mouse_over, proc: proc { @image_buttonset.subimage!(x: 0, y: @height * MOUSE_OVER, width: @width, height: @height) })
    register_event_handler(type: :mouse_out, proc: proc { @image_buttonset.subimage!(x: 0, y: @height * DEFAULT, width: @width, height: @height) })
  end

  def update
  end

  def draw
  end
end