class MUI3::Form < MUI3::Component
  def initialize(x:, y:, width:, height:, image_style: MUI3::Image::WhiteForm)
    super(x: x, y: y, width: width, height: height)
    @dragged = false
    @last_mouse_x = 0
    @last_mouse_y = 0
    @image_bg = image_style.create(x: 0, y: 0, width: width, height: height)
    add_child(component: @image_bg)
  end

  def update
    if $mui_manager.mouse_left_triggered? && @mouse_on
      @dragged = true
    elsif !Gosu.button_down?(Gosu::MS_LEFT)
      @dragged = false
    end

    if @dragged
      dx = $mui_manager.mouse_x - @last_mouse_x
      dy = $mui_manager.mouse_y - @last_mouse_y
      @x += dx
      @y += dy
    end
    @last_mouse_x = $mui_manager.mouse_x
    @last_mouse_y = $mui_manager.mouse_y
  end

  def draw
  end
end