module Gosu::ImageUtil
  UPPER_LEFT = 0
  UPPER_MID = 1
  UPPER_RIGHT = 2
  CENTER_LEFT = 3
  CENTER_MID = 4
  CENTER_RIGHT = 5
  LOWER_LEFT = 6
  LOWER_MID = 7
  LOWER_RIGHT = 8

  def self.resize(src_image:, new_width:, new_height:)
    canvas = ChunkyPNG::Canvas.from_rgba_stream(src_image.width, src_image.height, src_image.to_blob)
    canvas.resample_bilinear!(new_width, new_height)
    resized_image = Gosu::Image.from_blob(canvas.width, canvas.height, canvas.pixels.pack('N*'))
    return resized_image
  end

  def self.create_combined_image(src_images:, width:, height:)
    image_output = Gosu::Image.from_blob(width, height)

    image_new_upper_mid = self.resize(src_image: src_images[UPPER_MID],
      new_width: width - src_images[UPPER_LEFT].width - src_images[UPPER_RIGHT].width,
      new_height: src_images[UPPER_MID].height)

    image_new_center_left = self.resize(src_image: src_images[CENTER_LEFT],
      new_width: src_images[CENTER_LEFT].width,
      new_height: height - src_images[UPPER_LEFT].height - src_images[LOWER_LEFT].height)
    
    image_new_center_mid = self.resize(src_image: src_images[CENTER_MID],
      new_width: width - src_images[CENTER_LEFT].width - src_images[CENTER_RIGHT].width,
      new_height: height - src_images[UPPER_LEFT].height - src_images[LOWER_MID].height)
    
    image_new_center_right = self.resize(src_image: src_images[CENTER_RIGHT],
      new_width: src_images[CENTER_RIGHT].width,
      new_height: height - src_images[UPPER_RIGHT].height - src_images[LOWER_RIGHT].height)
    
    image_new_lower_mid = self.resize(src_image: src_images[LOWER_MID],
      new_width: width - src_images[LOWER_LEFT].width - src_images[LOWER_RIGHT].width,
      new_height: src_images[LOWER_MID].height)

    image_output.insert(src_images[UPPER_LEFT], 0, 0)
    image_output.insert(image_new_upper_mid, src_images[UPPER_LEFT].width, 0)
    image_output.insert(src_images[UPPER_RIGHT], width - src_images[UPPER_RIGHT].width, 0)

    image_output.insert(image_new_center_left, 0, src_images[UPPER_LEFT].height)
    image_output.insert(image_new_center_mid, src_images[CENTER_LEFT].width, src_images[UPPER_MID].height)
    image_output.insert(image_new_center_right, width - src_images[CENTER_RIGHT].width, src_images[UPPER_LEFT].height)

    image_output.insert(src_images[LOWER_LEFT], 0, height - src_images[LOWER_LEFT].height)
    image_output.insert(image_new_lower_mid, src_images[LOWER_LEFT].width, height - src_images[LOWER_LEFT].height)
    image_output.insert(src_images[LOWER_RIGHT], width - src_images[LOWER_RIGHT].width, height - src_images[LOWER_LEFT].height)

    return image_output
  end
end