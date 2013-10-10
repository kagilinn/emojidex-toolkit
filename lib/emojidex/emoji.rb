#
# Emoji
#
module Emojidex
  class Emoji
    attr_reader :name
    attr_reader :unicode
    attr_reader :xml
    attr_reader :to_s
    alias tag to_s
    def initialize(emoji_data)    # emoji_data:  Hash from utf/utf-emoji.json
      @name = emoji_data['name']
      @unicode = emoji_data['moji']
      @xml = %|<emoji name="#{name}" />|
      @to_s = ":#{name}:"
    end
  end
end
