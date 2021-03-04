module MUI
  class ButtonBase < Control
    module State
      NORMAL = 0
      MOUSE_OVER = 1
      PRESSED = 2
      DISABLED = 3
      
      Length = 4
    end

    def self.init
      @@skin_caches ||= Hash.new

      # 이미지를 3x3 분할로 쪼개기
      src = RPG::Cache.mui("button.png")
      grid = BitmapGrid.new(row_count: State::Length, column_count: 1,
        offset_x: 0, offset_y: 0,
        rects: [
          Rect.new(0, 0, 64, 32),
          Rect.new(0, 32, 64, 32),
          Rect.new(0, 64, 64, 32),
          Rect.new(0, 96, 64, 32),
        ]
      )
      grid_per_button = BitmapGrid.new(row_count: 3, column_count: 3,
        offset_x: 0, offset_y: 0,
        rects: [
          Rect.new(0, 0, 4, 4),
          Rect.new(4, 0, 4, 4),
          Rect.new(60, 0, 4, 4),

          Rect.new(0, 4, 4, 4),
          Rect.new(4, 4, 4, 4),
          Rect.new(60, 4, 4, 4),

          Rect.new(0, 28, 4, 4),
          Rect.new(4, 28, 4, 4),
          Rect.new(60, 28, 4, 4),
        ]
      )
      bitmap_buttons = grid.create_splitted_bitmaps(bitmap_src: src)
      @@skin_caches[:default_3x3] ||= Array.new(State::Length)
      @@skin_caches[:default_3x3][State::NORMAL] ||= SkinCache.new(grid_per_button.row_count, grid_per_button.column_count, grid_per_button.create_splitted_bitmaps(bitmap_src: bitmap_buttons[State::NORMAL][0]))
      @@skin_caches[:default_3x3][State::MOUSE_OVER] ||= SkinCache.new(grid_per_button.row_count, grid_per_button.column_count, grid_per_button.create_splitted_bitmaps(bitmap_src: bitmap_buttons[State::MOUSE_OVER][0]))
      @@skin_caches[:default_3x3][State::PRESSED] ||= SkinCache.new(grid_per_button.row_count, grid_per_button.column_count, grid_per_button.create_splitted_bitmaps(bitmap_src: bitmap_buttons[State::PRESSED][0]))
      @@skin_caches[:default_3x3][State::DISABLED] ||= SkinCache.new(grid_per_button.row_count, grid_per_button.column_count, grid_per_button.create_splitted_bitmaps(bitmap_src: bitmap_buttons[State::DISABLED][0]))

      # 이미지를 쪼개지 않음
      src = RPG::Cache.mui("button.png")
      grid = BitmapGrid.new(row_count: State::Length, column_count: 1,
        offset_x: 0, offset_y: 0,
        rects: [
          Rect.new(0, 0, 64, 32),
          Rect.new(0, 32, 64, 32),
          Rect.new(0, 64, 64, 32),
          Rect.new(0, 96, 64, 32),
        ]
      )
      grid_per_button = BitmapGrid.new(row_count: 1, column_count: 1,
        offset_x: 0, offset_y: 0,
        rects: [
          Rect.new(0, 0, 64, 32),
        ]
      )
      bitmap_buttons = grid.create_splitted_bitmaps(bitmap_src: src)
      @@skin_caches[:one_image] ||= Array.new(State::Length)
      @@skin_caches[:one_image][State::NORMAL] ||= SkinCache.new(grid_per_button.row_count, grid_per_button.column_count, grid_per_button.create_splitted_bitmaps(bitmap_src: bitmap_buttons[State::NORMAL][0]))
      @@skin_caches[:one_image][State::MOUSE_OVER] ||= SkinCache.new(grid_per_button.row_count, grid_per_button.column_count, grid_per_button.create_splitted_bitmaps(bitmap_src: bitmap_buttons[State::MOUSE_OVER][0]))
      @@skin_caches[:one_image][State::PRESSED] ||= SkinCache.new(grid_per_button.row_count, grid_per_button.column_count, grid_per_button.create_splitted_bitmaps(bitmap_src: bitmap_buttons[State::PRESSED][0]))
      @@skin_caches[:one_image][State::DISABLED] ||= SkinCache.new(grid_per_button.row_count, grid_per_button.column_count, grid_per_button.create_splitted_bitmaps(bitmap_src: bitmap_buttons[State::DISABLED][0]))

      # closing button
      src = RPG::Cache.mui("window.png")
      grid = BitmapGrid.new(row_count: State::Length, column_count: 1,
        offset_x: 100, offset_y: 0,
        rects: [
          Rect.new(0, 0, 12, 10),
          Rect.new(0, 10, 12, 10),
          Rect.new(0, 10, 12, 10),
          Rect.new(0, 0, 12, 10),
        ]
      )
      grid_per_button = BitmapGrid.new(row_count: 1, column_count: 1,
        offset_x: 0, offset_y: 0,
        rects: [
          Rect.new(0, 0, 12, 10),
        ]
      )
      bitmap_buttons = grid.create_splitted_bitmaps(bitmap_src: src)
      @@skin_caches[:x_button] ||= Array.new(State::Length)
      @@skin_caches[:x_button][State::NORMAL] ||= SkinCache.new(grid_per_button.row_count, grid_per_button.column_count, grid_per_button.create_splitted_bitmaps(bitmap_src: bitmap_buttons[State::NORMAL][0]))
      @@skin_caches[:x_button][State::MOUSE_OVER] ||= SkinCache.new(grid_per_button.row_count, grid_per_button.column_count, grid_per_button.create_splitted_bitmaps(bitmap_src: bitmap_buttons[State::MOUSE_OVER][0]))
      @@skin_caches[:x_button][State::PRESSED] ||= SkinCache.new(grid_per_button.row_count, grid_per_button.column_count, grid_per_button.create_splitted_bitmaps(bitmap_src: bitmap_buttons[State::PRESSED][0]))
      @@skin_caches[:x_button][State::DISABLED] ||= SkinCache.new(grid_per_button.row_count, grid_per_button.column_count, grid_per_button.create_splitted_bitmaps(bitmap_src: bitmap_buttons[State::DISABLED][0]))
    end
    
    class << self
      alias_method :button_base_new, :new
      
      def new(**args)
        raise "#{self}는 인스턴스화 할 수 없습니다." if self == MUI::ButtonBase
        button_base_new(**args)
      end
    end

  public
    def initialize(x:, y:, width:, height:, skin_key:, piece_row_count:, piece_column_count:)
      raise "등록되지 않은 key(#{key}) 입니다." if !@@skin_caches.key?(skin_key)
      @skins = @@skin_caches[skin_key]
      raise "해당 skin_key `#{skin_key}'은 #{self}과 호환되지 않습니다." if @skins[0].piece_row_count != piece_row_count || @skins[0].piece_column_count != piece_column_count
      
      super(x: x, y: y, width: width, height: height)
      @bitmap = Bitmap.new(width, height * State::Length)
    end

    def resize(width:, height:)
      @width = width
      @height = height
      @bitmap.dispose if !@bitmap.disposed?
      @bitmap = Bitmap.new(@width, @height * State::Length)
      @sprite.bitmap = @bitmap
    end

    def on_creating(window:, viewport:)
      super(window: window, viewport: viewport)

      render
      @sprite.src_rect.set(0, 0, @width, @height)
    end

    def on_got_focus
      super
    end

    def on_lost_focus
      super
    end

    def on_mouse_over(x:, y:)
      @sprite.src_rect.set(0, @height * State::MOUSE_OVER, @width, @height)
      super(x: x, y: y)
    end

    def on_mouse_out(x:, y:)
      @sprite.src_rect.set(0, @height * State::NORMAL, @width, @height)
      super(x: x, y: y)
    end

    def on_mouse_down(button:, x:, y:)
      @sprite.src_rect.set(0, @height * State::PRESSED, @width, @height) if Input::MOUSELEFT == button
      super(button: button, x: x, y: y)
    end

    def on_mouse_up(button:, x:, y:)
      if point_in_sprite?(x: x, y: y)
        @sprite.src_rect.set(0, @height * State::MOUSE_OVER, @width, @height) if Input::MOUSELEFT == button
        super(button: button, x: x, y: y)
      else
        @sprite.src_rect.set(0, @height * State::NORMAL, @width, @height)
      end
    end

    def on_mouse_dragging(button:, dx:, dy:)
      super(button: button, dx: dx, dy: dy)
    end

  private
    def render
      raise "추상 메서드 #{caller[0][/`.*'/][1..-2]} 를 구현하세요."
    end
  end
end