require 'rails_helper'

RSpec.describe List, type: :model do
  before(:each) do
    FactoryBot.create(:glyph, name: 'glyphicon-warning-sign')
    FactoryBot.create(:glyph, name: 'glyphicon-thumbs-up')
    FactoryBot.create(:glyph, name: 'glyphicon-star')
    FactoryBot.create(:glyph, name: 'glyphicon-eye-open')
  end
  describe 'name' do
    it 'is invalid if name is nil' do
      list = List.new(name: nil)
      expect(list).to be_invalid
    end
    it 'is valid if the name has a value' do
      list = List.new(name: 'Unassigned-2')
      expect(list).to be_valid
    end
    it 'is unique' do
      list = List.create(name: 'Highlander')
      list2 = List.new(name: 'Highlander')
      expect(list2).to be_invalid
      list.delete
    end
    it 'is case-insensitive' do
      list = List.create(name: 'Highlander')
      list2 = List.new(name: 'highlander')
      expect(list2).to be_invalid
      list.delete
    end
  end
  describe 'glyph' do
    it 'defaults to glyphicon-warning-sign' do
      list = List.create(name: 'default')
      expect(list.glyph_id).to eq(Glyph.find_by_name('glyphicon-warning-sign').id)
      list.delete
    end
    it 'can be set to glyphicon-star' do
      list = List.new(name: 'star', glyph_id: Glyph.find_by_name('glyphicon-star').id)
      expect(list).to be_valid
    end
    it 'can be set to glyphicon-eye-open' do
      list = List.new(name: 'star', glyph_id: Glyph.find_by_name('glyphicon-eye-open').id)
      expect(list).to be_valid
    end
    it 'cannot be set to glyphicon not defined in the set' do
      #list = List.new(name: 'star', glyph_id: Glyph.find_by_name('glyphicon-fred').id)
      #expect(list).to be_invalid
    end
  end
end
