require 'rails_helper'

RSpec.describe Server, type: :model do
  describe 'is invalid' do
    it 'if name is empty' do
      server = Server.new(ip: '1.1.1.1')
      expect(server).to be_invalid
    end
    it 'if ip is empty' do
      server = Server.new(name: 'server')
      expect(server).to be_invalid
    end
    it 'if IP is invalid' do
      server = Server.new(ip: '1.1.1', name: 'server')
      expect(server).to be_invalid
    end
    it 'if the name is not unique' do
      Server.create(ip: '1.1.1.1', name: 'server')
      server2 = Server.new(ip: '1.1.1.2', name: 'server')
      expect(server2).to be_invalid
    end
    it 'if the case-insensitive name is not unique' do
      Server.create(ip: '1.1.1.1', name: 'server')
      server2 = Server.new(ip: '1.1.1.2', name: 'SeRveR')
      expect(server2).to be_invalid
    end
    it 'if the IP is not unique' do
      Server.create(ip: '1.1.1.1', name: 'server1')
      server2 = Server.new(ip: '1.1.1.1', name: 'server2')
      expect(server2).to be_invalid
    end
  end
  describe 'is valid' do
    it 'if name is not empty and the IP is valid' do
      server = Server.new(name: 'server', ip: '1.1.1.1')
      expect(server).to be_valid
    end
  end
  describe 'destroys dependent' do
    before(:each) do
      FactoryBot.create(:list, name: 'Unassigned')
      device = FactoryBot.create(:device)
      @device_count = Device.count
      lease = Lease.create(ip: '1.1.1.1', device: device, expiration: Faker::Time)
      @lease_count = Lease.count
      scope = Scope.create(ip: '1.1.1.1', mask: '255.0.0.0')
      scope.leases << lease
      @scope_count = Scope.count
      server = Server.create(ip: '1.1.1.2', name: 'server1')
      server.scopes << scope
      #server_count = Server.count
      server.destroy
    end
    it 'scopes' do
      #expect(Server.count).to eq(server_count-1)
      expect(Scope.count).to eq(@scope_count-1)
    end
    it 'leases' do
      expect(Lease.count).to eq(@lease_count-1)
    end
    it 'devices' do
      expect(Device.count).to eq(@device_count-1)
    end
  end
end
