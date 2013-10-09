require 'json'

module Emojidex
  # listing, search and on-the-fly conversion of standard UTF emoji
  class UTF
    attr_reader :list

    def initialize
      json_path = File.join(File.dirname(File.expand_path(__FILE__)),
                       './utf/utf-emoji.json')
      @list = JSON.parse(IO.read(json_path))
      @lookup_unicode, @lookup_name = {}, {}
      @list.each do |emoji|
        emoji['xml'] = %|<emoji name="#{emoji['name']}" />|
        @lookup_unicode[emoji['moji']] = emoji
        @lookup_name[emoji['name']] = emoji
      end
    end

    def where(options = {})
    end

    def emojify(src_str)
      src_str.lines.map {|line|
        emojify_unicode(emojify_tag(line))
      }.join("\n")
    end

private
    def emojify_unicode(src_str)
      return src_str.chars.map {|c|
        emoji = @lookup_unicode[c]
        emoji ? emoji['xml'] : c
      }.join('')
    end

    def emojify_tag(src_str)
      result, s = '', src_str
      while s =~ /^([^:]*)\:([^:]+)\:(.*)$/o
        result += $1
        emoji_name, rest = $2, $3
        emoji = @lookup_name[emoji_name]
        if emoji
          result += emoji['xml']
          s = rest
        else
          result += ':'
          s = emoji_name + ':' + rest
        end
      end
      return result
    end
  end
end
