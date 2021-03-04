require 'mui/bitmap_grid.rb'
require 'mui/skin_cache.rb'

require 'mui/cursor.rb'

require 'mui/window_base.rb'
require 'mui/window_with_single_piece.rb'
require 'mui/window_with_4x3_pieces.rb'
require 'mui/window_with_3x3_pieces.rb'

require 'mui/windows/window_select_server.rb'
require 'mui/windows/window_test.rb'

require 'mui/control.rb'
require 'mui/button_base.rb'
require 'mui/button_with_3x3_pieces.rb'
require 'mui/button_with_single_piece.rb'

module MUIManager
  def self.init
    raise "#{self} 를 2번 이상 init 할 수 없습니다." if @is_init == true
    @is_init = true

    MUI::Cursor.init
    MUI::WindowBase.init
    MUI::ButtonBase.init

    @last_focused_window_or_nil = nil
    @created_windows = []
    @window_caches = {
      :select_server => MUI::Window_SelectServer.new,
    }
  end

  def self.add_window(window:)
    @created_windows.push(window)
  end

  def self.get_window_cache(key)
    return @window_caches[key]
  end

  def self.get_focused_window_or_nil
    return @last_focused_window_or_nil
  end

  def self.set_focused_window(window:)
    @last_focused_window_or_nil = window
  end

  def self.update
    MUI::Cursor.update

    if Input.trigger?(Input::MOUSELEFT)
      max_window_z = -1
      focused_window_or_nil = nil
      for window in @created_windows
        if window.showing? && max_window_z < window.z && window.point_in_frame?(x: Input.mouse_x, y: Input.mouse_y)
          max_window_z = window.z
          focused_window_or_nil = window
        end
      end
      if focused_window_or_nil != @last_focused_window_or_nil
        @last_focused_window_or_nil.on_lost_focus if nil != @last_focused_window_or_nil
        focused_window_or_nil.on_got_focus if nil != focused_window_or_nil
        @last_focused_window_or_nil = focused_window_or_nil
      end
    end

    max_window_z = -1
    over_control_or_nil = nil
    for window in @created_windows
      if window.showing? && max_window_z < window.z && window.point_in_frame?(x: Input.mouse_x, y: Input.mouse_y)
        max_window_z = window.z
        max_control_z = -1
        over_control_or_nil = nil
        for control in window.controls
          if control.is_visible
            if max_control_z < control.z && control.point_in_sprite?(x: Input.mouse_x, y: Input.mouse_y)
              max_control_z = control.z
              over_control_or_nil = control
            else
              if control.state_mouse_over
                control.state_mouse_over = false
                control.on_mouse_out(x: Input.mouse_x, y: Input.mouse_y)
              end
            end
          end
        end
      else
        for control in window.controls
          if control.is_visible && control.state_mouse_over
            control.state_mouse_over = false
            control.on_mouse_out(x: Input.mouse_x, y: Input.mouse_y)
          end
        end
      end
    end
    if nil != over_control_or_nil && !over_control_or_nil.state_mouse_over
      over_control_or_nil.state_mouse_over = true
      over_control_or_nil.on_mouse_over(x: Input.mouse_x, y: Input.mouse_y)
    end

    for window in @created_windows
      if window.showing?
        window.update
      end
    end

    @last_focused_window_or_nil.update_events if nil != @last_focused_window_or_nil && @last_focused_window_or_nil.showing?

    @created_windows.delete_if do |window|
      if window.has_disposing_request
        window.on_disposing
        true
      end
    end
    if nil != @last_focused_window_or_nil && @last_focused_window_or_nil.has_disposing_request
      @last_focused_window_or_nil = nil
    end
  end
end