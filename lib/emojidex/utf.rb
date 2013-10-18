require 'json'

module Emojidex
  # listing, search and on-the-fly conversion of standard UTF emoji
  class UTF
    include Enumerable

    attr_reader :categories
    alias categorys categories

    def initialize
      json_path = File.join(File.dirname(File.expand_path(__FILE__)),
                       './utf/utf-emoji.json')

      # lookup-table to emoji from unicode & emoji-name
      @lookup_unicode, @lookup_name = {}, {}
      @categories = {}

      @json = JSON.parse(IO.read(json_path))
      @list = @json.map {|hash|
        emoji = Emoji.new(hash)
        @categories[hash['category']] ||= []
        @categories[hash['category']] << emoji
        @lookup_unicode[emoji.unicode] = emoji
        @lookup_name[emoji.name] = emoji
        emoji
      }
      @categories.freeze
    end

    def each
      return to_enum(:each) unless block_given?
      @list.each{|emoji| yield emoji }
    end

    def where_name(name)
      return @lookup_name[name]
    end

    def where(options = {})
      return @json.select {|h|
        options.all? {|key, value| hash[key] == value }
      }.map{|h| @lookup_name[h['name']] }
    end

    def compile_assets(converter, dest_dir_path)
      converter.convert_all! self, dest_dir_path
    end

    def emojify(src_str)
      return emojify_each(src_str).map {|obj|
        obj.to_s
      }.join('')
    end

    def emojify_each(src_str)
      # if no blocks given, returns Enumerator
      return to_enum(:emojify_each, src_str) unless block_given?

      # work string buffer
      temp = ''
      src_str.chars.each do |chr|
        if @lookup_unicode[chr]                   # unicode emoji
          yield temp.dup unless temp == ''
          temp = ''
          yield @lookup_unicode[chr]
        elsif chr == "\n"                         # new line
          yield temp + "\n"
          temp = ''
        elsif chr == ':'                          # :
          temp += chr
          next unless temp =~ /^(.*)\:([^:]+)\:$/o
          s, emoji_name = $1, $2
          next unless emoji = @lookup_name[emoji_name]
          yield s unless temp == ''
          yield emoji
          temp = ''
        else                                      # other char
          temp += chr
        end
      end

      # iterate rest
      yield temp unless temp == ''
    end
  end
end
