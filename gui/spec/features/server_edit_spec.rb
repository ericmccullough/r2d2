require 'rails_helper'

RSpec.describe 'server', type: :feature do
  describe 'edit page' do
    before(:each) do
      FactoryBot.create(:list, name: 'Unassigned')
      @server = FactoryBot.create(:server)
      visit edit_server_path(@server)
    end
    it 'has the edit url' do
      expect(current_path).to eq(edit_server_path(@server))
    end
    it 'displays the current name' do
      expect(find_field('server_name').value).to eq(@server.name)
    end
    it 'displays the current IP address' do
      expect(find_field('server_ip').value).to eq(@server.ip)
    end
    context 'filling in field for' do
      context 'name and clicking save' do
        it 'changes the name' do
          old_name = @server.name
          fill_in 'Name', with: 'fred'
          click_button 'Save'
          expect(page.all('td')[0]).to have_content('fred')
          expect(page).not_to have_content(old_name)
        end
        it 'does not add a new server' do
          server_count = Server.count
          fill_in 'Name', with: 'freed'
          click_button 'Save'
          expect(Server.count).to eq(server_count)
          expect(Server.find_by_name('freed').valid?).to eq(true)
        end
        it 'displays success message' do
          fill_in 'Name', with: "Fred's Angels"
          click_button 'Save'
          expect(page).to have_content("Server updated")
        end
        describe 'cannot add' do
          before(:each) { @server2 = FactoryBot.create(:server) }
          it 'blank name' do
            fill_in 'Name', with: ''
            click_button 'Save'
            expect(page).to have_content("Name can't be blank")
          end
          it 'duplicate name' do
            fill_in 'Name', with: @server2.name
            click_button 'Save'
            expect(page).to have_content("Name has already been taken")
          end
          it 'case-insensitive duplicate name' do
            fill_in 'Name', with: @server2.name.upcase
            click_button 'Save'
            expect(page).to have_content("Name has already been taken")
          end
        end
      end
      context 'IP and clicking save' do
        it 'changes the IP' do
          old_ip = @server.ip
          fill_in 'server_ip', with: '1.2.3.45'
          click_button 'Save'
          expect(page.all('td')[1]).to have_content('1.2.3.45')
          expect(page).not_to have_content(old_ip)
        end
        it 'does not add a new server' do
          server_count = Server.count
          fill_in 'server_ip', with: '1.2.3.45'
          click_button 'Save'
          expect(Server.count).to eq(server_count)
        end
        it 'displays success message' do
          fill_in 'server_ip', with: "1.2.3.45"
          click_button 'Save'
          expect(page).to have_content("Server updated")
        end        
      end
      it 'redirects to the servers page' do
        click_button 'Save'
        expect(current_path).to eq(servers_path)
      end
    end
    describe 'clicking cancel' do
      it 'does not change the name' do
        fill_in 'Name', with: 'fred'
        click_link 'Cancel'
        expect(page.all('td')[0]).to have_content(@server.name)
        expect(page).not_to have_content('fred')
      end
      it 'does not change the IP' do
        fill_in 'server_ip', with: '1.2.3.45'
        click_link 'Cancel'
        expect(page.all('td')[1]).to have_content(@server.ip)
        expect(page).not_to have_content('1.2.3.45')
      end
      it 'redirects to the servers page' do
        click_link 'Cancel'
        expect(current_path).to eq(servers_path)
      end
    end
  end
end