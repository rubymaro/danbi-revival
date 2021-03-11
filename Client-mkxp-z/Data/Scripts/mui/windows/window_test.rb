module MUI
  class Window_Test < WindowWithSinglePiece
    def initialize(x:, y:, width:, height:, skin_key: :default_single)
      super(x: x, y: y, width: width, height: height, skin_key: skin_key)

      @button = ButtonWith3x3Pieces.new(x: 20, y: 10, width: 100, height: 32)
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