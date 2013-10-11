# -*- encoding: utf-8 -*-

require 'json'
require 'rsvg2'
require 'filemagic'
require 'RMagick'
# require 'rapngasm'

module Emojidex
  # Provides conversion facilities to create emoji 'glyphs'
  # from source images.
  class Converter
    #
    # class methods
    #
    def self.convert_all!(utf, dest_dir_path, format = :png)
      Dir.mkdir(dest_dir_path) unless FileText.exist?(dest_dir_path)
      raise("%p is not a directory" % dest_dir_path) if FileTest.directory?(dest_dir_path)
      conv = self.new
      utf.list.each do |emoji|
        conv.convert_from_name! emoji.name, dest_dir_path, format
      end
    end

    #
    # instance methods
    #
    def initialize
      @basic_sizes = [8, 16, 32, 64, 128, 256]
      @resource_sizes = { ldpi: 9, mdpi: 18, hdpi: 27, xhdpi: 36 }
      @formats = [:svg, :png, :webp]
      @def_size = 64
      @def_format = :png
    end

    # convert one file
    def convert!(source, destination, size = @def_size, format = @def_format)
      if FileTest.exist?(source) && FileTest.exist?(destination)
        return nil if File.mtime(source) < File.mtime(destination)
      end

      surface = get_surface(source, size)

      create_target_path! File.dirname(destination)

      case format
      when :png
        surface.write_to_png(destination)
      end
    end

    # convert one SVG to each-size PNGs
    def convert_standard_sizes!(source, destination, format = @def_format)
      @basic_sizes.each do |size|
        convert!(source, get_sized_destination(destination, size.to_s),
                 size, format)
      end

      @resource_sizes.each do |size, px|
        convert!(source, get_sized_destination(destination, size.to_s),
                 px, format)
      end
    end

    # convert SVG to each-size PNGs, specify by emoji-name
    def convert_from_name!(emoji_name, dest_path, format = :png)    # String, String, Symbol = :png
      src = File.dirname(File.expand_path(__FILE__)) + "/utf/#{emoji_name}"
      src = (if FileTest.directory?(src)
        src + '/0.svg'
      else
        src + '.svg'
      end)

      # if dest is a directory-path, then make picture's path from emoji-name.
      dest = (if !FileTest.directory?(dest_path)
        dest_path
      elsif dest_path[-1] == File::ALT_SEPARATOR || dest_path[-1] == File::SEPARATOR
        "#{dest_path}#{emoji_name}.#{format}"
      else
        "#{dest_path}/#{emoji_name}.#{format}"
      end)

      convert_standard_sizes! src, dest, format
    end

    private

    def get_surface(source, size)
      fm = FileMagic.new
      mime = fm.file source

      case mime
      when 'SVG Scalable Vector Graphics image'
        return svg_to_surface(source, size)
      end
    end

    def get_sized_path(destination, size)
      path = File.dirname(destination)
      path << "/#{size}/"
    end

    def get_sized_destination(destination, size)
      get_sized_path(destination, size) << File.basename(destination)
    end

    def create_target_path!(path)
      Dir.mkdir(path) unless FileTest.exist?(path)
    end

    def svg_to_surface(file, target_size)
      handle = RSVG::Handle.new_from_file(file)

      dim = handle.dimensions
      ratio_w = target_size.to_f / dim.width.to_f
      ratio_h = target_size.to_f / dim.height.to_f

      surface = Cairo::ImageSurface.new(Cairo::FORMAT_ARGB32, target_size,
                                        target_size)
      context = Cairo::Context.new(surface)
      context.scale(ratio_w, ratio_h)
      context.render_rsvg_handle(handle)

      surface
    end
  end
end
