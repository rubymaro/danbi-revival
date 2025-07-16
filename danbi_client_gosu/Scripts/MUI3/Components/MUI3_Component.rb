class MUI3::Component
  attr_accessor(:root)
  attr_accessor(:parent)
  attr_accessor(:x)
  attr_accessor(:y)
  attr_accessor(:width)
  attr_accessor(:height)
  attr_accessor(:top_flag)
  attr_reader(:real_x)
  attr_reader(:real_y)

  def initialize(x:, y:, width:, height:)
    @root = self
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
    @last_mouse_x = 0
    @last_mouse_y = 0
    @mouse_over = false
    @pressed = false
    @dragged = false
    @focused = false
    @top_flag = false
    @event_handlers = {}
    [:mouse_over, :mouse_out, :mouse_down, :mouse_up, :mouse_drag, :got_focus, :lost_focus].each do |event_type|
      @event_handlers[event_type] = []
    end 
  end

  def add_child(component:)
    raise ArgumentError, "component must be an instance of MUI3::Component" unless component.is_a?(MUI3::Component)
    raise ArgumentError, "component must not be nil" if component.nil?
    
    @children << component
    component.parent = self
    root = self
    while root.parent
      root = root.parent
    end
    component.root = root
  end

  def register_event_handler(type:, proc:)
    raise ArgumentError, "type must be a Symbol" unless type.is_a?(Symbol)
    raise ArgumentError, "proc must be a Proc" unless proc.is_a?(Proc)
    @event_handlers[type] << proc
  end

  def mouse_in_rect?
    return $mui_manager.mouse_x >= @real_x &&
      $mui_manager.mouse_x < @real_x + @width &&
      $mui_manager.mouse_y >= @real_y &&
      $mui_manager.mouse_y < @real_y + @height
  end

  def update_topmost_recursive
    return if !capturable?
    return if !mouse_in_rect?
    $mui_manager.over_topmost = self
    for child in @children
      child.update_topmost_recursive
    end
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
    topmost = $mui_manager.over_topmost

    is_mouse_over = (topmost == self)
    if @mouse_over != is_mouse_over
      @mouse_over = is_mouse_over
      if is_mouse_over
        @event_handlers[:mouse_over].each { |handler| handler.call(self) }
      else
        @event_handlers[:mouse_out].each { |handler| handler.call(self) }
      end
    end

    is_mouse_button_down = Gosu.button_down?(Gosu::MS_LEFT)
    is_pressed = is_mouse_over && is_mouse_button_down
    if @pressed != is_pressed
      @pressed = is_pressed
      if is_pressed
        @event_handlers[:mouse_down].each { |handler| handler.call(self) }
      elsif !is_mouse_button_down
        @event_handlers[:mouse_up].each { |handler| handler.call(self) }
      end
    end

    # TODO: fix got_focus and lost_focus events 
    if is_mouse_over && $mui_manager.mouse_left_triggered?
      @root.top_flag = true
      @dragged = true
      @focused = true
      @event_handlers[:got_focus].each { |handler| handler.call(self) }
    elsif !is_mouse_button_down
      @dragged = false
    end

    if @dragged
      dx = $mui_manager.mouse_x - @last_mouse_x
      dy = $mui_manager.mouse_y - @last_mouse_y
      if dx != 0 || dy != 0
        @event_handlers[:mouse_drag].each { |handler| handler.call(self, dx: dx, dy: dy) }
      end
    end
    @last_mouse_x = $mui_manager.mouse_x
    @last_mouse_y = $mui_manager.mouse_y
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

  def capturable?
    return false
  end
end