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
    @event_handlers = { :mouse_over => [], :mouse_out => [], :mouse_down => [], :mouse_up => [] }
  end

  def add_child(component:)
    raise ArgumentError, "component must be an instance of MUI3::Component" unless component.is_a?(MUI3::Component)
    raise ArgumentError, "component must not be nil" if component.nil?
    
    @children << component
    component.parent = self
  end

  def register_event_handler(type:, proc:)
    raise ArgumentError, "type must be a Symbol" unless type.is_a?(Symbol)
    raise ArgumentError, "proc must be a Proc" unless proc.is_a?(Proc)
    @event_handlers[type] ||= []
    @event_handlers[type] << proc
  end

  def mouse_on?
    return $mui_manager.mouse_x >= @real_x &&
      $mui_manager.mouse_x < @real_x + @width &&
      $mui_manager.mouse_y >= @real_y &&
      $mui_manager.mouse_y < @real_y + @height
  end

  def update_all
    pre_update
    update
    post_update
  end

  def draw_all
    draw
    post_draw
  end

  protected def pre_update
    mouse_on = mouse_on?
    if @mouse_on != mouse_on
      if mouse_on == true
        @event_handlers[:mouse_over].each { |handler| handler.call(self) } 
      else
        @event_handlers[:mouse_out].each { |handler| handler.call(self) }
      end
      @mouse_on = mouse_on
    end

    pressed = @mouse_on && Gosu.button_down?(Gosu::MS_LEFT)
    if @pressed != pressed
      if pressed == true
        @event_handlers[:mouse_down].each { |handler| handler.call(self) }
      else
        @event_handlers[:mouse_up].each { |handler| handler.call(self) }
      end
      @pressed = pressed
    end
  end

  protected def update
    raise NotImplementedError, "You must implement the update method in your subclass #{self.class.name}"
  end

  protected def post_update
    @real_x = @parent.nil? ? @x : @parent.real_x + @x
    @real_y = @parent.nil? ? @y : @parent.real_y + @y
    for child in @children
      child.update_all
    end
  end

  protected def draw
    raise NotImplementedError, "You must implement the draw method in your subclass #{self.class.name}"
  end

  protected def post_draw
    for child in @children
      child.draw_all
    end
  end
end