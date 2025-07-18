class MUI3::Text < MUI3::Component
  attr_accessor(:text)

  def initialize(x:, y:, width: nil, text: "MUI3::Text#{self.object_id}",
    font_name: "Malgun Gothic", font_height: 20, font_color: Gosu::Color::BLACK, align: :left)
    @gosu_image_text = Gosu::Image.from_text(text, font_height, {:width => width, :font => font_name, :align => align})
    @align = align
    @text = text
    @font_name = font_name
    @font_color = font_color
    @font_height = font_height
    super(x: x, y: y, width: @gosu_image_text.width, height: @gosu_image_text.height)
  end

  def update
    @gosu_image_text = Gosu::Image.from_text(text, @font_height, {:width => @width, :font => @font_name, :align => @align})
  end

  def draw
    @gosu_image_text.draw(@real_x, @real_y, @z, 1, 1, @font_color)
  end
end