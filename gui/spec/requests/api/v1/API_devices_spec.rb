require 'rails_helper'

RSpec.describe "API Devices" do
  describe 'get /api/device/:mac' do
    let!(:list) { FactoryBot.create(:list, name:'Unassigned') }
    describe 'when successful' do
      describe 'for an existing device' do
        let!(:device) { FactoryBot.create(:device) }
        before(:each) do
          get "http://api.example.com/api/devices/#{device.mac}"
        end
        it 'returns status 200' do
          expect(response).to be_success
        end
        it 'returns one device' do
          json = JSON.parse(response.body)
          expect(json.count).to eq(2)
        end
        it 'returns the requested device\'s fields' do
          json = JSON.parse(response.body, symbolize_names: true)
          expect(json[:id]).to eq(device.id)
          expect(json[:mac]).to eq(device.mac)
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
      describe 'for a new device' do
        before(:each) do
          get "http://api.example.com/api/devices/11:22:33:44:55:66"
        end
        it 'returns status 201' do
          expect(response.status).to eq(201) # :created
        end
        it 'returns one device' do
          json = JSON.parse(response.body)
          expect(json.count).to eq(2)
        end
        it 'returns the requested device\'s fields' do
          device = Device.find_by mac: '11:22:33:44:55:66'
          json = JSON.parse(response.body, symbolize_names: true)
          expect(json[:id]).to eq(device.id)
          expect(json[:mac]).to eq('11:22:33:44:55:66')
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
    describe 'when unsuccessful' do
      it 'should NOT create a device' do
        device_count_before = Device.count
        get "http://api.example.com/api/devices/blah"
        expect(Device.count).to eq(device_count_before)
      end

      it 'returns status 422' do
        get "http://api.example.com/api/devices/blah"
        expect(status).to eq(422)
      end
    end
  end
end
