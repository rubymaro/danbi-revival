#==============================================================================
# ** Scene::Manager
#------------------------------------------------------------------------------
#  This module manages scene transitions. For example, it can handle
# hierarchical structures such as calling the item screen from the main menu
# or returning from the item screen to the main menu.
#==============================================================================

module Scene
  class Manager
    attr_reader(:scene)

    def initialize
      @scene = nil                            # current scene object
      @stack = []                             # stack for hierarchical transitions
    end

    def run
      @scene = first_scene_class.new
    end

    def first_scene_class
      Scene::Title
    end

    def goto(scene_class)
      @scene = scene_class.new
    end

    def call(scene_class)
      @stack.push(@scene)
      @scene = scene_class.new
    end

    def return
      @scene = @stack.pop
    end

    def clear
      @stack.clear
    end

    def exit
      @scene = nil
    end
  end
end