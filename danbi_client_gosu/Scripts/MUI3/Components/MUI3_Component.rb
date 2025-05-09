class MUI3::Component
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
  end

  def update

  end

  def draw
    raise NotImplementedError, "You must implement the draw method"
  end

  def add_child(component:)
    raise ArgumentError, "component must be an instance of MUI3::Component" unless component.is_a?(MUI3::Component)
    raise ArgumentError, "component must not be nil" if component.nil?
    
    @children << component
    component.parent = self
  end
end