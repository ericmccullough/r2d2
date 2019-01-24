require 'rails_helper'

RSpec.describe 'server', type: :feature do
  describe 'new page' do
    before(:each) do
      FactoryBot.create(:list, name: 'Unassigned')
      @server = FactoryBot.create(:server)
      visit new_server_path
    end
    it 'has the new url' do
      expect(current_path).to eq(new_server_path)
    end
    describe 'filling out form to add a server' do
      describe 'cannot add with' do
        it 'a blank name' do
          server_count = Server.count
          click_button 'Save'
          expect(page).to have_content("Name can't be blank")
          expect(Server.count).to eq(server_count)
        end
        it 'a duplicate name' do
          server_count = Server.count
          fill_in 'Name', with: @server.name
          click_button 'Save'
          expect(page).to have_content("Name has already been taken")
          expect(Server.count).to eq(server_count)
        end
        it 'a case-insensitive duplicate name' do
          server_count = Server.count
          fill_in 'Name', with: @server.name.upcase
          click_button 'Save'
          expect(page).to have_content("Name has already been taken")
          expect(Server.count).to eq(server_count)
        end
        it 'an invalid IP' do
          server_count = Server.count
          fill_in 'Name', with: 'invalid_ip_test'
          fill_in 'server_ip', with: 'web'
          click_button 'Save'
          expect(page).to have_content("Ip is invalid")
          expect(Server.count).to eq(server_count)
        end
        it 'no IP' do
          server_count = Server.count
          fill_in 'Name', with: 'invalid_ip_test'
          fill_in 'server_ip', with: ''
          click_button 'Save'
          expect(page).to have_content("Ip is invalid")
          expect(Server.count).to eq(server_count)
        end
        it 'a duplicate ip' do
          server_count = Server.count
          fill_in 'Name', with: 'duplicate_ip_test'
          fill_in 'server_ip', with: @server.ip
          click_button 'Save'
          expect(page).to have_content("Ip has already been taken")
          expect(Server.count).to eq(server_count)
        end
      end
      describe 'adds the server to servers' do
        it 'with a valid name and IP address' do
          server_count = Server.count
          fill_in 'Name', with: 'fred'
          fill_in 'server_ip', with: '1.2.3.45'
          click_button 'Save'
          expect(Server.count).to eq(server_count+1)
          expect(Server.find_by_name('fred').valid?).to eq(true)
        end
        it 'displays success message' do
          fill_in 'Name', with: "Fred's Angels"
          fill_in 'server_ip', with: '1.2.3.45'
          click_button 'Save'
          expect(page).to have_content("Added new server Fred's Angels")
        end
        it 'redirects to the servers page' do
          fill_in 'Name', with: "Fred's Angels"
          fill_in 'server_ip', with: '1.2.3.45'
          click_button 'Save'
          expect(current_path).to eq(servers_path)
        end
      end
    end
    describe 'clicking cancel' do
      it 'returns to the servers page' do
        click_link 'Cancel'
        expect(current_path).to eq(servers_path)
      end
    end
  end
end
