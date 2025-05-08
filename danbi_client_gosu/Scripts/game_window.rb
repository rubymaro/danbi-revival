class GameWindow < Gosu::Window
  def initialize
    super(Config::WINDOW_WIDTH, Config::WINDOW_HEIGHT, {:update_interval => Config::FRAME_RATE})
    self.caption = Config::GAME_TITLE
  end

  def update
    SceneManager.scene().update()
  end

  def draw
    SceneManager.scene().draw()
  end
end
