class MUI3::Form::Test < MUI3::Form
  def initialize
    super(x: 200, y: 200, width: 400, height: 300)

    @text = MUI3::Text.new(x: 20, y: 20, text: "Hello, MUI3!")
    add_child(component: @text)
  end
end