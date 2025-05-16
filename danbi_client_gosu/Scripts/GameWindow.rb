class GameWindow < Gosu::Window
  def initialize
    super(Config::WINDOW_WIDTH, Config::WINDOW_HEIGHT, {:update_interval => Config::FRAME_RATE})
    self.caption = Config::GAME_TITLE
    @mouse_left_triggered = false
  end

  def update
    Scene::Manager.scene.update
  end

  def draw
    Scene::Manager.scene.draw
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
