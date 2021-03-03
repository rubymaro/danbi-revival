#==============================================================================
# ** Main
#------------------------------------------------------------------------------
#  This processing is executed after module and class definition is finished.
#==============================================================================

require 'config.rb'
require 'preload.rb'

require 'modules/rpg_cache.rb'
require 'modules/data_manager.rb'
require 'modules/scene_manager.rb'
require 'modules/mui_manager.rb'

require 'scenes/scene_base.rb'
require 'scenes/scene_select_server.rb'

require 'games/game_system.rb'

rgss_main {
  DataManager.init
  MUIManager.init
  SceneManager.run
}

#require 'socket'

#s = TCPSocket.new '127.0.0.1', 50000
#s.close