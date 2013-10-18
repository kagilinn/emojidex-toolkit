# -*- encoding: utf-8 -*-

require 'json'
require 'rsvg2'
require 'filemagic'
require 'RMagick'
require 'fileutils'

module Emojidex
  # Provides conversion facilities to create emoji 'glyphs'
  # from source images.
  class Converter
    def initialize
      @basic_sizes = [8, 16, 32, 64, 128, 256]
      @resource_sizes = { ldpi: 9, mdpi: 18, hdpi: 27, xhdpi: 36 }
      @formats = [:svg, :png, :webp]
      @def_size = 64
      @def_format = :png
    end

    # options = {
    #   format: Symbol = @def_format,
    #   size: Fixnum/Symbol = nil(ALL sizes)
    # }
    def convert_all!(utf, dest_dir_path, options={})
      dest_dir_path = File.expand_path(dest_dir_path)
      create_target_path! dest_dir_path
      unless FileTest.directory?(dest_dir_path)
        raise "%p is not a directory" % dest_dir_path
      end
      utf.each do |emoji|
        convert_from_name! utf, dest_dir_path, emoji.name, options
      end
    end

    # convert SVG to each-size PNGs, specify by emoji-name
    # options = {
    #   format: Symbol = :png,
    #   size: Fixnum/Symbol = nil(ALL sizes)
    # }
    def convert_from_name!(utf, dest_dir, emoji_name, options={})
      src = File.dirname(File.expand_path(__FILE__))
      src << "/utf/#{emoji_name}"
      src << (FileTest.directory?(src) ? '/0.svg' : '.svg')

      format = options[:format] || @def_format

      dest_dir = File.expand_path(dest_dir)
      if FileTest.exist?(dest_dir) && !FileTest.directory?(dest_dir)
        raise "%p is NOT a directory" % dest_dir
      end

      dest_file = dest_dir
      if dest_file[-1] != File::ALT_SEPARATOR &&
         dest_file[-1] != File::SEPARATOR
      then
        dest_file << "/"
      end
      dest_file << "#{emoji_name}.#{format}"

      create_target_path! File.dirname(dest_file)

      size = options[:size]
      size = (case size
        when Fixnum then size
        when Symbol then @resource_sizes[size]
        else nil
      end)

      if size.nil?
        convert_standard_sizes! src, dest_file, format
      else
        dest = get_sized_destination(dest_file, options[:size])
        convert! src, dest, size, format
        emoji = utf.where_name(emoji_name)
        emoji.reload_image! dest if emoji
      end
    end

  private
    # convert one file
    def convert!(source, dest, size = @def_size, format = @def_format)
      if FileTest.exist?(source) && FileTest.exist?(dest)
        return nil if File.mtime(source) < File.mtime(dest)
      end
      surface = get_surface(source, size)
      create_target_path! File.dirname(dest)
      surface.write_to_png dest if format == :png
    end

    # convert one SVG to each-size PNGs
    def convert_standard_sizes!(source, dest, format = @def_format)
      @basic_sizes.each do |size|
        convert!(source, get_sized_destination(dest, size.to_s),
                 size, format)
      end
      @resource_sizes.each do |size, px|
        convert!(source, get_sized_destination(dest, size.to_s),
                 px, format)
      end
    end

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
      FileUtils.mkpath(path) unless FileTest.exist?(path)
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
