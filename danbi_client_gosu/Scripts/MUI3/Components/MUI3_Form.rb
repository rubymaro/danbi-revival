class MUI3::Form < MUI3::Component
  def initialize(x:, y:, width:, height:, image_style: MUI3::Image::WhiteForm)
    super(x: x, y: y, width: width, height: height)
    @dragged = false
    @image_bg = image_style.create(x: 0, y: 0, width: width, height: height)
    add_child(component: @image_bg)
    proc_mouse_drag = proc { |component, dx:, dy:|
      @x += dx
      @y += dy
    }
    register_event_handler(type: :mouse_drag, proc: proc_mouse_drag)
  end

  def update
    
  end

  def draw
  end

  def capturable?
    return true
  end
end