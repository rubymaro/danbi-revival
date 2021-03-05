class Bitmap
  @@info = new(1, 1)

  def self.text_size(text, font)
    @@info.font = font
    return @@info.text_size(text)
  end

  def self.create(out_ranges, text, font, width_or_nil = nil, height_or_nil = nil)
    @@info.font = font
    char_widths = Array.new(text.length)

    max_width = (nil == width_or_nil) ? (1 << 30) : width_or_nil
    last_index = 0
    now_width = 0

    determined_width = 0
    for i in 0...text.length
      char = text[i]
      if "\n" == char
        char_widths[i] = 0
        out_ranges.push(last_index...i)
        last_index = i + 1
        determined_width = [determined_width, now_width].max
        now_width = 0
      else
        char_widths[i] = @@info.text_size(char).width
        if now_width + char_widths[i] <= max_width
          now_width += char_widths[i]
        else
          out_ranges.push(last_index...i)
          last_index = i
          determined_width = [determined_width, now_width].max
          now_width = char_widths[i]
        end
      end
    end
    if now_width > 0
      out_ranges.push(last_index..i)
      determined_width = [determined_width, now_width].max
      now_width = 0
    end
    determined_width += 1 # error
    determined_height = font.size * out_ranges.length

    return Bitmap.new(nil == width_or_nil ? determined_width : width_or_nil, nil == height_or_nil ? determined_height : height_or_nil)
  end
end