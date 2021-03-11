module MUI
  class Window_SelectServer < WindowWith4x3Pieces
    def initialize(skin_key: :default_4x3)
      super(x: 60, y: 0, width: 600, height: 800, skin_key: skin_key)
      @label_title.text = "서버 선택"
      @label_title.render

      @button2 = ButtonWithSinglePiece.new(x: 0, y: 100, width: 80, height: 32, skin_key: :one_image)
      @button2.text = "size up"
      @button2.handler_mouse_up = ->(button, x, y) do
        @textbox.is_enabled = !@textbox.is_enabled
        #@button.is_enabled = !@button.is_enabled
        @label.resize(width: @label.width + 10, height: @label.height)
      end
      @button2.z = 1
      @button2.add_to_window_content(window: self)


      @button2 = ButtonWithSinglePiece.new(x: 70, y: 100, width: 80, height: 32, skin_key: :one_image)
      @button2.text = "size down"
      @button2.handler_mouse_up = ->(button, x, y) do
        @label.resize(width: @label.width - 10, height: @label.height)
      end
      @button2.z = 2
      @button2.add_to_window_content(window: self)

      @button = ButtonWith3x3Pieces.new(x: 20, y: 80, width: 100, height: 32)
      @button.z = 3
      @button.text = "click me"
      @button.handler_mouse_up = ->(button, x, y) do
        #@button.resize(width: @button.width + 10, height: @button.height)
        #resize(width: @width, height: @height + 5)
        @label.text = @textbox.text
        #@label.is_multiline = false
        @label.render

        @button.text = "random: #{rand(50)}"
        @button.resize(width: @button.width + 12, height: @button.height)
      end
      @button.handler_got_focus = ->() do
        #p "got focus"
      end
      @button.handler_lost_focus = ->() do
        #p "lost focus"
      end
      @button.add_to_window_content(window: self)

      @label = Label.new(x: 200, y: 20, width: 300, height: 50, is_multiline: true)
      @label.alignment = AlignmentFlags::VERTICAL_CENTER | AlignmentFlags::HORIZONTAL_CENTER
      @label.background_color = Colors::WHITE
      @label.text = "mkxp-z\nhello\nworld\n안녕하세요. 레이블 테스트입니다."
      @label.z = 5
      @label.add_to_window_content(window: self)
      @label.resize

      @textbox = TextBox.new(x: 0, y: 0, width: 200, height: 36, skin_key: :default_3x3)
      @textbox.add_to_window_content(window: self)
    end

    def has_close_button?
      return true
    end

    def is_disposable?
      return false
    end
  end
end