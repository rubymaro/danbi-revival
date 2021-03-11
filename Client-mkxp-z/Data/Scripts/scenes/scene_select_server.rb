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
      @window_login = MUI::Window_Login.new(x: 200, y: 200, width: 400, height: 300, skin_key: :default_single)
      @window_login.show
    end
    #--------------------------------------------------------------------------
    # * Create Background
    #--------------------------------------------------------------------------
    def create_background
      @sprite = Sprite.new
      @sprite.opacity = 16
      @sprite.bitmap = RPG::Cache.title($data_system.title_name)
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