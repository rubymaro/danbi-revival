if __FILE__ == $0
  require "gosu"
  require "chunky_png"

  require_relative "Extensions/Gosu_ImageEx.rb"

  require_relative "Config.rb"
  require_relative "GameWindow.rb"

  require_relative "MUI3/requires.rb"
  
  require_relative "Scenes/Scene_Manager.rb"
  require_relative "Scenes/Scene_Base.rb"
  require_relative "Scenes/Scene_Title.rb"

  GameWindow.new.show
end
