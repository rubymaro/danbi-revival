script_path = File.expand_path("../", __dir__) + "/danbi_client_gosu/Scripts/"
$LOAD_PATH.unshift(script_path)

require "gosu"
require "MUI3/requires.rb"

WIDTH, HEIGHT = 1600, 900

class DanbiUIEditorWindow < Gosu::Window
  def initialize
    super(WIDTH, HEIGHT)
    self.caption = "Danbi UI Editor"
  end

  def draw
  end
end

DanbiUIEditorWindow.new.show if __FILE__ == $0