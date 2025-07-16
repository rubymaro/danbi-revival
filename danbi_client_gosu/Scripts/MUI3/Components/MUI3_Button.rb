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
    proc_mouse_over = proc {
      @image_buttonset.subimage!(x: 0, y: @height * MOUSE_OVER, width: @width, height: @height)
    }
    proc_mouse_out = proc {
      @image_buttonset.subimage!(x: 0, y: @height * DEFAULT, width: @width, height: @height)
    }
    proc_mouse_down = proc {
      @image_buttonset.subimage!(x: 0, y: @height * MOUSE_PRESSED, width: @width, height: @height)
    }
    proc_mouse_up = proc {
      @image_buttonset.subimage!(x: 0, y: @height * MOUSE_OVER, width: @width, height: @height)
    }
    register_event_handler(type: :mouse_over, proc: proc_mouse_over)
    register_event_handler(type: :mouse_out, proc: proc_mouse_out)
    register_event_handler(type: :mouse_down, proc: proc_mouse_down)
    register_event_handler(type: :mouse_up, proc: proc_mouse_up)
  end

  def update
  end

  def draw
  end

  def capturable?
    return true
  end
end