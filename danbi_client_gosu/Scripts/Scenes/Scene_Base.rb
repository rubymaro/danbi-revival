#==============================================================================
# ** Scene::Base
#------------------------------------------------------------------------------
#  This is a super class of all scenes within the game.
#==============================================================================

class Scene::Base
  def update
    raise NotImplementedError, "You must implement the update method"
  end

  def draw
    raise NotImplementedError, "You must implement the draw method"
  end

  def return_scene
    Scene::Manager.return
  end
end