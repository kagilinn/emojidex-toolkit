module Emojidex
  class Emoji
    attr_reader :name
    attr_reader :unicode
    attr_reader :xml
    def initialize(emoji_data)    # Hash from utf/utf-emoji.json
      @name = emoji_data['name']
      @unicode = emoji_data['moji']
      @xml = %|<emoji name="#{name}" />|
    end
  end
end
