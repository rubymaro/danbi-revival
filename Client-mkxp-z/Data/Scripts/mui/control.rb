module MUI
  class Control
    class << self
      alias_method :control_new, :new
      
      def new(**args)
        raise "#{self}는 인스턴스화 할 수 없습니다." if self == MUI::Control
        control_new(**args)
      end
    end

    attr_reader :x
    attr_reader :y
    attr_reader :z
    attr_reader :width
    attr_reader :height
    attr_reader :visible

    attr_accessor :state_mouse_over

    attr_accessor :handler_got_focus
    attr_accessor :handler_lost_focus
    attr_accessor :handler_mouse_over
    attr_accessor :handler_mouse_out
    attr_accessor :handler_mouse_down
    attr_accessor :handler_mouse_up
    attr_accessor :handler_mouse_dragging

  public
    def initialize(x:, y:, width:, height:)
      @x = x
      @y = y
      @z = 0
      @width = width
      @height = height
      @visible = true

      @state_mouse_over = false

      @bitmap = nil

      @is_added = false
    end

    def on_creating(window:, viewport:)
      raise "같은 컨트롤을 2번 이상 추가할 수 없습니다." if @is_added
      @is_added = true
      
      @parent_window = window
      @sprite = Sprite.new(viewport)
      @sprite.bitmap = @bitmap
      @sprite.x = @x
      @sprite.y = @y
      @sprite.z = @z
      @sprite.visible = @visible
    end

    def x=(integer)
      @x = integer
      @sprite.x = @x if nil != @sprite
    end

    def y=(integer)
      @y = integer
      @sprite.y = @y if nil != @sprite
    end

    def z=(integer)
      @z = integer
      @sprite.z = @z if nil != @sprite
    end

    def visible=(bool)
      @visible = bool
      @sprite.visible = @visible if nil != @sprite
      @state_mouse_over = false
    end

    def point_in_sprite?(x:, y:)
      return x >= real_x && x < real_x + @width && y >= real_y && y < real_y + @height
    end

    def real_x
      return @x + @sprite.viewport.rect.x
    end

    def real_y
      return @y + @sprite.viewport.rect.y
    end

    def resize(width:, height:)
      return if @width == width && @height == height

      @width = width
      @height = height
      @bitmap.dispose if !@bitmap.disposed?
      @bitmap = Bitmap.new(@width, @height)
      @sprite.bitmap = @bitmap
    end

    def dispose
      @sprite.bitmap.dispose
      @sprite.dispose
    end

    def on_got_focus
      @handler_got_focus.call if nil != @handler_got_focus
    end

    def on_lost_focus
      @handler_lost_focus.call if nil != @handler_lost_focus
    end

    def on_mouse_over(x:, y:)
      @handler_mouse_over.call(x, y) if nil != @handler_mouse_over
    end

    def on_mouse_out(x:, y:)
      @handler_mouse_out.call(x, y) if nil != @handler_mouse_out
    end

    def on_mouse_down(button:, x:, y:)
      @handler_mouse_down.call(button, x, y) if nil != @handler_mouse_down
    end

    def on_mouse_up(button:, x:, y:)
      @handler_mouse_up.call(button, x, y) if nil != @handler_mouse_up
    end

    def on_mouse_dragging(button:, dx:, dy:)
      @handler_mouse_dragging.call(button, dx, dy) if nil != @handler_mouse_dragging
    end
  end
end