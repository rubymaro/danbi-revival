class MUI3::Form::Login < MUI3::Form
  def initialize(x: 200)
    super(x: x, y: 200, width: 400, height: 300)

    @text_input = MUI3::Text.new(x: 20, y: 20, width: @width, font_height: 20, text: "로그인")
    add_child(component: @text_input)

    @button = MUI3::Button.new(x: 20, y: 60, width: @width - 40, height: 40, text: "로그인", image_style: MUI3::Image::BasicButtonSet)
    add_child(component: @button)

    @input_box = MUI3::InputBox.new(x: 20, y: 120, width: @width - 40, height: 30)
    add_child(component: @input_box)
  end
end