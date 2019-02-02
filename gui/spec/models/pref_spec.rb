require 'rails_helper'

RSpec.describe Pref, type: :model do
  describe 'mac_separator field' do
    describe 'is invalid if' do
      it 'more than one character' do
        pref = Pref.new(mac_separator: '::')
        expect(pref).to be_invalid
      end
      it 'contains characters other than ":-."' do
        pref = Pref.new(mac_separator: ';')
        expect(pref).to be_invalid
      end
    end
    describe 'is valid if' do
      it 'set to ";"' do
        pref = Pref.new(mac_separator: ':')
        expect(pref).to be_valid
      end
      it 'set to "-"' do
        pref = Pref.new(mac_separator: '-')
        expect(pref).to be_valid
      end
      it 'set to "."' do
        pref = Pref.new(mac_separator: '.')
        expect(pref).to be_valid
      end
    end
    it 'is set to ":" if not set' do
      pref = Pref.create()
      expect(pref.mac_separator).to eq ':'
    end
  end
  describe 'mac_uppercase field' do
    it "is set to 'true' if not set" do
      pref = Pref.create()
      expect(pref.mac_uppercase).to eq true
    end
  end
  describe 'mac_separators field' do
    it 'is set to ":-." if not set' do
      pref = Pref.create()
      expect(pref.mac_separators).to eq ':-.'
    end
  end
end
