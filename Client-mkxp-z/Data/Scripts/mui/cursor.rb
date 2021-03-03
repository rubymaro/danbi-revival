module MUI
  module Cursor
    def self.init
      @viewport = Viewport.new(0, 0, Config::WINDOW_WIDTH, Config::WINDOW_HEIGHT)
      @viewport.z = (1 << 30) - 1
      @sprite = Sprite.new(@viewport)
      @sprite.bitmap = RPG::Cache.icon(Config::FILENAME_CURSOR_ICON)

      #a = MiniFFI.new("C:/dev/GitHub/danbi-revival/Client-mkxp-z/user32.dll", 'ShowCursor', 'l', 'l')
      #a.call
      Graphics.show_cursor = false
      
    end

    def self.update
      @sprite.x = Input.mouse_x
      @sprite.y = Input.mouse_y
    end
  end
end

