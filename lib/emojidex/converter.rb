# -*- encoding: utf-8 -*-

require 'json'
require 'rsvg2'
require 'filemagic'
require 'RMagick'
#require 'rapngasm' #Come on kickstarter!

module Emojidex
  class Converter

    SIZES = [8, 16, 32, 64, 128, 256, ldpi: 9, mdpi: 18, hdpi: 27, xhdpi: 36]
    FORMATS = [:svg, :png, :webp]
    DEF_SIZE = 64
    DEF_FORMAT = :png

    def convert!(source, destination, size = DEF_SIZE, format = DEF_FORMAT)
      fm = FileMagic.new
      mime = fm.file source

      case mime
      when 'SVG Scalable Vector Graphics image'
        surface = svg_to_surface(source, size)
      end

      case format
      when :png
        surface.write_to_png(destination)
      end
    end

    private
    def svg_to_surface(file, target_size)
      handle = RSVG::Handle.new_from_file(file)

      dim = handle.dimensions
      ratio_w = target_size.to_f / dim.width.to_f
      ratio_h = target_size.to_f / dim.height.to_f

      surface = Cairo::ImageSurface.new(Cairo::FORMAT_ARGB32, target_size, target_size)
      context = Cairo::Context.new(surface)
      context.scale(ratio_w, ratio_h)
      context.render_rsvg_handle(handle)

      return surface
    end
  end
end
