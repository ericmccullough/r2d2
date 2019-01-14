require 'rails_helper'

RSpec.describe "API Servers" do
  describe 'get /api/servers' do
    before(:each) do
      @servers =  FactoryBot.create_list(:server, 3, scope_count: 0)
      get "http://api.example.com/api/servers"
    end  
   describe 'when successful' do
      it 'returns status 200' do
        expect(response).to be_success
      end
      it 'returns all the servers' do
        json = JSON.parse(response.body)
        expect(json.count).to eq(3)
      end
      it 'returns all the server\'s details' do
        json = JSON.parse(response.body, symbolize_names: true)
        json.each do |j|
          @servers.each do |s|
            if j[:id] == s.id
              expect(j[:name]).to eq(s.name)
              expect(j[:ip]).to eq(s.ip)
            end
          end
        end
      end
      it 'does not return the created_at field' do
        json = JSON.parse(response.body, symbolize_names: true)
        json.each do |j|
          @servers.each do |s|
            if j[:id] == s.id
              expect(j[:created_at]).to eq(nil)
            end
          end
        end
      end
      it 'does not return the updated_at field' do
        json = JSON.parse(response.body, symbolize_names: true)
        json.each do |j|
          @servers.each do |s|
            if j[:id] == s.id
              expect(j[:updated_at]).to eq(nil)
            end
          end
        end
      end
    end
  end

  describe 'get /api/servers/:id' do
    let!(:server) { FactoryBot.create(:server, scope_count: 0) }
    before(:each) do
      get "http://api.example.com/api/servers/#{server.id}"
    end  
    describe 'when successful' do
      it 'returns status 200' do
        expect(response).to be_success
      end
      it 'returns the requested server' do
        json = JSON.parse(response.body, symbolize_names: true)
        expect(json[:id]).to eq(server.id)
        expect(json[:ip]).to eq(server.ip)
        expect(json[:name]).to eq(server.name)
      end
      it 'returns one server' do
        json = JSON.parse(response.body)
        expect(json.count).to eq(3)
      end
    end
  end

  describe 'Update server scopes using PUT /api/servers/:id' do
    let!(:server) { FactoryBot.create(:server, scope_count: 0) }
    describe 'when successful' do
      before(:each) do
        put "http://api.example.com/api/servers/#{server.id}",
          { server:
            { scopes_attributes:
              [{ leasetime: '691200', ip: '1.1.1.0', comment: 'The Comment', description: 'The Description', state: '1', mask: '255.255.255.0' }]
            }
          }.to_json,
          { 'Accept' => Mime::JSON, 'Content-Type' => Mime::JSON.to_s }
      end

      it 'returns status 204' do # :no_content
        expect(response.status).to eq(204)
      end

      it 'returns an empty body' do
        expect(response.body.length).to eq(0)
      end

      it 'updates a scope when it already exists (has an id)' do
        scope = Scope.first
        scope_count_before = Scope.count
        put "http://api.example.com/api/servers/#{server.id}",
          { server:
            { scopes_attributes:
              [{ id: scope.id, leasetime: '2', ip: '2.1.1.0', comment: 'The Comment2', description: 'The Description2', state: '2', mask: '255.255.255.2' }]
            }
          }.to_json,
          { 'Accept' => Mime::JSON, 'Content-Type' => Mime::JSON.to_s }
        expect(Scope.count).to eq(scope_count_before)
        scope = Scope.first
        expect(scope.ip).to eq('2.1.1.0')
        expect(scope.leasetime).to eq('2')
        expect(scope.comment).to eq('The Comment2')
        expect(scope.description).to eq('The Description2')
        expect(scope.state).to eq('2')
        expect(scope.mask).to eq('255.255.255.2')
      end

      it 'creates a scope if it does not have an id' do
        scope_count_before = Scope.count
        put "http://api.example.com/api/servers/#{server.id}",
          { server:
            { scopes_attributes:
              [{ leasetime: '691200', ip: '2.1.1.0', comment: 'The Comment', description: 'The Description', state: '1', mask: '255.255.255.0' }]
            }
          }.to_json,
          { 'Accept' => Mime::JSON, 'Content-Type' => Mime::JSON.to_s }
        expect(Scope.count).to eq(scope_count_before + 1)
      end

      it 'creates multiple scopes' do
        scope_count_before = Scope.count
        put "http://api.example.com/api/servers/#{server.id}",
          { server:
            { scopes_attributes:
              [{ leasetime: '691200', ip: '2.1.1.0', comment: 'The Comment2', description: 'The Description2', state: '1', mask: '255.255.255.0' },
               { leasetime: '84500', ip: '3.1.1.0', comment: 'The Comment3', description: 'The Description3', state: '1', mask: '255.255.255.0' }]
            }
          }.to_json,
          { 'Accept' => Mime::JSON, 'Content-Type' => Mime::JSON.to_s }
        expect(Scope.count).to eq(scope_count_before + 2)
      end
    end

    describe 'when unsuccessful' do
      it 'should NOT create a scope' do
        scope_count_before = Scope.count
        put "http://api.example.com/api/servers/#{server.id}",
          { server:
            { scopes_attributes:
              [{ leasetime: '691200', ip: '', comment: 'The Comment', description: 'The Description', state: '1', mask: '255.255.255.0' }]
            }
          }.to_json,

          { 'Accept' => Mime::JSON, 'Content-Type' => Mime::JSON.to_s }
        expect(Scope.count).to eq(scope_count_before)
      end

      it 'returns status 422 for nil mask' do
        put "http://api.example.com/api/servers/#{server.id}",
          { server:
            { scopes_attributes:
              [{ leasetime: '691200', ip: '1.1.1.0', comment: 'The Comment', description: 'The Description', state: '1', mask: nil }]
            }
          }.to_json,

          { 'Accept' => Mime::JSON, 'Content-Type' => Mime::JSON.to_s }
        expect(status).to eq(422)
      end

      it 'returns status 422 for nil IP' do
        put "http://api.example.com/api/servers/#{server.id}",
          { server:
            { scopes_attributes:
              [{ leasetime: '691200', ip: nil, comment: 'The Comment', description: 'The Description', state: '1', mask: '255.255.255.0' }]
            }
          }.to_json,
          { 'Accept' => Mime::JSON, 'Content-Type' => Mime::JSON.to_s }
        expect(status).to eq(422)
      end

      it 'returns status 422 for nil IP and nil mask' do
        put "http://api.example.com/api/servers/#{server.id}",
          { server:
            { scopes_attributes:
              [{ leasetime: '691200', ip: nil, comment: 'The Comment', description: 'The Description', state: '1', mask: nil }]
            }
          }.to_json,

          { 'Accept' => Mime::JSON, 'Content-Type' => Mime::JSON.to_s }
        expect(status).to eq(422)
      end
    end
  end

  describe 'get /api/servers/:id/scopes' do
    let!(:list) { FactoryBot.create(:list, name:'Unassigned') }
    let!(:server) { FactoryBot.create(:server, scope_count: 3) }
    before(:each) do
      get "http://api.example.com/api/servers/#{server.id}/scopes"
    end  
    describe 'when successful' do
      it 'returns status 200' do
        expect(response).to be_success
      end

      it 'returns three scopes' do
        json = JSON.parse(response.body)
        expect(json.count).to eq(3)
      end
    end
  end
end
