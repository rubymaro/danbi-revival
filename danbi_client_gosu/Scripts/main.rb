if __FILE__ == $0
  $LOAD_PATH.unshift(File.expand_path("../", __dir__))

  require "gosu"

  require_relative "config.rb"
  require_relative "game_window.rb"

  require_relative "modules/scene_manager.rb"
  
  require_relative "scenes/scene_base.rb"
  require_relative "scenes/scene_title.rb"

  SceneManager.run

  $game_window = GameWindow.new
  $game_window.show
end
