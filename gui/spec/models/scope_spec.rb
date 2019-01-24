require 'rails_helper'

RSpec.describe Scope, type: :model do
  describe 'is invalid' do
    it 'if IP is not defined' do
      scope = Scope.new(mask: '255.0.0.0')
      expect(scope).to be_invalid
    end
    it 'if the mask is not defined' do
      scope = Scope.new(ip: '1.1.1.1')
      expect(scope).to be_invalid
    end
    it 'if the IP is not valid' do
      scope = Scope.new(ip: '355.1.1.1', mask: '255.0.0.0')
      expect(scope).to be_invalid
    end
    it 'if the mask is not valid' do
      scope = Scope.new(ip: '1.1.1.1', mask: '355.0.0.0')
      expect(scope).to be_invalid
    end   
  end
  describe 'is valid' do
    it 'if IP and mask are defined' do
      scope = Scope.new(ip: '1.1.1.1', mask: '255.0.0.0')
      expect(scope).to be_valid
    end
    it 'if the IP is unique' do
      scope1 = Scope.create(ip: '1.1.1.1', mask: '255.0.0.0')
      scope2 = Scope.new(ip: '1.1.1.1', mask: '255.255.0.0')
      expect(scope1).to be_valid
      expect(scope2).to be_invalid
    end
  end
  it 'removes the associated Lease if deleted' do
    FactoryBot.create(:list, name: 'Unassigned')
    device = FactoryBot.create(:device)
    lease = Lease.create(ip: '1.1.1.1', device: device, expiration: Faker::Time)
    scope = Scope.new(ip: '1.1.1.1', mask: '255.0.0.0')
    scope.leases << lease
    expect {scope.destroy}.to change{Lease.count}.by(-1)
  end
end
