if __FILE__ == $0
  $LOAD_PATH.unshift(File.expand_path("../", __dir__))

  require "gosu"
  require "chunky_png"

  require_relative "Extensions/Gosu_ImageEx.rb"

  require_relative "Config.rb"
  require_relative "GameWindow.rb"

  require_relative "MUI3/MUI3_Manager.rb"
  require_relative "MUI3/Components/MUI3_Component.rb"
  require_relative "MUI3/Components/MUI3_Form.rb"
  require_relative "MUI3/MUI3_Style.rb"

  require_relative "MUI3/Outputs/MUI3_Form_Login.rb"
  
  require_relative "Scenes/Scene_Manager.rb"
  require_relative "Scenes/Scene_Base.rb"
  require_relative "Scenes/Scene_Title.rb"

  Scene::Manager.run

  $game_window = GameWindow.new
  $game_window.show
end
