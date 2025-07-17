class MUI3::InputBox < MUI3::Component
  attr_reader(:gosu_text_input)

  def initialize(x:, y:, width:, height:, text: "", image_style: MUI3::Image::InputBoxSet)
    super(x: x, y: y, width: width, height: height)
    @text = text
    @gosu_text_input = Gosu::TextInput.new
    @image_bg = image_style.create(x: 0, y: 0, width: width, height: height)
    add_child(component: @image_bg)
    @text_caption = MUI3::Text.new(x: 0, y: 0, text: text, width: width, align: :left, font_color: Gosu::Color::BLACK)
    add_child(component: @text_caption)
    proc_got_focus = proc {
      $mui_manager.set_input_box(input_box: self)
    }
    proc_lost_focus = proc {
      $mui_manager.set_input_box(input_box: nil)
    }
    register_event_handler(type: :got_focus, proc: proc_got_focus)
    register_event_handler(type: :lost_focus, proc: proc_lost_focus)
  end

  def update
  end

  def draw
  end

  def capturable?
    return true
  end
end