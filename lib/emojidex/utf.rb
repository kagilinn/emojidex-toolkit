require 'json'

module Emojidex
  # listing, search and on-the-fly conversion of standard UTF emoji
  class UTF
    attr_reader :list

    def initialize
      json_path = File.join(File.dirname(File.expand_path(__FILE__)),
                       './utf/utf-emoji.json')
      @lookup_unicode, @lookup_name = {}, {}
      @list = JSON.parse(IO.read(json_path)).map {|hash|
        emoji = Emoji.new(hash).freeze
        @lookup_unicode[emoji.unicode] = emoji
        @lookup_name[emoji.name] = emoji
        emoji
      }
    end

    def where(options = {})
    end

    def emojify(src_str)
      return emojify_each(src_str).map {|obj|
        case obj
          when String then obj
          when Emoji then obj.xml
        end
      }.join('')
    end

    def emojify_each(src_str)
      # if no blocks given, returns Enumerator
      return to_enum(:emojify_each, src_str) unless block_given?
      temp = ''
      src_str.chars.each do |chr|
        emoji = @lookup_unicode[chr]
        if emoji
          yield temp.dup unless temp == ''
          temp = ''
          yield emoji
        elsif chr == "\n"
          yield temp + "\n"
          temp = ''
        elsif chr == ':'
          temp += chr
          next unless temp =~ /^(.*)\:([^:]+)\:$/o
          s, emoji_name = $1, $2
          next unless emoji = @lookup_name[emoji_name]
          yield s unless temp == ''
          yield emoji
          temp = ''
        else
          temp += chr
        end
      end
      yield temp unless temp == ''
    end

private
    def emojify_unicode_xml(src_str)
      return src_str.chars.map {|c|
        emoji = @lookup_unicode[c]
        emoji ? emoji.xml : c
      }.join('')
    end

    def emojify_tag_xml(src_str)
      result, s = '', src_str
      while s =~ /^([^:]*)\:([^:]+)\:(.*)$/o
        result += $1
        emoji_name, rest = $2, $3
        emoji = @lookup_name[emoji_name]
        if emoji
          result += emoji.xml
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
