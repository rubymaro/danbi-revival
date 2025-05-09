class GameWindow < Gosu::Window
  def initialize
    super(Config::WINDOW_WIDTH, Config::WINDOW_HEIGHT, {:update_interval => Config::FRAME_RATE})
    self.caption = Config::GAME_TITLE
  end

  def update
    Scene::Manager.scene.update
  end

  def draw
    Scene::Manager.scene.draw
  end
end
