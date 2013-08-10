require 'spec_helper'

describe 'Emojidex::Converter' do
  it 'uses convert! to convert an svg to a single png' do
    conv = Emojidex::Converter.new
    conv.convert!(spec_root + '/support/Genshin.svg',
                  spec_root + '/out/Genshin.png')
  end

  it 'uses convert_standard_sizes! to convert svg to standard sized pngs' do
    conv = Emojidex::Converter.new
    conv.convert_standard_sizes!(spec_root + '/support/Genshin.svg',
                                 spec_root + '/out/Genshin.png')
  end
end

