#==============================================================================
# ** Scene::Base
#------------------------------------------------------------------------------
#  This is a super class of all scenes within the game.
#==============================================================================

module Scene
  class Base
    def update
      raise NotImplementedError, "You must implement the update method"
    end

    def draw
      raise NotImplementedError, "You must implement the draw method"
    end

    def return_scene
      SceneManager.return
    end
  end
end