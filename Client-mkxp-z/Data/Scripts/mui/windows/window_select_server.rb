module MUI
  class Window_SelectServer < WindowWith3x3Pieces
    def initialize
      super(x: :center, y: :center, width: 320, height: 240, skin_key: :glass_skin_window_3x3)
      @label_title.font.size = 22
      @label_title.font.color = Colors::WHITE
      @label_title.text = "서버 선택"
      @label_title.render

      @label_server_names = Array.new(Config::SERVER_INFOS.length)
      @button_connect_servers = Array.new(Config::SERVER_INFOS.length)

      for i in 0...Config::SERVER_INFOS.length
        server_info = Config::SERVER_INFOS[i]

        @label_server_names[i] = Label.new(x: 0, y: 36 * i, width: @viewport_content.rect.width, height: 32, text: server_info.name)
        @label_server_names[i].index = i
        @label_server_names[i].alignment = AlignmentFlags::VERTICAL_CENTER | AlignmentFlags::HORIZONTAL_CENTER
        @label_server_names[i].font.size = 18
        @label_server_names[i].font.color = Colors::WHITE
        @label_server_names[i].background_color.set(0, 0, 0, 24)
        @label_server_names[i].handler_mouse_over = ->(control, x, y) do
          control.background_color.set(0, 111, 255, 128)
          control.render
        end
        @label_server_names[i].handler_mouse_out = ->(control, x, y) do
          control.background_color.set(0, 0, 0, 24)
          control.render
        end
        @label_server_names[i].handler_mouse_up = ->(control, button, x, y) do
          if Input::MOUSELEFT == button
            server_info = Config::SERVER_INFOS[control.index]
            puts "#{server_info.inspect}로 접속을 시도합니다 ..."
            if !$network.has_socket?
              $network.connect(server_info)

              @window_login = MUI::Window_Login.new
              @window_login.show
              hide
            end
            
          end
        end
        @label_server_names[i].add_to_window_content(window: self)
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