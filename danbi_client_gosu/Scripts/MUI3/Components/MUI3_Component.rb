class MUI3::Component
  attr_accessor(:parent)
  attr_accessor(:x)
  attr_accessor(:y)
  attr_accessor(:width)
  attr_accessor(:height)

  def initialize(x:, y:, width:, height:)
    @parent = nil
    @children = []
    @visible = true
    @enabled = true
    @x = x
    @y = y
    @width = width
    @height = height
    @z = 0
    @pressed = false
  end

  def update
  end

  def draw(x:, y:)
    for child in @children
      child.draw(x: x + @x, y: y + @y)
    end
  end

  def add_child(component:)
    raise ArgumentError, "component must be an instance of MUI3::Component" unless component.is_a?(MUI3::Component)
    raise ArgumentError, "component must not be nil" if component.nil?
    
    @children << component
    component.parent = self
  end

  def mouse_on?
    return $mui_manager.mouse_x >= @x && $mui_manager.mouse_x < @x + @width && $mui_manager.mouse_y >= @y && $mui_manager.mouse_y < @y + @height
  end
end