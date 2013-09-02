require_relative '../lib/emojidex/utf.rb'

describe 'Emojidex::UTF' do
  describe 'new' do
    it 'initializes and loads the utf-emoji.json file into a hash' do
      Emojidex::UTF.new
    end
  end

  describe 'list' do
    it 'gets a ruby hash of all UTF emoji' do
      utf = Emojidex::UTF.new
      utf.list
    end
  end
end
