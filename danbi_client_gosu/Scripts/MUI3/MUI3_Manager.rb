module MUI3
  class Manager
    attr_accessor(:mouse_x)
    attr_accessor(:mouse_y)
    attr_accessor(:over_topmost)
    attr_reader(:last_mouse_x)
    attr_reader(:last_mouse_y)

    def initialize(gosu_window:)
      @gosu_window = gosu_window
      @components = []
      @over_topmost = nil
      @input_box = nil
      @press_ticks = { Gosu::MS_LEFT => 0 }
      @last_mouse_x = 0
      @last_mouse_y = 0
    end

    def add(component:)
      component.root = component
      @components << component
    end

    def update
      if Gosu.button_down?(Gosu::MS_LEFT)
        @press_ticks[Gosu::MS_LEFT] += 1
      else
        @press_ticks[Gosu::MS_LEFT] = 0
      end
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
      @last_mouse_x = @mouse_x
      @last_mouse_y = @mouse_y
    end

    def draw
      for component in @components
        component.draw_all
      end
    end

    def mouse_left_triggered?
      return @press_ticks[Gosu::MS_LEFT] == 1
    end

    def set_input_box(input_box:)
      @input_box = input_box
      if @input_box.nil?
        @gosu_window.text_input = nil
      else
        @gosu_window.text_input = @input_box.gosu_text_input
      end
    end
  end
end