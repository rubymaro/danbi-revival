if __FILE__ == $0
  $LOAD_PATH.unshift(File.expand_path("../", __dir__))

  require "gosu"

  require_relative "Config.rb"
  require_relative "GameWindow.rb"

  require_relative "Managers/SceneManager.rb"
  
  require_relative "Scenes/Scene_Base.rb"
  require_relative "Scenes/Scene_Title.rb"

  SceneManager.run

  $game_window = GameWindow.new
  $game_window.show
end
