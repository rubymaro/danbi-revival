class MUI3::Form < MUI3::Component
  def initialize(x:, y:, width:, height:, image_style: MUI3::Image::WhiteForm)
    super(x: x, y: y, width: width, height: height)
    @image_bg = image_style.create(x: 0, y: 0, width: width, height: height)
    add_child(component: @image_bg)
  end

  def update
    if @pressed
      @last_mouse_x ||= $mui_manager.mouse_x
      @last_mouse_y ||= $mui_manager.mouse_y

      dx = $mui_manager.mouse_x - @last_mouse_x
      dy = $mui_manager.mouse_y - @last_mouse_y
      @x += dx
      @y += dy
      @last_mouse_x = $mui_manager.mouse_x
      @last_mouse_y = $mui_manager.mouse_y
    else
      @last_mouse_x = nil
      @last_mouse_y = nil
    end
  end

  def draw
    @image_bg.draw
    super
  end
end