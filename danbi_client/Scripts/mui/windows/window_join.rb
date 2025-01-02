module MUI
  class Window_Join < WindowWith3x3Pieces
    def initialize
      super(x: :center, y: :center, width: 320, height: 240, skin_key: :glass_skin_window_3x3)
      @label_title.font.size = 22
      @label_title.font.color = Colors::WHITE
      @label_title.text = "회원가입"
      @label_title.render
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