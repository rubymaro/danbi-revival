module RPG
  module Cache
    def self.mui(filename)
      return self.load_bitmap("Graphics/MUI/", filename)
    end
  end
end