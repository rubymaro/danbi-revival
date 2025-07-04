class MUI3::Style
  WHITE_IMAGE_PATH = "Graphics/MUI3/white_style.png"

  ONE_PIECE_COUNT = 1
  NINE_PIECE_COUNT = 9

  UPPER_LEFT = 0
  UPPER_MID = 1
  UPPER_RIGHT = 2
  CENTER_LEFT = 3
  CENTER_MID = 4
  CENTER_RIGHT = 5
  LOWER_LEFT = 6
  LOWER_MID = 7
  LOWER_RIGHT = 8

  module WhiteForm
    def self.create(width:, height:)
      image = Gosu::Image.new(WHITE_IMAGE_PATH)
      image_pieces = Array.new(NINE_PIECE_COUNT)
      
      image_pieces[UPPER_LEFT]   = image.subimage(0, 0, 10, 32)
      image_pieces[UPPER_MID]    = image.subimage(10, 0, 10, 32)
      image_pieces[UPPER_RIGHT]  = image.subimage(90, 0, 10, 32)
      image_pieces[CENTER_LEFT]  = image.subimage(0, 45, 10, 10)
      image_pieces[CENTER_MID]   = image.subimage(10, 45, 10, 10)
      image_pieces[CENTER_RIGHT] = image.subimage(90, 45, 10, 10)
      image_pieces[LOWER_LEFT]   = image.subimage(0, 90, 10, 10)
      image_pieces[LOWER_MID]    = image.subimage(10, 90, 10, 10)
      image_pieces[LOWER_RIGHT]  = image.subimage(90, 90, 10, 10)

      style = MUI3::Style.new(width: width, height: height, image_pieces: image_pieces)

      return style
    end
  end

  def initialize(width:, height:, image_pieces:)
    @width = width
    @height = height
    @image_image_pieces = image_pieces
    @image_output = Gosu::Image.from_blob(@width, @height)

    if @image_image_pieces.size == NINE_PIECE_COUNT
      image_new_upper_mid = Gosu::ImageEx.resize(@image_image_pieces[UPPER_MID],
        @width - @image_image_pieces[UPPER_LEFT].width - @image_image_pieces[UPPER_RIGHT].width,
        @image_image_pieces[UPPER_MID].height)

      image_new_center_left = Gosu::ImageEx.resize(@image_image_pieces[CENTER_LEFT],
        @image_image_pieces[CENTER_LEFT].width,
        @height - @image_image_pieces[UPPER_LEFT].height - @image_image_pieces[LOWER_LEFT].height)
      
      image_new_center_mid = Gosu::ImageEx.resize(@image_image_pieces[CENTER_MID],
        @width - @image_image_pieces[CENTER_LEFT].width - @image_image_pieces[CENTER_RIGHT].width,
        @height - @image_image_pieces[UPPER_LEFT].height - @image_image_pieces[LOWER_MID].height)
      
      image_new_center_right = Gosu::ImageEx.resize(@image_image_pieces[CENTER_RIGHT],
        @image_image_pieces[CENTER_RIGHT].width,
        @height - @image_image_pieces[UPPER_RIGHT].height - @image_image_pieces[LOWER_RIGHT].height)
      
      image_new_lower_mid = Gosu::ImageEx.resize(@image_image_pieces[LOWER_MID],
        @width - @image_image_pieces[LOWER_LEFT].width - @image_image_pieces[LOWER_RIGHT].width,
        @image_image_pieces[LOWER_MID].height)

      @image_output.insert(@image_image_pieces[UPPER_LEFT], 0, 0)
      @image_output.insert(image_new_upper_mid, @image_image_pieces[UPPER_LEFT].width, 0)
      @image_output.insert(@image_image_pieces[UPPER_RIGHT], @width - @image_image_pieces[UPPER_RIGHT].width, 0)

      @image_output.insert(image_new_center_left, 0, @image_image_pieces[UPPER_LEFT].height)
      @image_output.insert(image_new_center_mid, @image_image_pieces[CENTER_LEFT].width, @image_image_pieces[UPPER_MID].height)
      @image_output.insert(image_new_center_right, @width - @image_image_pieces[CENTER_RIGHT].width, @image_image_pieces[UPPER_LEFT].height)

      @image_output.insert(@image_image_pieces[LOWER_LEFT], 0, @height - @image_image_pieces[LOWER_LEFT].height)
      @image_output.insert(image_new_lower_mid, @image_image_pieces[LOWER_LEFT].width, @height - @image_image_pieces[LOWER_LEFT].height)
      @image_output.insert(@image_image_pieces[LOWER_RIGHT], @width - @image_image_pieces[LOWER_RIGHT].width, @height - @image_image_pieces[LOWER_LEFT].height)

    elsif @image_image_pieces.size == ONE_PIECE_COUNT
      
    end
  end

  def draw(x:, y:)
    @image_output.draw(x, y, 0)
  end
end