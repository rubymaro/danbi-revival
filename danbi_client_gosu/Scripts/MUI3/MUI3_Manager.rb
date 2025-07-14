module MUI3
  class Manager
    attr_reader(:gosu_window)
    attr_accessor(:mouse_x)
    attr_accessor(:mouse_y)
    attr_accessor(:over_topmost)
    
    def initialize(gosu_window:)
      @gosu_window = gosu_window
      @components = []
      @mouse_left_triggered = false
      @over_topmost = nil
    end

    def add(component:)
      component.root = component
      @components << component
    end

    def update
      @mouse_x = @gosu_window.mouse_x.to_i
      @mouse_y = @gosu_window.mouse_y.to_i
      @over_topmost = nil
      for component in @components
        component.update_topmost_recursive
      end
      for component in @components
        component.update_all
      end
      for i in 0...@components.length
        if @components[i].top_flag == true
          @components[i].top_flag = false
          @components << @components[i]
          @components.delete_at(i)
        end
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