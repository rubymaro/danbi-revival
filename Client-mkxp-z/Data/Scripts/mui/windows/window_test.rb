module MUI
  class Window_Test < WindowWithSinglePiece
    def initialize(x:, y:, width:, height:, skin_key: :default_single, has_close_button: true, disposable: false)
      super(x: x, y: y, width: width, height: height, skin_key: skin_key)

      @button = ButtonWith3x3Pieces.new(x: 20, y: 10, width: 100, height: 32)
      add_to_content(control: @button)
    end
  end
end