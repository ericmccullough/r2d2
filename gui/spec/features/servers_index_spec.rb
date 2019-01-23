require 'rails_helper'

RSpec.describe 'servers', type: :feature do
  describe 'GET /servers' do
    before(:each) do
      FactoryBot.create(:list, name: 'Unassigned')
      FactoryBot.create(:server)
      visit servers_path
    end
    it 'has the program name as the title' do
      expect(page).to have_title('Remote Rogue Device Detector')
    end
    it 'has a link r2d2 to root' do
      expect(page).to have_link('Remote Rogue Device Detector', :href => '/r2d2')
    end
    it 'has Home as the page description in the navbar' do
      expect(page.all('.navbar')[0]).to have_content('Servers')
    end
    describe 'clicking the Add button' do
      it 'takes you to the new server page' do
        click_link('Add')
        expect(current_path).to eq(new_server_path)
      end
    end
    it 'displays a table' do
      expect(page).to have_selector('table')
    end
    describe 'table' do
      it 'has a header' do
        expect(page).to have_selector('thead')
      end
      describe 'header' do
        it 'has a Name column' do
          expect(page.all('th')[0]).to have_content('Name')
        end
        it 'has a IP column' do
          expect(page.all('th')[1]).to have_content('IP')
        end
        it 'has an Action column' do
          expect(page.all('th')[2]).to have_content('Action')
        end      end
      describe 'data row' do
        it 'displays the server name' do
          expect(page.all('td')[0].text).to match(Server.first.name)
        end
        it 'displays the IP address' do
          expect(page.all('td')[1]).to have_content(Server.first.ip)
        end
        it 'displays the edit icon' do
          within(page.all('td')[2]) do
            element = all('span')[0]
            expect(element['class']).to match('glyphicon-pencil')
          end
        end
        describe 'clicking the edit icon' do
          it 'takes you to the edit server page' do
            within(page.all('td')[2]) do
              all('.btn')[0].click
            end
            expect(current_path).to eq(edit_server_path(Server.first.id))
          end
        end
        it 'displays the delete icon' do
          within(page.all('td')[2]) do
            element = all('span')[1]
            expect(element['class']).to match('glyphicon-remove')
          end
        end
        
        describe 'clicking the delete icon', :js => true do
          before(:each) do
            @delete_server = FactoryBot.create(:server)
            visit servers_path
            find(:data_id, @delete_server.id).click
            #find_button("[data-id=\"#{@delete_fingerprint.id}\"]").click
          end
          it 'displays the delete modal with "Delete Server <servername>?"' do
            expect(page).to have_content("Delete Server '#{@delete_server.name}'?")
          end
          it 'deletes the server after confirmation' do
            server_count = Server.count
            click_link('Delete')
            visit servers_path # reload page because flash message has server name
            expect(page).not_to have_content(@delete_server.name)
            expect(Server.count).to eq(server_count - 1)
          end
          it 'deletes the scopes after confirmation' do
            scope_count = Scope.count
            click_link('Delete')
            expect(Scope.count).to eq(scope_count - 1)
          end
          it 'deletes the leases after confirmation' do
            lease_count = Lease.count
            click_link('Delete')
            expect(Lease.count).to eq(lease_count - 1)
          end
          it 'deletes the devices after confirmation' do
            device_count = Device.count
            click_link('Delete')
            expect(Device.count).to eq(device_count - 1)
          end
          it 'displays success message' do
            click_link('Delete')
            expect(page).to have_content("Deleted server named '#{@delete_server.name}'.")
          end
          it 'does not delete the server if cancelled' do
            click_button('Cancel')
            visit servers_path
            expect(page).to have_content(@delete_server.name)
          end
        end

      end
    end
  end
end