require 'rails_helper'

RSpec.describe Device, type: :model do
  before(:each) do
    @list = FactoryBot.create(:list, name: 'Unassigned')
  end
  
  describe 'is invalid if ' do
    it "empty" do
      device = Device.new()
      expect(device).to be_invalid
    end
  
    it "MAC is not set" do
      device = Device.new(mac: '', list: @list)
      expect(device).to be_invalid
    end
  
    it "MAC is not long enough" do
      device = Device.new(mac: '00:1f:f3:cd:62:d', list: @list)
      expect(device).to be_invalid
    end
  
    it "MAC is too long" do
      device = Device.new(mac: '00:1f:f3:cd:62:d22', list: @list)
      expect(device).to be_invalid
    end
  
    it "MAC is has invalid characters" do
      device = Device.new(mac: '00:1f:f3:cd:62:g2', list: @list)
      expect(device).to be_invalid
    end

    it "if it is not unique" do
      device = Device.create(mac: '00:1f:f3:cd:62:f2', list: @list)
      duplicate_device = Device.new(mac: device.mac)
      expect(duplicate_device).to be_invalid
    end
  end
  
  it 'is valid if the MAC and list are valid' do
    device = Device.new(mac: '00:1f:f3:cd:62:f2', list: @list)
    expect(device).to be_valid
  end

  it 'converts the MAC to upper case' do
    device = Device.new(mac: '00:1f:f3:cd:62:f2', list: @list)
    expect(device.mac).to eq('001FF3CD62F2')
  end
  
  it 'removes punctuation from the MAC' do
    device = Device.new(mac: '00:1f:f3:cd:62:f2', list: @list)
    expect(device.mac).to eq('001FF3CD62F2')
  end

  it 'has a notes field' do
    note = 'This is a note'
    device = Device.create(mac: '00:1f:f3:cd:62:f2', list: @list, notes: note)
    expect(device.notes).to eq(note)
  end

  it "sets the list to 'Unassigned' if not set" do
    device = Device.create(mac: '00:1f:f3:cd:62:f2', list: nil)
    list = Device.find(device.id).list
    expect(list.name).to eq 'Unassigned'
  end

  it 'does a Vendor lookup' do
    Vendor.create(name: 'The Republic', oui: '001FF3')
    device = Device.create(mac: '00:1f:f3:cd:62:f2', list: @list)
    expect(device.vendor).to eq('The Republic')
  end

  it 'returns UNKNOWN if vendor not found' do
    device = Device.create(mac: '00:1f:f3:cd:62:f2', list: @list)
    expect(device.vendor).to eq('UNKNOWN')
  end
  
  it 'can have a fingerprint assigned'
end
