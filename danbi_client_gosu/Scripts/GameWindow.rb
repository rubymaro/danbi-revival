class GameWindow < Gosu::Window
  def initialize
    super(Config::WINDOW_WIDTH, Config::WINDOW_HEIGHT, {:update_interval => Config::FRAME_RATE, :resizable => false})
    self.caption = Config::GAME_TITLE
    $mui_manager = MUI3::Manager.new(gosu_window: self)
    $scene_manager = Scene::Manager.new
    $scene_manager.run
  end

  def update
    $mui_manager.update
    $scene_manager.scene.update
  end

  def draw
    $scene_manager.scene.draw
    $mui_manager.draw
  end
end
