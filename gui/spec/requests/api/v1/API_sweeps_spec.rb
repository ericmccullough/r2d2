require 'rails_helper'

RSpec.describe "API" do
  describe 'Create sweeps using POST /sweeps' do
    describe 'when successful' do
      before(:each) do
        post 'http://api.example.com/api/sweeps/',
          { sweep:
            { description: '1.1.1.0/24', nodes_attributes:
              [{ mac: '00:11:22:33:44:55', ip: '1.1.1.1' }]
            }
          }.to_json,
          { 'Accept' => Mime::JSON, 'Content-Type' => Mime::JSON.to_s }
      end

      it 'should return status 201' do
        expect(response).to be_created
      end

      it 'should create a sweep' do
        sweep_count_before = Sweep.count
        post 'http://api.example.com/api/sweeps/',
          { sweep:
            { description: '1.1.1.0/24', nodes_attributes:
                [{ mac: '00:11:22:33:44:55', ip: '1.1.1.2' }]
            }
          }.to_json,
          { 'Accept' => Mime::JSON, 'Content-Type' => Mime::JSON.to_s }
        expect(Sweep.count).to eq(sweep_count_before + 1)
      end

      it 'should create a node'do
        expect(Node.find_by_mac('001122334455').id).to be_truthy
      end
      
      it 'should create all devices' do
        post 'http://api.example.com/api/sweeps/',
          { sweep:
            { description: '1.1.1.0/24', nodes_attributes:
              [{ mac: '00:11:22:33:44:66',ip: '1.1.1.1' },{ mac: '00:11:22:33:44:55',ip: '1.1.1.2' }]
            }
          }.to_json,
          { 'Accept' => Mime::JSON, 'Content-Type' => Mime::JSON.to_s }
        expect(Node.find_by_mac('001122334466').id).to be_truthy
        expect(Node.find_by_ip('1.1.1.1').id).to be_truthy
        expect(Node.find_by_mac('001122334455').id).to be_truthy
        expect(Node.find_by_ip('1.1.1.2').id).to be_truthy
      end
    end

    describe 'when unsuccessful' do
      it 'should NOT create a sweep' do
        sweep_count_before = Sweep.count
        post 'http://api.example.com/api/sweeps/',
          { sweep:
            { description: '1.1.1.0/24', nodes_attributes:
              [{ mac: nil, ip: '1.1.1.1' }]
            }
          }.to_json,
          { 'Accept' => Mime::JSON, 'Content-Type' => Mime::JSON.to_s }
        expect(Sweep.count).to eq(sweep_count_before)
      end

      it 'returns status 422 for nil mac' do
        post 'http://api.example.com/api/sweeps/',
          { sweep:
            { description: '1.1.1.0/24', nodes_attributes:
              [{ mac: nil, ip: '1.1.1.1' }]
            }
          }.to_json,
          { 'Accept' => Mime::JSON, 'Content-Type' => Mime::JSON.to_s }
        expect(status).to eq(422)
      end

      it 'returns status 422 for nil IP' do
        post 'http://api.example.com/api/sweeps/',
          { sweep:
            { description: '1.1.1.0/24', nodes_attributes:
              [{ mac: '00:11:22:33:44:55', ip: nil }]
            }
          }.to_json,
          { 'Accept' => Mime::JSON, 'Content-Type' => Mime::JSON.to_s }
        expect(status).to eq(422)
      end

      it 'returns status 422 for nil IP and nil mac' do
        post 'http://api.example.com/api/sweeps/',
          { sweep:
            { description: '1.1.1.0/24', nodes_attributes:
              [{ mac: nil, ip: nil }]
            }
          }.to_json,
          { 'Accept' => Mime::JSON, 'Content-Type' => Mime::JSON.to_s }
        expect(status).to eq(422)
      end
    end
  end
end
