class MUI3::Form::Login < MUI3::Form
  def initialize
    super(x: 200, y: 200, width: 400, height: 300)

    @text = MUI3::Text.new(x: 20, y: 20, width: @width, font_size: 20, text: "로그인")
    add_child(component: @text)

    @button = MUI3::Button.new(x: 20, y: 60, width: @width - 40, height: 40, text: "로그인", image_style: MUI3::Image::BasicButton)
    add_child(component: @button)
  end
end