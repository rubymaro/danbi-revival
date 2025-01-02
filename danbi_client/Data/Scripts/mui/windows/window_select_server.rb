module MUI
  class Window_SelectServer < WindowWith3x3Pieces

    MOUSE_OVER_ALPHA = 96
    MOUSE_OUT_ALPHA = 24
    SERVER_ON_COLOR = Color.new(0, 255, 127)
    SERVER_OFF_COLOR = Color.new(220, 20, 60)

    def initialize
      super(x: :center, y: :center, width: 320, height: 240, skin_key: :glass_skin_window_3x3)
      @label_title.font.size = 22
      @label_title.font.color = Colors::WHITE
      @label_title.text = "서버 선택"
      @label_title.render
      
      @label_server_names = Array.new(Config::SERVER_INFOS.length)

      for i in 0...Config::SERVER_INFOS.length
        server_info = Config::SERVER_INFOS[i]

        @label_server_names[i] = Label.new(x: 0, y: 36 * i, width: @viewport_content.rect.width, height: 32, text: server_info.name)
        @label_server_names[i].index = i
        @label_server_names[i].alignment = AlignmentFlags::VERTICAL_CENTER | AlignmentFlags::HORIZONTAL_CENTER
        @label_server_names[i].font.size = 18
        @label_server_names[i].font.color = Colors::WHITE
        @label_server_names[i].background_color.set(SERVER_OFF_COLOR.red, SERVER_OFF_COLOR.green, SERVER_OFF_COLOR.blue, MOUSE_OUT_ALPHA)
        @label_server_names[i].handler_mouse_over = ->(control, x, y) do
          control.background_color.alpha = MOUSE_OVER_ALPHA
          control.render
        end
        @label_server_names[i].handler_mouse_out = ->(control, x, y) do
          control.background_color.alpha = MOUSE_OUT_ALPHA
          control.render
        end
        @label_server_names[i].handler_mouse_up = ->(control, button, x, y) do
          if Input::MOUSELEFT == button
            server_info = Config::SERVER_INFOS[control.index]
            puts "#{server_info.inspect}로 접속을 시도합니다 ..."

            @try_connect = true
            loop do 
              c = 0
              for thread in @threads
                c += 1 if thread.stop?
              end
              break if c == Config::SERVER_INFOS.length
            end

            if true == $network.connect(server_info)
              @threads.each do |thread|
                if thread.stop?
                  thread.exit
                else
                  thread.join
                end
              end
              hide
              SceneManager.scene.mode = Scene::Intro::Mode::LOGIN
            else
              @try_connect = false
              @threads.each do |thread|
                thread.run
              end
            end
          end
        end
        @label_server_names[i].add_to_window_content(window: self)
      end

      @try_connect = false
      @threads = []
      for server_info in Config::SERVER_INFOS
        @threads << Thread.new(server_info) do |server|
          # initialize states
          current_thread = Thread.current
          current_thread[:is_server_on] = false
          current_thread[:time_stamp] = 0

          # refresh states
          while is_showing?
            Thread.stop if true == @try_connect
            if (Time.now - current_thread[:time_stamp]).to_i >= Config::REFRESHING_SERVER_CONNECTION_STATE_DELAY_SEC
              begin
                socket_checker = TCPSocket.new(server.ip, server.port)
                current_thread[:is_server_on] = true
                socket_checker.close
              rescue Errno::ECONNREFUSED
                current_thread[:is_server_on] = false
              ensure
                current_thread[:time_stamp] = Time.now
              end
            end
          end
        end
      end
    end

    def update
      for i in 0...Config::SERVER_INFOS.length
        t = @threads[i]
        label = @label_server_names[i]
        if true == t[:is_server_on]
          label.background_color.red = SERVER_ON_COLOR.red
          label.background_color.green = SERVER_ON_COLOR.green
          label.background_color.blue = SERVER_ON_COLOR.blue
        else
          label.background_color.red = SERVER_OFF_COLOR.red
          label.background_color.green = SERVER_OFF_COLOR.green
          label.background_color.blue = SERVER_OFF_COLOR.blue
        end
        @label_server_names[i].render
      end
    end

    def has_close_button?
      return false
    end

    def is_disposable?
      return false
    end

    def is_draggable?
      return false
    end

    def relative_content_y
      return 64
    end
  end
end