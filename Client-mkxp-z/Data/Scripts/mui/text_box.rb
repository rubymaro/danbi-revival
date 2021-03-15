module MUI
  class TextBox < Control
    module State
      DEFAULT = 0
      PRESSED = 1
      DISABLED = 2

      Length = 3
    end

    module PieceIndices
      LEFT = 0; HORIZONTAL_CENTER = 1; RIGHT = 2
      UPPER = 0
      VERTICAL_CENTER = 1
      LOWER = 2
    end

    def self.init
      @@backspace_rate = 2
      @@backspace_trigger_delay = 20

      @@skin_caches ||= Hash.new

      # 이미지를 3x3 분할로 쪼개기
      src = RPG::Cache.mui("white_skin.png")
      grid = BitmapGrid.new(row_count: State::Length, column_count: 1,
        offset_x: 184, offset_y: 0,
        rects: [
          Rect.new(0, 0, 64, 32),
          Rect.new(0, 32, 64, 32),
          Rect.new(0, 64, 64, 32),
        ]
      )
      grid_per_button = BitmapGrid.new(row_count: 3, column_count: 3,
        offset_x: 0, offset_y: 0,
        rects: [
          Rect.new(0, 0, 8, 8),
          Rect.new(8, 0, 8, 8),
          Rect.new(56, 0, 8, 8),

          Rect.new(0, 8, 8, 8),
          Rect.new(8, 8, 8, 8),
          Rect.new(56, 8, 8, 8),

          Rect.new(0, 24, 8, 8),
          Rect.new(8, 24, 8, 8),
          Rect.new(56, 24, 8, 8),
        ]
      )
      bitmap_buttons = grid.create_splitted_bitmaps(bitmap_src: src)
      @@skin_caches[:white_skin_textbox_3x3] ||= Array.new(State::Length)
      @@skin_caches[:white_skin_textbox_3x3][State::DEFAULT] ||= SkinCache.new(grid_per_button.row_count, grid_per_button.column_count, grid_per_button.create_splitted_bitmaps(bitmap_src: bitmap_buttons[State::DEFAULT][0]))
      @@skin_caches[:white_skin_textbox_3x3][State::PRESSED] ||= SkinCache.new(grid_per_button.row_count, grid_per_button.column_count, grid_per_button.create_splitted_bitmaps(bitmap_src: bitmap_buttons[State::PRESSED][0]))
      @@skin_caches[:white_skin_textbox_3x3][State::DISABLED] ||= SkinCache.new(grid_per_button.row_count, grid_per_button.column_count, grid_per_button.create_splitted_bitmaps(bitmap_src: bitmap_buttons[State::DISABLED][0]))
    end

  public

    attr_reader :text

    def initialize(x:, y:, width:, height:, skin_key:)
      raise "등록되지 않은 skin_key(#{skin_key}) 입니다." if !@@skin_caches.key?(skin_key)
      @skins = @@skin_caches[skin_key]

      super(x: x, y: y, width: width, height: height)
      @text = ""
      @font = Font.new
      @font.color = Colors::BLACK.dup
      @font.size = 15
      @backspace_triggered = false
      @delay_backspace = 0
      @char_widths = [0]
      @cursor_position = 0
      @opacity_switch = 10
    end

    def on_creating(window:, viewport:)
      super(window: window, viewport: viewport)
      @sprite_text = Sprite.new(viewport)
      @sprite_text.ox = (-text_area_relative_x)
      @sprite_text.oy = (-text_area_relative_y)
      @sprite_text.x = @x
      @sprite_text.y = @y
      @sprite_text.z = @z
      @sprite_text.visible = @is_visible

      @sprite_cursor = Sprite.new(viewport)
      @sprite_cursor.bitmap = Bitmap.new(2, @font.size)
      @sprite_cursor.bitmap.fill_rect(@sprite_cursor.bitmap.rect, Colors::GRAY96)
      @sprite_cursor.ox = (-text_area_relative_x)
      @sprite_cursor.oy = (-text_area_relative_y)
      @sprite_cursor.x = @x
      @sprite_cursor.y = @y
      @sprite_cursor.z = @z
      @sprite_cursor.opacity = 0
      @sprite_cursor.visible = @is_visible

      width = @width
      height = @height
      @width = -1 # for calling resize successfully
      resize(width: width, height: height)
    end

    def x=(integer)
      super(integer)
      @sprite_text.x = @x if nil != @sprite_text
      @sprite_cursor.x = @x if nil != @sprite_cursor
    end

    def y=(integer)
      super(integer)
      @sprite_text.y = @y if nil != @sprite_text
      @sprite_cursor.y = @y if nil != @sprite_cursor
    end

    def z=(integer)
      super(integer)
      @sprite_text.z = @z if nil != @sprite_text
      @sprite_cursor.z = @z if nil != @sprite_cursor
    end

    def resize(width:, height:)
      textbox_state_index = @sprite.src_rect.y / @height rescue 0
      is_resized = super(width: width, height: height)
      if is_resized
        @bitmap.dispose if nil != @bitmap && !@bitmap.disposed?
        @bitmap = nil
        @bitmap = Bitmap.new(@width, @height * State::Length)
        render
        @sprite.bitmap = @bitmap
        @sprite.src_rect.set(0, textbox_state_index * @height, @width, @height)

        @bitmap_text.dispose if nil != @bitmap_text && !@bitmap_text.disposed?
        @bitmap_text = Bitmap.new(@width - margin_width - text_area_relative_x, @height - margin_height - text_area_relative_y)
        render_text
        @sprite_text.bitmap = @bitmap_text
      end

      return is_resized
    end

    def is_visible=(bool)
      super(bool)
      @sprite_text.visible = @is_visible if nil != @sprite_text
      @sprite_cursor.visible = @is_visible if nil != @sprite_cursor
    end

    def is_enabled=(bool)
      super(bool)
      if bool
        @sprite.src_rect.y = @height * State::DEFAULT
      else
        @sprite.src_rect.y = @height * State::DISABLED
        @is_focusing = false
      end
    end

    def update
      if @is_enabled && @is_focusing && true == Input.text_input
        @opacity_switch *= -1 if @sprite_cursor.opacity >= 255 || @sprite_cursor.opacity <= 0
        @sprite_cursor.opacity += @opacity_switch

        if Input.pressex?(:BACKSPACE)
          if Input.triggerex?(:BACKSPACE)
            if @text.length > 0
              @text.chop!
              @char_widths.pop
              puts @text
              render_text
            end
          elsif @delay_backspace >= @@backspace_trigger_delay + @@backspace_rate
            if @text.length > 0
              @text.chop!
              @char_widths.pop
              puts @text
              render_text
            end
            @delay_backspace = @@backspace_trigger_delay
          end
          @delay_backspace += 1
        else
          str = Input.gets.force_encoding('UTF-8')
          if str.length > 0
            for i in 0...str.length
              char = str[i]
              @char_widths.push(@char_widths.last + Bitmap.text_size(char, @font).width)
              puts @text += char
            end
            render_text
          end
          @delay_backspace = 0
        end
      else
        @sprite_cursor.opacity = 0
      end
    end

    def dispose
      super
      @sprite_text.bitmap.dispose
      @sprite_text.bitmap = nil
      @sprite_text.dispose
      @sprite_text = nil
      @bitmap_text = nil
      @sprite_cursor.bitmap.dispose
      @sprite_cursor.bitmap = nil
      @sprite_cursor.dispose
      @sprite_cursor = nil
    end

    def on_got_focus
      super
      if @is_enabled
        @sprite.src_rect.y = @height * State::PRESSED
        Input.text_input = true
      end
    end

    def on_lost_focus
      super
      if @is_enabled
        @sprite.src_rect.y = @height * State::DEFAULT
      end
      Input.text_input = false
      @backspace_triggered = false
      @delay_backspace = 0
    end

  private
    def text_area_relative_x
      return @skins[State::DEFAULT].bitmap_pieces[PieceIndices::UPPER][PieceIndices::LEFT].width
    end

    def text_area_relative_y
      return @skins[State::DEFAULT].bitmap_pieces[PieceIndices::UPPER][PieceIndices::LEFT].height
    end

    def margin_width
      return @skins[State::DEFAULT].bitmap_pieces[PieceIndices::VERTICAL_CENTER][PieceIndices::LEFT].width
              + @skins[State::DEFAULT].bitmap_pieces[PieceIndices::VERTICAL_CENTER][PieceIndices::RIGHT].width
    end

    def margin_height
      return @skins[State::DEFAULT].bitmap_pieces[PieceIndices::UPPER][PieceIndices::HORIZONTAL_CENTER].height
              + @skins[State::DEFAULT].bitmap_pieces[PieceIndices::LOWER][PieceIndices::HORIZONTAL_CENTER].height
    end

    def render
      for i in 0...State::Length
        skin = @skins[i]
        upper_left   = skin.bitmap_pieces[PieceIndices::UPPER][PieceIndices::LEFT]
        upper_mid    = skin.bitmap_pieces[PieceIndices::UPPER][PieceIndices::HORIZONTAL_CENTER]
        upper_right  = skin.bitmap_pieces[PieceIndices::UPPER][PieceIndices::RIGHT]
        center_left  = skin.bitmap_pieces[PieceIndices::VERTICAL_CENTER][PieceIndices::LEFT]
        center_mid   = skin.bitmap_pieces[PieceIndices::VERTICAL_CENTER][PieceIndices::HORIZONTAL_CENTER]
        center_right = skin.bitmap_pieces[PieceIndices::VERTICAL_CENTER][PieceIndices::RIGHT]
        lower_left   = skin.bitmap_pieces[PieceIndices::LOWER][PieceIndices::LEFT]
        lower_mid    = skin.bitmap_pieces[PieceIndices::LOWER][PieceIndices::HORIZONTAL_CENTER]
        lower_right  = skin.bitmap_pieces[PieceIndices::LOWER][PieceIndices::RIGHT]

        # upper
        y = @height * i
        @bitmap.blt(0, y, upper_left, upper_left.rect)
        @bitmap.stretch_blt(Rect.new(upper_left.width, y, @width - upper_left.width - upper_right.width, upper_mid.height), upper_mid, upper_mid.rect)
        @bitmap.blt(@width - upper_right.width, y, upper_right, upper_right.rect)
        # center
        y += upper_left.height
        @bitmap.stretch_blt(Rect.new(0, y, center_left.width, @height - upper_left.height - lower_left.height), center_left, center_left.rect)
        @bitmap.stretch_blt(Rect.new(center_left.width, y, @width - center_left.width - center_right.width, @height - upper_mid.height - lower_mid.height), center_mid, center_mid.rect)
        @bitmap.stretch_blt(Rect.new(@width - center_right.width, y, center_right.width, @height - upper_right.height - lower_right.height), center_right, center_right.rect)
        # lower
        y += @height - upper_left.height - lower_left.height
        @bitmap.blt(0, y, lower_left, lower_left.rect)
        @bitmap.stretch_blt(Rect.new(lower_left.width, y, @width - lower_left.width - lower_right.width, lower_mid.height), lower_mid, lower_mid.rect)
        @bitmap.blt(@width - lower_right.width, y, lower_right, lower_right.rect)
      end
    end

    def render_text
      @bitmap_text.font = @font
      @bitmap_text.clear

      if @char_widths.last <= @bitmap_text.width
        @bitmap_text.draw_text(@bitmap_text.rect, @text)
        @sprite_cursor.x = @x + @char_widths.last
      else
        for i in (@char_widths.length - 2).downto(0)
          drawing_width = @char_widths.last - @char_widths[i]
          if drawing_width >= @bitmap_text.width
            offset = @bitmap_text.width - drawing_width
            @bitmap_text.draw_text(offset, 0, drawing_width, @bitmap_text.height, @text[i...@char_widths.length])
            break
          end
        end
        @sprite_cursor.x = @x + @bitmap_text.width
      end
    end
  end
end