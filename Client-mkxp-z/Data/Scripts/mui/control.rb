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
    attr_reader :is_visible
    attr_reader :is_enabled
    attr_reader :is_focusing

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
      @is_visible = true
      @is_enabled = true
      @is_focusing = false
      @state_mouse_over = false
      @is_added = false
    end

    def add_to_window_frame(window:)
      on_creating(window: window, viewport: window.viewport_frame)
      window.controls.push(self)
    end

    def add_to_window_content(window:)
      on_creating(window: window, viewport: window.viewport_content)
      window.controls.push(self)
    end

    def on_creating(window:, viewport:)
      raise "같은 컨트롤을 2번 이상 추가할 수 없습니다." if @is_added
      @is_added = true
      
      @parent_window = window
      @sprite = Sprite.new(viewport)
      @sprite.x = @x
      @sprite.y = @y
      @sprite.z = @z
      @sprite.visible = @is_visible
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

    def resize(width:, height:)
      return false if @width == width && @height == height
      @width = width
      @height = height
      return true
    end

    def is_visible=(bool)
      @is_visible = bool
      @sprite.visible = @is_visible if nil != @sprite
      @state_mouse_over = false
    end

    def is_enabled=(bool)
      @is_enabled = bool
      @state_mouse_over = false
    end

    def real_x
      return @x + @sprite.viewport.rect.x
    end

    def real_y
      return @y + @sprite.viewport.rect.y
    end

    def is_point_in_sprite?(x:, y:)
      rx = real_x
      ry = real_y
      return x >= rx && x < rx + @width && y >= ry && y < ry + @height
    end

    def update

    end

    def dispose
      @sprite.bitmap.dispose
      @sprite.bitmap = nil
      @sprite.dispose 
      @sprite = nil
      @bitmap = nil
    end

    def on_got_focus
      @is_focusing = true
      @handler_got_focus.call if nil != @handler_got_focus
    end

    def on_lost_focus
      @is_focusing = false
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

  protected
    def render
      raise "추상 메서드 #{caller[0][/`.*'/][1..-2]} 를 구현하세요."
    end
  end
end