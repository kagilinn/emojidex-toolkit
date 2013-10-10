#
# Emoji
#
module Emojidex
  class Emoji
    attr_reader :category_name
    attr_reader :name
    attr_reader :unicode
    attr_reader :xml
    attr_reader :to_s
    attr_reader :inspect
    alias category category_name
    alias tag to_s

    def initialize(emoji_data)    # emoji_data:  Hash from utf/utf-emoji.json
      @name = emoji_data['name'].dup
      @name.freeze

      @unicode = emoji_data['moji'].dup
      @unicode.freeze

      @xml = %|<emoji name="#{name}" />|
      @xml.freeze

      @to_s = ":#{name}:"
      @to_s.freeze

      @category_name = emoji_data['category']
      @category_name.freeze

      @inspect = "#<Emojidex::Emoji #{category_name}#{to_s} `#{unicode}'>"
    end
  end
end
