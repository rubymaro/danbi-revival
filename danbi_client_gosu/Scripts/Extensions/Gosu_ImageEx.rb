module Gosu
  class ImageEx
    def self.resize(gosu_image, new_width, new_height)
      canvas = ChunkyPNG::Canvas.from_rgba_stream(gosu_image.width, gosu_image.height, gosu_image.to_blob)
      canvas.resample_bilinear!(new_width, new_height)
      resized_image = Gosu::Image.from_blob(canvas.width, canvas.height, canvas.pixels.pack('N*'))
      return resized_image
    end
  end
end