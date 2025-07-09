class MUI3::Component
  attr_accessor(:parent)
  attr_accessor(:x)
  attr_accessor(:y)
  attr_accessor(:width)
  attr_accessor(:height)
  attr_reader(:real_x)
  attr_reader(:real_y)

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
    @real_x = 0
    @real_y = 0
    @mouse_on = false
    @pressed = false
  end

  def update
    @mouse_on = mouse_on?
    if @mouse_on && $mui_manager.mouse_left_triggered?
      @pressed = true
    elsif !Gosu.button_down?(Gosu::MS_LEFT)
      @pressed = false
    end
    for child in @children
      child.update
    end
    @real_x = @parent.nil? ? @x : @parent.real_x + @x
    @real_y = @parent.nil? ? @y : @parent.real_y + @y
  end

  def draw
    for child in @children
      child.draw
    end
  end

  def add_child(component:)
    raise ArgumentError, "component must be an instance of MUI3::Component" unless component.is_a?(MUI3::Component)
    raise ArgumentError, "component must not be nil" if component.nil?
    
    @children << component
    component.parent = self
  end

  def mouse_on?
    return $mui_manager.mouse_x >= @real_x &&
      $mui_manager.mouse_x < @real_x + @width &&
      $mui_manager.mouse_y >= @real_y &&
      $mui_manager.mouse_y < @real_y + @height
  end
end