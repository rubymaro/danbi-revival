module MUI
  class Window_Login < WindowWith4x3Pieces
    def initialize
      super(x: :center, y: :center, width: 320, height: 240)

      @label_title.text = "로그인"
      @label_title.font.size = 20
      @label_title.font.bold = true
      @label_title.render

      @textbox_id = TextBox.new(x: 64, y: 50, width: 200, height: 36, skin_key: :white_skin_textbox_3x3)
      @textbox_id.add_to_window_content(window: self)
      @textbox_pw = TextBox.new(x: 64, y: 100, width: 200, height: 36, skin_key: :white_skin_textbox_3x3)
      @textbox_pw.add_to_window_content(window: self)

      @button_login = ButtonWith3x3Pieces.new(x: 64, y: 150, width: 200, height: 32)
      @button_login.text = "로그인"
      @button_login.handler_mouse_up = ->(control, button, x, y) do
        if Input::MOUSELEFT == button
          id = @textbox_id.text.strip
          pw = @textbox_pw.text.strip
          if id.length > 0 && pw.length > 0
            $network.send({'header' => CTSHeader::LOGIN, 'id' => id, 'password' => pw})
          else
            p "빈칸을 채우세요"
          end
        end
      end
      @button_login.add_to_window_content(window: self)

      @button_join = ButtonWith3x3Pieces.new(x: 64, y: 182, width: 200, height: 32)
      @button_join.text = "회원가입"
      @button_join.z = 1
      @button_join.add_to_window_content(window: self)
    end

    def has_close_button?
      return false
    end

    def is_disposable?
      return true
    end

    def is_draggable?
      return false
    end
  end
end