require 'rails_helper'

RSpec.describe Lease, type: :model do
  before(:each) do
    FactoryBot.create(:list, name: 'Unassigned')
    @device = FactoryBot.create(:device)
  end
  describe 'is invalid' do
    it 'if IP is empty' do
      lease = Lease.new(ip: '')
      expect(lease).to be_invalid
    end
    it 'if IP is not valid' do
      lease = Lease.new(ip: '1.1.1', device: @device, expiration: Faker::Time)
      expect(lease).to be_invalid
    end
    it 'if device is empty' do
      lease = Lease.new(ip: '1.1.1.1', device: nil, expiration: Faker::Time)
      expect(lease).to be_invalid
    end
    it 'if expiration is empty' do
      lease = Lease.new(ip: '1.1.1.1', device: @device, expiration: nil)
      expect(lease).to be_invalid
    end
    it 'if the ip is duplicate' do
      Lease.create(ip: '1.1.1.1', device: @device, expiration: Faker::Time)
      duplicate_lease = Lease.new(ip: '1.1.1.1', device: @device, expiration: Faker::Time)
      expect(duplicate_lease).to be_invalid
    end
  end
  it 'is valid if IP, device, expiration are defined' do
    lease = Lease.new(ip: '1.1.1.1', device: @device, expiration: Faker::Time)
    expect(lease).to be_valid
  end
  it 'has a mask'
  describe 'kind' do # called type by M$
    it 'is valid if D' # DHCP
    it 'is valid if B' # BOOTP
    it 'is valid if U' # UNSPECIFIED
    it 'is valid if R' # RESERVATION IP
    it 'is valid if N' # NONE
    it 'is invalid if not DBURN'
  end
  it 'belongs to a scope'
  it 'has a name'
  it 'removes the associated device if deleted' do
    device = FactoryBot.create(:device)
    lease = Lease.create(ip: '1.1.1.1', device: device, expiration: Faker::Time)
    expect {lease.destroy}.to change{Device.count}.by(-1)
  end
end
