require 'rails_helper'

RSpec.describe "API Devices" do
  describe 'Update scope leases using PUT /scopes/:id' do
  let!(:list) { FactoryBot.create(:list, name:'Unassigned') }
  let!(:scope) { FactoryBot.create(:scope, lease_count: 0) }
  let!(:device) { FactoryBot.create(:device) }
    describe 'when successful' do
      describe 'given an id' do
        let!(:lease) { FactoryBot.create(:lease, scope: scope) }
        let!(:device2) { FactoryBot.create(:device) }
        it 'updates a lease' do
          lease_count_before = Lease.count
          lease_ip_before = lease.ip
          lease_expiration_before = lease.expiration
          lease_kind_before = lease.kind
          lease_name_before = lease.name
          lease_mask_before = lease.mask
          lease_device_before = lease.device.id
          lease_id = lease.id
          put "http://api.example.com/api/scopes/#{scope.id}",
            { scope:
              { id: scope.id, 
                leases_attributes:
                [{ id: '', ip: lease.ip, expiration: lease.expiration, kind: lease.kind, name: lease.name, mask: lease.mask, device_id: lease.device.id }]
              }
            }.to_json,
            { 'Accept' => Mime::JSON, 'Content-Type' => Mime::JSON.to_s }
json = { scope:
        { id: scope.id, 
          leases_attributes:
          [{ id: lease_id, ip: lease.ip, expiration: lease.expiration, kind: lease.kind, name: lease.name, mask: lease.mask, device_id: lease.device.id }]
        }
      }.to_json
puts json
          expect(Lease.count).to eq(lease_count_before)
          lease = Lease.find(lease_id)
          expect(lease.ip).to eq(lease_ip_before)
          expect(lease.expiration).to eq(lease_expiration_before)
          expect(lease.kind).to eq(lease_kind_before)
          expect(lease.name).to eq(lease_name_before)
          expect(lease.mask).to eq(lease_mask_before)
          expect(lease.device_id).to eq(lease_device_before)
          expect(response.status).to eq(204)
        end
      end
    end
  end
end
