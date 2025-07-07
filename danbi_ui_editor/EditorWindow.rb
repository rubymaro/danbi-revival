script_path = File.expand_path("../", __dir__) + "/danbi_client_gosu/Scripts/"
$LOAD_PATH.unshift(script_path)

require "gosu"
require "chunky_png"

require "Extensions/Gosu_ImageEx.rb"
require "MUI3/requires.rb"

require_relative "Forms/Test.rb"

WIDTH, HEIGHT = 1600, 900

class DanbiUIEditorWindow < Gosu::Window
  def initialize
    super(WIDTH, HEIGHT)
    self.caption = "Danbi UI Editor"
    $mui_manager = MUI3::Manager.new(gosu_window: self)
    @form_test = MUI3::Form::Test.new
    $mui_manager.add(component: @form_test)
  end

  def update
    $mui_manager.update
  end

  def draw
    $mui_manager.draw
  end
end

DanbiUIEditorWindow.new.show