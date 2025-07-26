class MUI3::InputBox < MUI3::Component
  DEFAULT = 0
  FOCUSED = 1
  DISABLED = 2
  PADDING = 4

  attr_reader(:gosu_text_input)

  def initialize(x:, y:, width:, height:, text: "", image_style: MUI3::Image::InputBoxSet)
    super(x: x, y: y, width: width, height: height)
    @gosu_text_input = Gosu::TextInput.new
    @image_input_box_set = image_style.create(x: 0, y: 0, width: width, height: height)
    add_child(component: @image_input_box_set)
    @text_input = MUI3::Text.new(x: PADDING, y: PADDING, text: text, width: width - PADDING * 2, align: :left, font_color: Gosu::Color::BLACK)
    add_child(component: @text_input)
    proc_got_focus = proc {
      $mui_manager.set_input_box(input_box: self)
      @image_input_box_set.subimage!(ox: 0, oy: @height * FOCUSED, width: @width, height: @height)
    }
    proc_lost_focus = proc {
      $mui_manager.set_input_box(input_box: nil)
      @image_input_box_set.subimage!(ox: 0, oy: @height * DEFAULT, width: @width, height: @height)
    }
    register_event_handler(type: :got_focus, proc: proc_got_focus)
    register_event_handler(type: :lost_focus, proc: proc_lost_focus)
  end

  def update
    if @text_input.text.length != @gosu_text_input.text.length
      @text_input.text = @gosu_text_input.text
    end
  end

  def draw
  end

  def capturable?
    return true
  end
end