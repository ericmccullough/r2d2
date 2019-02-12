require 'rails_helper'

RSpec.describe Node, type: :model do
  describe 'is invalid' do
    it 'if empty' do
      node = Node.new()
      expect(node).to be_invalid 
    end
    it 'if mac is not set' do
      node = Node.new(ip: '192.168.1.1')
      expect(node).to be_invalid
    end
    it 'if IP is not set' do
      node = Node.new(mac: '00:1f:f3:cd:62:d2')
      expect(node).to be_invalid
    end
    it 'if IP is not valid' do
      node = Node.new(mac: '00:1f:f3:cd:62:d2', ip: '192.168.1')
      expect(node).to be_invalid
    end
    it 'if mac is not long enough' do
      node = Node.new(mac: '00:1f:f3:cd:62:d', ip: '192.168.1.1')
      expect(node).to be_invalid
    end
    it 'if mac is too long' do
      node = Node.new(mac: '00:1f:f3:cd:62:d22', ip: '192.168.1.1')
      expect(node).to be_invalid
    end
    it 'if mac is has invalid characters' do
      node = Node.new(mac: '00:1f:f3:cd:62:g2', ip: '192.168.1.1')
      expect(node).to be_invalid
    end
    it 'if mac is nil' do
      node = Node.new(mac: nil, ip: '192.168.1.1')
      expect(node).to be_invalid
    end    
  end

  it 'converts the MAC to upper case' do
    node = Node.new(mac: '00:1f:f3:cd:62:f2', ip: '192.168.1.1')
    expect(node.mac).to eq('001FF3CD62F2')
  end
  
  it 'removes punctuation from the MAC' do
    node = Node.new(mac: '00:1f:f3:cd:62:f2', ip: '192.168.1.1')
    expect(node.mac).to eq('001FF3CD62F2')
  end

  it "should have a unique mac?"
  it "is valid if required fields are set" do
    node = Node.new(mac: '00:1f:f3:cd:62:d2', ip: '192.168.1.1')
    expect(node).to be_valid
  end
  it 'does a Vendor lookup' do
    Vendor.create(name: 'The Republic', oui: '001FF3')
    node = Node.create(mac: '00:1f:f3:cd:62:f2', ip: '192.168.1.1')
    expect(node.vendor).to eq('The Republic')
  end

  it 'returns UNKNOWN if vendor not found' do
    node = Node.create(mac: '00:1f:f3:cd:62:f2', ip: '192.168.1.1')
    expect(node.vendor).to eq('UNKNOWN')
  end
end
