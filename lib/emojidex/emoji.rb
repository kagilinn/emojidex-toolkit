#
# Emojidex::Emoji
#
module Emojidex
  class Emoji
    attr_reader :category_name
    attr_reader :name
    attr_reader :unicode
    attr_reader :tag
    alias category category_name

    # emoji_data(Hash)
    def initialize(emoji_data)
      @category_name = emoji_data['category'].dup
      @category_name.freeze

      @name = emoji_data['name'].dup
      @name.freeze

      @unicode = emoji_data['moji'].dup
      @unicode.freeze

      @tag = ":#{name}:"
      @tag.freeze

      @hash = emoji_data.dup
      @hash.freeze
    end

    def to_s
      @unicode or @tag
    end

    def to_json(*args)
      return @hash.to_json(*args)
    end
  end
end
