require 'rails_helper'

RSpec.describe "API Scopes " do
  describe 'get /api/scopes/:id' do
    let!(:list) { FactoryBot.create(:list, name:'Unassigned') }
    let!(:scope) { FactoryBot.create(:scope, lease_count: 0) }
    before(:each) do
      get "http://api.example.com/api/scopes/#{scope.id}"
    end
    describe 'when successful' do
      it 'returns status 200' do
        expect(response).to be_success
      end
      it 'returns one scope' do
        json = JSON.parse(response.body)
        expect(json.count).to eq(8)
      end
      it 'returns the requested scope\'s fields' do
        json = JSON.parse(response.body, symbolize_names: true)
        expect(json[:id]).to eq(scope.id)
        expect(json[:ip]).to eq(scope.ip)
        expect(json[:mask]).to eq(scope.mask)
        expect(json[:leasetime]).to eq(scope.leasetime)
        expect(json[:description]).to eq(scope.description)
        expect(json[:comment]).to eq(scope.comment)
        expect(json[:state]).to eq(scope.state)
        expect(json[:server_id]).to eq(scope.server_id)
      end
      it 'does not return the created_at field' do
        json = JSON.parse(response.body, symbolize_names: true)
        expect(json[:created_at]).to eq(nil)
      end
      it 'does not return the updated_at field' do
        json = JSON.parse(response.body, symbolize_names: true)
        expect(json[:updated_at]).to eq(nil)
      end
    end
  end

  describe 'Update scope leases using PUT /scopes/:id' do
    let!(:list) { FactoryBot.create(:list, name:'Unassigned') }
    let!(:scope) { FactoryBot.create(:scope, lease_count: 0) }
    let!(:device) { FactoryBot.create(:device) }
    describe 'when successful' do
      it 'should return status 204' do
        put "http://api.example.com/api/scopes/#{scope.id}",
          { scope:
            { leases_attributes:
              [{ ip: '1.1.1.1', mask: '255.255.255.0', expiration: '1', kind: '', name: 'fred',
                device_id: device.id 
              }]
            }
          }.to_json,
          { 'Accept' => Mime::JSON, 'Content-Type' => Mime::JSON.to_s }
        expect(response.status).to eq(204)
      end

      it 'returns an empty body' do
        put "http://api.example.com/api/scopes/#{scope.id}",
          { scope:
            { leases_attributes:
              [{ ip: '1.1.1.1', mask: '255.255.255.0', expiration: '1', kind: '', name: 'fred',
                device_id: device.id 
              }]
            }
          }.to_json,
          { 'Accept' => Mime::JSON, 'Content-Type' => Mime::JSON.to_s }
        expect(response.body.length).to eq(0)
      end

      describe 'given a lease id' do
        let!(:lease) { FactoryBot.create(:lease, scope: scope) }
        let!(:device2) { FactoryBot.create(:device) }
        let!(:node) { FactoryBot.create(:node) }
        describe 'updates only the changed' do
          before(:each) do
            @lease_count_before = Lease.count
            @lease_ip_before = lease.ip
            @lease_expiration_before = lease.expiration
            @lease_kind_before = lease.kind
            @lease_name_before = lease.name
            @lease_mask_before = lease.mask
            @lease_device_before = lease.device.id
            @lease_id = lease.id
          end
          it 'ip field' do
            put "http://api.example.com/api/scopes/#{scope.id}",
              { scope:
                { id: scope.id, 
                  leases_attributes:
                  [{ id: @lease_id, ip: node.ip }]
                }
              }.to_json,
              { 'Accept' => Mime::JSON, 'Content-Type' => Mime::JSON.to_s }
            expect(Lease.count).to eq(@lease_count_before)
            lease = Lease.find(@lease_id)
            expect(lease.ip).to eq(node.ip)
            expect(lease.expiration).to eq(@lease_expiration_before)
            expect(lease.kind).to eq(@lease_kind_before)
            expect(lease.name).to eq(@lease_name_before)
            expect(lease.mask).to eq(@lease_mask_before)
            expect(lease.device_id).to eq(@lease_device_before)
            expect(response.status).to eq(204)
          end
          it 'expiration field' do
            put "http://api.example.com/api/scopes/#{scope.id}",
              { scope:
                { id: scope.id, 
                  leases_attributes:
                  [{ id: @lease_id, ip: lease.ip, expiration: '2', kind: lease.kind, name: lease.name, mask: lease.mask, device_id: lease.device.id }]
                }
              }.to_json,
              { 'Accept' => Mime::JSON, 'Content-Type' => Mime::JSON.to_s }
            expect(Lease.count).to eq(@lease_count_before)
            lease = Lease.find(@lease_id)
            expect(lease.ip).to eq(@lease_ip_before)
            expect(lease.expiration).to eq('2')
            expect(lease.kind).to eq(@lease_kind_before)
            expect(lease.name).to eq(@lease_name_before)
            expect(lease.mask).to eq(@lease_mask_before)
            expect(lease.device_id).to eq(@lease_device_before)
            expect(response.status).to eq(204)
          end
          it 'kind field' do
            new_kind = 'DBURN'.slice!(@lease_kind_before).split('').sample
            put "http://api.example.com/api/scopes/#{scope.id}",
              { scope:
                { id: scope.id, 
                  leases_attributes:
                  [{ id: @lease_id, ip: lease.ip, expiration: lease.expiration, kind: new_kind, name: lease.name, mask: lease.mask, device_id: lease.device.id }]
                }
              }.to_json,
              { 'Accept' => Mime::JSON, 'Content-Type' => Mime::JSON.to_s }
            expect(Lease.count).to eq(@lease_count_before)
            lease = Lease.find(@lease_id)
            expect(lease.ip).to eq(@lease_ip_before)
            expect(lease.expiration).to eq(@lease_expiration_before)
            expect(lease.kind).to eq(@lease_kind_before)
            expect(lease.name).to eq(@lease_name_before)
            expect(lease.mask).to eq(@lease_mask_before)
            expect(lease.device_id).to eq(@lease_device_before)
            expect(response.status).to eq(204)
          end
          it 'name field' do
            new_name = lease.name+'1'
            put "http://api.example.com/api/scopes/#{scope.id}",
              { scope:
                { id: scope.id, 
                  leases_attributes:
                  [{ id: @lease_id, ip: lease.ip, expiration: lease.expiration, kind: lease.kind, name: new_name, mask: lease.mask, device_id: lease.device.id }]
                }
              }.to_json,
              { 'Accept' => Mime::JSON, 'Content-Type' => Mime::JSON.to_s }
            expect(Lease.count).to eq(@lease_count_before)
            lease = Lease.find(@lease_id)
            expect(lease.ip).to eq(@lease_ip_before)
            expect(lease.expiration).to eq(@lease_expiration_before)
            expect(lease.kind).to eq(@lease_kind_before)
            expect(lease.name).to eq(new_name)
            expect(lease.mask).to eq(@lease_mask_before)
            expect(lease.device_id).to eq(@lease_device_before)
            expect(response.status).to eq(204)
          end
          it 'device id field' do
            put "http://api.example.com/api/scopes/#{scope.id}",
              { scope:
                { id: scope.id, 
                  leases_attributes:
                  [{ id: @lease_id, ip: lease.ip, expiration: lease.expiration, kind: lease.kind, name: lease.name, mask: lease.mask, device_id: device2.id }]
                }
              }.to_json,
              { 'Accept' => Mime::JSON, 'Content-Type' => Mime::JSON.to_s }
            expect(Lease.count).to eq(@lease_count_before)
            lease = Lease.find(@lease_id)
            expect(lease.ip).to eq(@lease_ip_before)
            expect(lease.expiration).to eq(@lease_expiration_before)
            expect(lease.kind).to eq(@lease_kind_before)
            expect(lease.name).to eq(@lease_name_before)
            expect(lease.mask).to eq(@lease_mask_before)
            expect(lease.device_id).to eq(device2.id)
            expect(response.status).to eq(204)
          end
        end
      end
      
      it 'creates a lease if there is no lease id' do
        lease_count_before = Lease.count
        put "http://api.example.com/api/scopes/#{scope.id}",
          { scope:
            { leases_attributes:
              [{ ip: '1.1.1.1', mask: '255.255.255.0', expiration: '1', kind: '', name: '', device_id: device.id  }]
            }
          }.to_json,
          { 'Accept' => Mime::JSON, 'Content-Type' => Mime::JSON.to_s }
        expect(Lease.count).to eq(lease_count_before + 1)
      end
    
      it 'creates multiple leases if there are no lease ids' do
        lease_count_before = Lease.count
        put "http://api.example.com/api/scopes/#{scope.id}",
          { scope:
            { leases_attributes: 
              [{ ip: '1.1.1.1', mask: '255.255.255.0', expiration: '1', kind: '', name: '', device_id: device.id },
               { ip: '1.1.1.2', mask: '255.255.255.0', expiration: '2', kind: '', name: '', device_id: device.id }]
            }
          }.to_json,
          { 'Accept' => Mime::JSON, 'Content-Type' => Mime::JSON.to_s }
        expect(Lease.count).to eq(lease_count_before + 2)
      end
    end

    describe 'when unsuccessful' do
      it 'should NOT create a scope' do # invalid lease - ip is ''
        lease_count_before = Lease.count
        put "http://api.example.com/api/scopes/#{scope.id}",
          { scope:
            { leases_attributes:
              [{ leasetime: '691200', ip: '', comment: 'The Comment', description: 'The Description', state: '1', mask: '255.255.255.0', device_id: device.id }]
            }
          }.to_json,

          { 'Accept' => Mime::JSON, 'Content-Type' => Mime::JSON.to_s }
        expect(Lease.count).to eq(lease_count_before)
      end

      it 'returns status 422 for nil mask' do
        put "http://api.example.com/api/scopes/#{scope.id}",
          { scope:
            { leases_attributes:
              [{ leasetime: '691200', ip: '1.1.1.0', comment: 'The Comment', description: 'The Description', state: '1', mask: nil, device_id: device.id }]
            }
          }.to_json,

          { 'Accept' => Mime::JSON, 'Content-Type' => Mime::JSON.to_s }
        expect(status).to eq(422)
      end

      it 'returns status 422 for nil IP' do
        put "http://api.example.com/api/scopes/#{scope.id}",
          { scope:
            { leases_attributes:
              [{ leasetime: '691200', ip: nil, comment: 'The Comment', description: 'The Description', state: '1', mask: '255.255.255.0', device_id: device.id }]
            }
          }.to_json,
          { 'Accept' => Mime::JSON, 'Content-Type' => Mime::JSON.to_s }
        expect(status).to eq(422)
      end

      it 'returns status 422 for nil IP and nil mask' do
        put "http://api.example.com/api/scopes/#{scope.id}",
          { scope:
            { leases_attributes:
              [{ leasetime: '691200', ip: nil, comment: 'The Comment', description: 'The Description', state: '1', mask: nil, device_id: device.id }]
            }
          }.to_json,

          { 'Accept' => Mime::JSON, 'Content-Type' => Mime::JSON.to_s }
        expect(status).to eq(422)
      end
    end
  end
  
  describe 'get /api/scopes/:id/leases' do
    let!(:list) { FactoryBot.create(:list, name:'Unassigned') }
    let!(:scope) { FactoryBot.create(:scope, lease_count: 3) }
    before(:each) do
      get "http://api.example.com/api/scopes/#{scope.id}/leases"
    end  
    describe 'when successful' do
      it 'returns status 200' do
        expect(response).to be_success
      end

      it 'returns three leases' do
        json = JSON.parse(response.body)
        expect(json.count).to eq(3)
      end
    end
  end
end
