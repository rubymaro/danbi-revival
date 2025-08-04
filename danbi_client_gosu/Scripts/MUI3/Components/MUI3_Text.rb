class MUI3::Text < MUI3::Component
  attr_accessor(:text)

  def initialize(x:, y:, width: nil, text: "MUI3::Text#{self.object_id}",
    font_name: Config::FONT_NAME, font_height: Config::FONT_HEIGHT, font_color: Gosu::Color::BLACK, align: :left)
    @gosu_font = Gosu::Font.new(font_height, {:name => font_name})
    width ||= @gosu_Font.text_width(text)
    @align = align
    @text = text
    @font_color = font_color
    super(x: x, y: y, width: width, height: font_height)
    update_image_text
  end

  def update
  end

  def update_image_text
    @gosu_image_text = Gosu::Image.from_text(@text, @gosu_font.height, {:width => @width, :font => @gosu_font.name, :align => @align})
  end

  def draw
    @gosu_image_text.draw(@real_x, @real_y, @z, 1, 1, @font_color)
  end
end