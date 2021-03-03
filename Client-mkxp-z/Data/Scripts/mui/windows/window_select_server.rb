module MUI
  class Window_SelectServer < WindowWith4x3Pieces
    def initialize(skin_key: :default_4x3)
      super(x: 60, y: 0, width: 200, height: 400, skin_key: skin_key)

      @button2 = ButtonWithSinglePiece.new(x: 0, y: 0, width: 175, height: 59, skin_key: :one_image)
      @button2.z = 1
      add_to_content(control: @button2)

      @button = ButtonWith3x3Pieces.new(x: 20, y: 100, width: 100, height: 32)
      @button.z = 2
      @button.handler_mouse_down = ->(button, x, y) do
        #p "mouse down"
      end
      @button.handler_got_focus = ->() do
        p "got focus"
      end
      @button.handler_lost_focus = ->() do
        p "lost focus"
      end
      add_to_content(control: @button)

      @button_close = ButtonWith3x3Pieces.new(x: frame_width - 12, y: 0, width: 12, height: 12)
      add_to_frame(control: @button_close)
    end
  end
end