require 'rails_helper'

RSpec.describe Sweeper, type: :model do
  describe 'is invalid' do
    it "if empty" do
      sweeper = Sweeper.new()
      expect(sweeper).to be_invalid 
    end
    it "if mac is not set" do
      sweeper = Sweeper.new(ip: '192.168.1.1', description: '192.168.1.0/24')
      expect(sweeper).to be_invalid
    end
    it "if mac is not long enough" do
      sweeper = Sweeper.new(mac: '00:1f:f3:cd:62:d')
      expect(sweeper).to be_invalid
    end
    it "if mac is too long" do
      sweeper = Sweeper.new(mac: '00:1f:f3:cd:62:d22')
      expect(sweeper).to be_invalid
    end
    it "if mac is has invalid characters" do
      sweeper = Sweeper.new(mac: '00:1f:f3:cd:62:g2')
      expect(sweeper).to be_invalid
    end
    it 'if mac is duplicate' do
      sweeper = Sweeper.create(mac: '00:1f:f3:cd:62:d2')
      sweeper_duplicate = Sweeper.new(mac: sweeper.mac)
      expect(sweeper_duplicate).to be_invalid
    end
    it 'if mac is duplicate - case insensitive' do
      sweeper = Sweeper.create(mac: '00:1f:f3:cd:62:d2')
      sweeper_duplicate = Sweeper.new(mac: sweeper.mac.upcase)
      expect(sweeper_duplicate).to be_invalid
    end
    it 'if IP is invalid' do
      sweeper = Sweeper.new(mac: '00:1f:f3:cd:62:d2', ip: '192.168.1')
      expect(sweeper).to be_invalid
    end
  end
  it "is valid if mac is set" do
    @sweeper = Sweeper.new(mac: '00:1f:f3:cd:62:d2')
    expect(@sweeper).to be_valid
  end
  describe 'and' do
    it "IP is valid" do
      sweeper = Sweeper.new(mac: '00:1f:f3:cd:62:d2', ip: '1.1.1.1')
      expect(sweeper).to be_valid
    end
    it 'IP is empty' do
      sweeper = Sweeper.new(mac: '00:1f:f3:cd:62:d2', ip: '')
      expect(sweeper).to be_valid
    end
    it "description has a value" do
      sweeper = Sweeper.new(mac: '00:1f:f3:cd:62:d2', description: '1.0.0.0/8')
      expect(sweeper).to be_valid
    end
  end

  it 'converts the MAC to upper case' do
    sweeper = Sweeper.new(mac: '00:1f:f3:cd:62:f2', description: '1.0.0.0/8')
    expect(sweeper.mac).to eq('001FF3CD62F2')
  end
  
  it 'removes punctuation from the MAC' do
    sweeper = Sweeper.new(mac: '00:1f:f3:cd:62:f2', description: '1.0.0.0/8')
    expect(sweeper.mac).to eq('001FF3CD62F2')
  end

end
