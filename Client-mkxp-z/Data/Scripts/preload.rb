Graphics.resize_screen(Config::WINDOW_WIDTH, Config::WINDOW_HEIGHT)
Graphics.fullscreen if Config::FULLSCREEN_LAUNCHING
Graphics.center
Graphics.frame_rate = 60

def rgss_main
  loop do
    begin
      yield
      break
    end
  end
end