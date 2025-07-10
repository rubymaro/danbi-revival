class MUI3::Style < MUI3::Component
  def initialize(x:, y:, width:, height:, image:)
    super(x: x, y: y, width: width, height: height)
    @image = image
  end

  def draw
    @image.draw(@real_x, @real_y, 0)
    super
  end

  WHITE_IMAGE_PATH = "Graphics/MUI3/white_style.png"

  module WhiteForm
    def self.create(x:, y:, width:, height:)
      image_src = Gosu::Image.new(WHITE_IMAGE_PATH)
      image_pieces = [
        image_src.subimage(0, 0, 10, 32),
        image_src.subimage(10, 0, 10, 32),
        image_src.subimage(90, 0, 10, 32),
        image_src.subimage(0, 45, 10, 10),
        image_src.subimage(10, 45, 10, 10),
        image_src.subimage(90, 45, 10, 10),
        image_src.subimage(0, 90, 10, 10),
        image_src.subimage(10, 90, 10, 10),
        image_src.subimage(90, 90, 10, 10)
      ]
      image_output = Gosu::ImageUtil.create_combined_image(image_pieces, width, height)
      style = MUI3::Style.new(x: x, y: y, width: width, height: height, image: image_output)
      return style
    end
  end

  module BasicButton
    def self.create(x:, y:, width:, height:, index:)
      offset_x = 120
      offset_y = index * 32
      image_src = Gosu::Image.new(WHITE_IMAGE_PATH)
      image_pieces = [
        image_src.subimage(offset_x, offset_y, 4, 4),
        image_src.subimage(offset_x + 4, offset_y, 4, 4),
        image_src.subimage(offset_x + 60, offset_y, 4, 4),
        image_src.subimage(offset_x, offset_y + 4, 4, 4),
        image_src.subimage(offset_x + 4, offset_y + 4, 4, 4),
        image_src.subimage(offset_x + 60, offset_y + 4, 4, 4),
        image_src.subimage(offset_x, offset_y + 28, 4, 4),
        image_src.subimage(offset_x + 4, offset_y + 28, 4, 4),
        image_src.subimage(offset_x + 60, offset_y + 28, 4, 4)
      ]
      image_output = Gosu::ImageUtil.create_combined_image(image_pieces, width, height)
      style = MUI3::Style.new(x: x, y: y, width: width, height: height, image: image_output)
      return style
    end
  end
end