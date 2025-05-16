class MUI3::Form < MUI3::Component
  def initialize(x:, y:, width:, height:, style: MUI3::Style::WhiteForm)
    super(x: x, y: y, width: width, height: height)
    @style_bg = style.create(width: width, height: height)
  end

  def update
    super()

    if $game_window.mouse_left_triggered? && mouse_on?
      @pressed = true
    elsif !Gosu.button_down?(Gosu::MS_LEFT)
      @pressed = false
    end

    if @pressed
      @last_mouse_x ||= @mouse_x
      @last_mouse_y ||= @mouse_y

      dx = @mouse_x - @last_mouse_x
      dy = @mouse_y - @last_mouse_y
      @x += dx
      @y += dy
      @last_mouse_x = @mouse_x
      @last_mouse_y = @mouse_y
    else
      @last_mouse_x = nil
      @last_mouse_y = nil
    end
  end

  def draw
    @style_bg.draw(x: @x, y: @y)
  end
end