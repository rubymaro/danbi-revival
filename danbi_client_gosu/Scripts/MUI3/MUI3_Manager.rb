module MUI3
  class Manager
    attr_reader(:gosu_window)
    attr_accessor(:mouse_x)
    attr_accessor(:mouse_y)
    
    def initialize(gosu_window:)
      @gosu_window = gosu_window
      @components = []
      @mouse_left_triggered = false
    end

    def add(component:)
      @components << component
    end

    def update
      @mouse_x = @gosu_window.mouse_x.to_i
      @mouse_y = @gosu_window.mouse_y.to_i
      for component in @components
        component.update_all
      end
    end

    def draw
      for component in @components
        component.draw_all
      end
    end

    def mouse_left_triggered?
      if Gosu.button_down?(Gosu::MS_LEFT)
        if !@mouse_left_triggered
          @mouse_left_triggered = true
          return true
        end
      else
        @mouse_left_triggered = false
      end
      return false
    end
  end
end