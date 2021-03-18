module Scene
  class SelectServer < Base
    #--------------------------------------------------------------------------
    # * Start Processing
    #--------------------------------------------------------------------------
    def start
      super
      SceneManager.clear
      Graphics.freeze
      create_background
      play_title_music
      @window_select_server = MUIManager.get_window_cache(:select_server)
      @window_select_server.show
    end
    #--------------------------------------------------------------------------
    # * Create Background
    #--------------------------------------------------------------------------
    def create_background
      @sprite = Sprite.new
      @sprite.bitmap = RPG::Cache.title($data_system.title_name).dup
      10.times do
        @sprite.bitmap.blur
      end
      @sprite.opacity = 160
    end
    #--------------------------------------------------------------------------
    # * Play Title Screen Music
    #--------------------------------------------------------------------------
    def play_title_music
      $game_system.bgm_play($data_system.title_bgm)
      Audio.bgs_stop
      Audio.me_stop
    end
  end
end