module MUI
  class Window_Login < WindowWithSinglePiece
    def initialize(x:, y:, width:, height:, skin_key: :default_single)
      super(x: x, y: y, width: width, height: height, skin_key: skin_key)

      @label_title.text = "로그인"
      @label_title.font.size = 20
      @label_title.font.bold = true
      @label_title.render

      @textbox_id = TextBox.new(x: 64, y: 50, width: 200, height: 36, skin_key: :default_3x3)
      @textbox_id.add_to_window_content(window: self)
      @textbox_pw = TextBox.new(x: 64, y: 100, width: 200, height: 36, skin_key: :default_3x3)
      @textbox_pw.add_to_window_content(window: self)

      @button = ButtonWith3x3Pieces.new(x: 64, y: 150, width: 200, height: 32)
      @button.text = "접속"
      @button.add_to_window_content(window: self)
    end

    def has_close_button?
      return true
    end

    def is_disposable?
      return true
    end
  end
end