module Scene
  class Intro < Base
    module Mode
      SERVER = 0
      LOGIN = 1
      JOIN = 2
    end
    #--------------------------------------------------------------------------
    # * Start Processing
    #--------------------------------------------------------------------------
    def start
      super
      SceneManager.clear
      Graphics.freeze
      play_title_music
      self.mode = Mode::SERVER
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
      @sprite.opacity = 128
    end
    #--------------------------------------------------------------------------
    # * Play Title Screen Music
    #--------------------------------------------------------------------------
    def play_title_music
      $game_system.bgm_play($data_system.title_bgm)
      Audio.bgs_stop
      Audio.me_stop
    end

    def terminate
      @sprite.bitmap.dispose
      @sprite.bitmap = nil
      @sprite.dispose
      @sprite = nil
      super
    end

    def mode=(value)
      @mode = value
      case @mode
      when Mode::SERVER
        create_background
        MUIManager.get_window_cache(:select_server).show

      when Mode::LOGIN
        @sprite.bitmap.dispose
        @sprite.bitmap = RPG::Cache.title($data_system.title_name)
        MUIManager.get_window_cache(:login).show
        
      when Mode::JOIN


      else
        raise "invalid mode"
      end
    end

    def update
      case @mode
      when Mode::SERVER

      when Mode::LOGIN
        @sprite.opacity += 2 if @sprite.opacity < 255

      when Mode::JOIN
      end
      super
    end
  end
end