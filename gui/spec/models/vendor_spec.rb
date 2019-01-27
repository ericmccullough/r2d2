require 'rails_helper'

RSpec.describe Vendor, type: :model do
  describe 'is invalid if' do
    it 'empty' do
      @vendor = Vendor.new()
      expect(@vendor).to be_invalid
    end
    it "oui is not set" do
      @vendor = Vendor.new(name: 'company', oui: '')
      expect(@vendor).to be_invalid
    end
    it "name is not set" do
      @vendor = Vendor.new(name: '', oui: '112233')
      expect(@vendor).to be_invalid
    end
    it "oui is < 6 hex chars" do
      @vendor = Vendor.new(name: 'company', oui: '12345')
      expect(@vendor).to be_invalid
    end
    it "oui is > 6 hex chars" do
      @vendor = Vendor.new(name: 'company', oui: '1234567')
      expect(@vendor).to be_invalid
    end
    it "oui has non-hex chars" do
      @vendor = Vendor.new(name: 'company', oui: '12345G')
      expect(@vendor).to be_invalid
    end
    it 'not unique' do
      Vendor.create(name: 'company', oui: 'abcdef')
      @vendor = Vendor.new(name: 'company', oui: 'abcdef')
      expect(@vendor).to be_invalid
    end
  end
  describe 'is valid if' do
    it 'has a name and oui of 6 hex char' do
      @vendor = Vendor.new(name: 'company', oui: 'abcdef')
      expect(@vendor).to be_valid
    end
  end
  it 'upper cases the OUI' do
    vendor = Vendor.new(name: 'company', oui: 'abcdef')
    expect(vendor.oui).to eq('ABCDEF')
  end
  it 'removes non-hex chars?'
end
