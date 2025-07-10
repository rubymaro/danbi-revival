class MUI3::Image < MUI3::Component
  attr_reader(:gosu_image)
  attr_reader(:gosu_subimage)

  def initialize(x:, y:, width:, height:, gosu_image:)
    super(x: x, y: y, width: width, height: height)
    @gosu_image = gosu_image
    subimage!(x: x, y: y, width: width, height: height)
  end

  def update

  end

  def draw
    @gosu_subimage.draw(@real_x, @real_y, @z)
  end

  def subimage!(x:, y:, width:, height:)
    @gosu_subimage = @gosu_image.subimage(x, y, width, height)
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
      image_output = Gosu::ImageUtil.create_combined_image(src_images: image_pieces, width: width, height: height)
      image = MUI3::Image.new(x: x, y: y, width: width, height: height, gosu_image: image_output)
      return image
    end
  end

  module BasicButtonSet
    def self.create(x:, y:, width:, height:, state_count: 4)
      image_buttonset = Gosu::Image.from_blob(width, height * state_count)
      image_src = Gosu::Image.new(WHITE_IMAGE_PATH)
      offset_x = 120
      for index in 0...state_count
        offset_y = index * 32
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
        image_output = Gosu::ImageUtil.create_combined_image(src_images: image_pieces, width: width, height: height)
        image_buttonset.insert(image_output, 0, index * height)
      end
      image = MUI3::Image.new(x: x, y: y, width: width, height: height, gosu_image: image_buttonset)
      return image
    end
  end
end