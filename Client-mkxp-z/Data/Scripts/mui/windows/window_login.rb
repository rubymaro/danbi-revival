module MUI
  class Window_Login < WindowWithSinglePiece
    def initialize
      super(x: :center, y: :center, width: 400, height: 300, skin_key: :default_single)

      @label_title.text = "로그인"
      @label_title.font.size = 20
      @label_title.font.bold = true
      @label_title.render

      @textbox_id = TextBox.new(x: 64, y: 50, width: 200, height: 36, skin_key: :white_skin_textbox_3x3)
      @textbox_id.add_to_window_content(window: self)
      @textbox_pw = TextBox.new(x: 64, y: 100, width: 200, height: 36, skin_key: :white_skin_textbox_3x3)
      @textbox_pw.add_to_window_content(window: self)

      @button_login = ButtonWith3x3Pieces.new(x: 64, y: 150, width: 200, height: 32)
      @button_login.text = "접속"
      @button_login.handler_mouse_up = ->(control, button, x, y) do
        if Input::MOUSELEFT == button
          $network.send({'header' => CTSHeader::LOGIN, 'id' => "1", 'password' => "12"})
        end
      end
      @button_login.add_to_window_content(window: self)
    end

    def has_close_button?
      return true
    end

    def is_disposable?
      return true
    end
  end
end