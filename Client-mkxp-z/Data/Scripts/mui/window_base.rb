module MUI
  class WindowBase
    module MouseButtonFlags
      MOUSELEFT = 1 << 0
      MOUSEMIDDLE = 1 << 1
      MOUSERIGHT = 1 << 2

      MAPPING_INPUT_CONSTANTS = Array.new(5)
      MAPPING_INPUT_CONSTANTS[MOUSELEFT] = Input::MOUSELEFT
      MAPPING_INPUT_CONSTANTS[MOUSEMIDDLE] = Input::MOUSEMIDDLE
      MAPPING_INPUT_CONSTANTS[MOUSERIGHT] = Input::MOUSERIGHT
      VALUES = [MOUSELEFT, MOUSEMIDDLE, MOUSERIGHT]
    end

    def self.init
      @@global_zorder = 9999
      @@skin_caches ||= Hash.new

      # 이미지를 4x3 분할로 쪼개기
      src = RPG::Cache.mui("window.png")
      grid = BitmapGrid.new(row_count: 4, column_count: 3,
        offset_x: 0, offset_y: 0,
        rects: [
          Rect.new(0, 0, 10, 32),
          Rect.new(10, 0, 10, 32),
          Rect.new(90, 0, 10, 32),
  
          Rect.new(0, 32, 10, 10),
          Rect.new(10, 32, 10, 10),
          Rect.new(90, 32, 10, 10),
  
          Rect.new(0, 45, 10, 10),
          Rect.new(10, 45, 10, 10),
          Rect.new(90, 45, 10, 10),

          Rect.new(0, 90, 10, 10),
          Rect.new(10, 90, 10, 10),
          Rect.new(90, 90, 10, 10)
        ])
      @@skin_caches[:default_4x3] ||= SkinCache.new(grid.row_count, grid.column_count, grid.create_splitted_bitmaps(bitmap_src: src))

      # 이미지를 3x3 분할로 쪼개기
      src = RPG::Cache.mui("window.png")
      grid = BitmapGrid.new(row_count: 3, column_count: 3,
        offset_x: 0, offset_y: 0,
        rects: [
          Rect.new(0, 0, 10, 32),
          Rect.new(10, 0, 10, 32),
          Rect.new(90, 0, 10, 32),
  
          Rect.new(0, 45, 10, 10),
          Rect.new(10, 45, 10, 10),
          Rect.new(90, 45, 10, 10),

          Rect.new(0, 90, 10, 10),
          Rect.new(10, 90, 10, 10),
          Rect.new(90, 90, 10, 10)
        ])
      @@skin_caches[:default_3x3] ||= SkinCache.new(grid.row_count, grid.column_count, grid.create_splitted_bitmaps(bitmap_src: src))

      # 이미지를 쪼개지 않음
      src = RPG::Cache.mui("doggy.png")
      grid = BitmapGrid.new(row_count: 1, column_count: 1,
        offset_x: 0, offset_y: 0,
        rects: [
          Rect.new(0, 0, src.width, src.height)
        ])
      @@skin_caches[:default_single] ||= SkinCache.new(grid.row_count, grid.column_count, grid.create_splitted_bitmaps(bitmap_src: src))
    end

    class << self
      alias_method :window_base_new, :new
      
      def new(**args)
        raise "#{self}는 인스턴스화 할 수 없습니다." if self == MUI::WindowBase
        window_base_new(**args)
      end
    end

    attr_reader :x
    attr_reader :y
    attr_reader :z
    attr_reader :width
    attr_reader :height
    attr_reader :controls
    attr_reader :has_disposing_request
    attr_reader :viewport_frame
    attr_reader :viewport_content

  public
    def initialize(x:, y:, width:, height:, skin_key:, piece_row_count:, piece_column_count:)
      @x = x
      @y = y
      @width = nil
      @height = nil

      raise "등록되지 않은 skin_key(#{skin_key}) 입니다." if !@@skin_caches.key?(skin_key)
      @skin = @@skin_caches[skin_key]
      raise "해당 skin_key `#{skin_key}'은 #{self}과 호환되지 않습니다." if @skin.piece_row_count != piece_row_count || @skin.piece_column_count != piece_column_count

      @mouse_button_flags = 0
      @mouse_x = 0
      @mouse_y = 0
      @controls = []
      @bound_control_or_nil = nil
      @focused_control_or_nil = nil
      @has_disposing_request = false

      @viewport_frame = Viewport.new(0, 0, 0, 0)
      @viewport_frame.visible = false
      @viewport_content = Viewport.new(0, 0, 0, 0)
      @viewport_content.visible = false
      @sprite_frame = Sprite.new(@viewport_frame)

      on_got_focus

      MUIManager.add_window(window: self)

      @label_title = Label.new(x: 0, y: 0, width: 1, height: 1)
      @label_title.font.size = 16
      @label_title.font.bold = false
      @label_title.font.color = Colors::GRAY96.dup
      @label_title.alignment = AlignmentFlags::VERTICAL_CENTER | AlignmentFlags::HORIZONTAL_CENTER
      if is_draggable?
        @label_title.handler_mouse_dragging = ->(button, dx, dy) do
          if Input::MOUSELEFT == button
            @x += dx
            @y += dy
            adjust_position
          end
        end
      end
      @label_title.add_to_window_frame(window: self)

      @button_close = ButtonWithSinglePiece.new(x: 0, y: 0, width: 12, height: 10, skin_key: :x_button)
      @button_close.handler_mouse_down = if is_disposable?
        ->(button, x, y) do
          dispose if Input::MOUSELEFT == button
        end
      else
        ->(button, x, y) do
          hide if Input::MOUSELEFT == button
        end
      end
      @button_close.is_visible = has_close_button?
      @button_close.z = 1
      @button_close.add_to_window_frame(window: self)
    end

    def create_bitmap_frame
      if nil != @sprite_frame.bitmap && !@sprite_frame.bitmap.disposed?
        @sprite_frame.bitmap.dispose
        @sprite_frame.bitmap = nil
      end
      @sprite_frame.bitmap = Bitmap.new(@viewport_frame.rect.width, @viewport_frame.rect.height)
    end
    
    def x=(integer)
      @x = integer
      adjust_position
    end

    def y=(integer)
      @y = integer
      adjust_position
    end

    def z=(integer)
      @z = integer
      @viewport_frame.z = @z
      @viewport_content.z = @z
    end

    def resize(width:, height:)
      return false if @width == width && @height == height

      @width = width
      @height = height
      @viewport_content.rect.width = @width
      @viewport_content.rect.height = @height
      @viewport_frame.rect.width = frame_width
      @viewport_frame.rect.height = frame_height
      create_bitmap_frame
      render_frame
      @label_title.resize(width: frame_width, height: title_height)

      return true
    end

    def has_close_button?
      return true
    end

    def is_disposable?
      return true
    end

    def is_draggable?
      return true
    end

    def is_showing?
      return @viewport_frame.visible && @viewport_content.visible
    end

    def point_in_frame?(x:, y:)
      return x >= @viewport_frame.rect.x && x < @viewport_frame.rect.x + @viewport_frame.rect.width &&
        y >= @viewport_frame.rect.y && y < @viewport_frame.rect.y + @viewport_frame.rect.height
    end
    
    def show
      @viewport_frame.visible = true
      @viewport_content.visible = true
      MUIManager.set_focused_window(window: self)
      on_got_focus
    end

    def hide
      @viewport_frame.visible = false
      @viewport_content.visible = false
      on_lost_focus
    end

    def dispose
      raise "#{self.class} 는 disposable 속성이 없는 Window 입니다. hide를 사용하세요." if !is_disposable?
      @has_disposing_request = true
    end

    def update
      for control in @controls
        if control.is_visible
          control.update
        end
      end
    end

    def update_events
      new_mouse_button_flags = 0
      new_mouse_button_flags |= MouseButtonFlags::MOUSELEFT if Input.press?(Input::MOUSELEFT)
      new_mouse_button_flags |= MouseButtonFlags::MOUSEMIDDLE if Input.press?(Input::MOUSEMIDDLE)
      new_mouse_button_flags |= MouseButtonFlags::MOUSERIGHT if Input.press?(Input::MOUSERIGHT)

      for flag in MouseButtonFlags::VALUES
        if ((@mouse_button_flags ^ new_mouse_button_flags) & flag) != 0
          if (new_mouse_button_flags & flag) != 0
            @mouse_x = Input.mouse_x
            @mouse_y = Input.mouse_y
            on_mouse_down(button: MouseButtonFlags::MAPPING_INPUT_CONSTANTS[flag], x: Input.mouse_x, y: Input.mouse_y)
          else
            on_mouse_up(button: MouseButtonFlags::MAPPING_INPUT_CONSTANTS[flag], x: Input.mouse_x, y: Input.mouse_y)
          end
        end
        if (new_mouse_button_flags & flag) != 0 && (Input.mouse_x != @mouse_x || Input.mouse_y != @mouse_y)
          on_mouse_dragging(button: MouseButtonFlags::MAPPING_INPUT_CONSTANTS[flag], dx: Input.mouse_x - @mouse_x, dy: Input.mouse_y - @mouse_y)
          @mouse_x = Input.mouse_x
          @mouse_y = Input.mouse_y
        end
      end
      @mouse_button_flags = new_mouse_button_flags
    end
 
    def on_disposing
      for control in @controls
        control.dispose
      end
      @sprite_frame.bitmap.dispose
      @sprite_frame.bitmap = nil
      @sprite_frame.dispose
      @sprite_frame = nil
      @viewport_frame.dispose
      @viewport_frame = nil
      @viewport_content.dispose
      @viewport_content = nil
    end

    def on_got_focus
      self.z = @@global_zorder
      @@global_zorder += 1
    end

    def on_lost_focus
      for control in @controls
        control.state_mouse_over = false
      end
      @bound_control_or_nil = nil
      @focused_control_or_nil.on_lost_focus if nil != @focused_control_or_nil
      @focused_control_or_nil = nil
    end

    def on_mouse_down(button:, x:, y:)
      @bound_control_or_nil = get_control_or_nil(mouse_x: x, mouse_y: y)
      if nil != @bound_control_or_nil
        @bound_control_or_nil.on_mouse_down(button: button, x: x, y: y)
      end

      new_focused_control_or_nil = @bound_control_or_nil
      if @focused_control_or_nil != new_focused_control_or_nil
        @focused_control_or_nil.on_lost_focus if nil != @focused_control_or_nil
        new_focused_control_or_nil.on_got_focus if nil != new_focused_control_or_nil
        @focused_control_or_nil = new_focused_control_or_nil
      end
    end

    def on_mouse_up(button:, x:, y:)
      if nil != @bound_control_or_nil
        @bound_control_or_nil.on_mouse_up(button: button, x: x, y: y)
        @bound_control_or_nil = nil
        return
      end
    end

    def on_mouse_dragging(button:, dx:, dy:)
      if nil != @bound_control_or_nil
        @bound_control_or_nil.on_mouse_dragging(button: button, dx: dx, dy: dy)
        return
      end

      case button
      when Input::MOUSELEFT
        @x += dx
        @y += dy
        adjust_position
      when Input::MOUSEMIDDLE
      when Input::MOUSERIGHT
      else
        raise "invalid mouse button"
      end
    end

    def frame_width
      raise "추상 메서드 #{caller[0][/`.*'/][1..-2]} 를 구현하세요."
    end

    def frame_height
      raise "추상 메서드 #{caller[0][/`.*'/][1..-2]} 를 구현하세요."
    end

  protected
    def adjust_position
      @viewport_frame.rect.x = @x
      @viewport_frame.rect.y = @y
      @viewport_content.rect.x = @x + relative_content_x
      @viewport_content.rect.y = @y + relative_content_y
    end

    def render_frame
      raise "추상 메서드 #{caller[0][/`.*'/][1..-2]} 를 구현하세요."
    end

    def title_height
      raise "추상 메서드 #{caller[0][/`.*'/][1..-2]} 를 구현하세요."
    end

    def relative_content_x
      raise "추상 메서드 #{caller[0][/`.*'/][1..-2]} 를 구현하세요."
    end

    def relative_content_y
      raise "추상 메서드 #{caller[0][/`.*'/][1..-2]} 를 구현하세요."
    end

  private
    def get_control_or_nil(mouse_x:, mouse_y:)
      selected_or_nil = nil
      max_z = -1
      for control in @controls
        if control.is_visible && max_z < control.z && control.is_point_in_sprite?(x: mouse_x, y: mouse_y)
          max_z = control.z
          selected_or_nil = control
        end
      end

      return selected_or_nil
    end
  end
end