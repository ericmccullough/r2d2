require 'rails_helper'

RSpec.describe 'fingerprints', type: :feature do
  describe 'GET /fingerprints' do
    before(:each) do
      FactoryBot.create(:fingerprint)
      visit fingerprints_path
    end
    it 'has the program name as the title' do
      expect(page).to have_title('Remote Rogue Device Detector')
    end
    it 'has a link r2d2 to root' do
      expect(page).to have_link('Remote Rogue Device Detector', :href => '/r2d2')
    end
    it 'has Home as the page description in the navbar' do
      expect(page.all('.navbar')[0]).to have_content('Fingerprints')
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
        it 'has a tcp_ports column' do
          expect(page.all('th')[1]).to have_content('TCP Ports')
        end
        it 'has a upd_ports column' do
          expect(page.all('th')[2]).to have_content('UDP Ports')
        end
        it 'has a shares column' do
          expect(page.all('th')[3]).to have_content('Shares')
        end
        it 'has an Action column' do
          expect(page.all('th')[4]).to have_content('Action')
        end
      end
      describe 'data row' do
        it 'displays the fingerprint name' do
          expect(page.all('td')[0].text).to match(Fingerprint.first.name)
        end
        it 'displays the TCP ports' do
          expect(page.all('td')[1]).to have_content(Fingerprint.first.tcp_ports)
        end
        it 'displays the UDP ports' do
          expect(page.all('td')[2]).to have_content(Fingerprint.first.udp_ports)
        end
        it 'displays the shares' do
          expect(page.all('td')[3]).to have_content(Fingerprint.first.shares)
        end
        it 'displays the edit icon' do
          within(page.all('td')[4]) do
            element = all('span')[0]
            expect(element['class']).to match('glyphicon-pencil')
          end
        end
        describe 'clicking the edit icon' do
          it 'takes you to the edit fingerprint page' do
            within(page.all('td')[4]) do
              all('.btn')[0].click
            end
            expect(current_path).to eq(edit_fingerprint_path(Fingerprint.first.id))
          end
        end
        it 'displays the delete icon' do
          within(page.all('td')[4]) do
            element = all('span')[1]
            expect(element['class']).to match('glyphicon-remove')
          end
        end
        describe 'clicking the delete icon', :js => true do
          before(:all) do
            Capybara.current_driver = :webkit
          end
          after(:all) do
            Capybara.use_default_driver
          end
          before(:each) do
            @delete_fingerprint = FactoryBot.create(:fingerprint)
            visit fingerprints_path
            find(:data_id, @delete_fingerprint.id).click
            #find_button("[data-id=\"#{@delete_fingerprint.id}\"]").click
          end
          it 'displays the delete modal with "Delete Fingerprint <fingerprintname>?"' do
            expect(page).to have_content("Delete Fingerprint '#{@delete_fingerprint.name}'?")
          end
          it 'deletes the fingerprint after confirmation' do
            click_link('Delete')
            visit fingerprints_path # reload page because flash message has fingerprint name
            expect(page).not_to have_content(@delete_fingerprint.name)
          end
          it 'displays success message' do
            click_link('Delete')
            expect(page).to have_content("Deleted fingerprint named '#{@delete_fingerprint.name}'.")
          end
          it 'does not delete the fingerprint if cancelled' do
            click_button('Cancel')
            visit fingerprints_path
            expect(page).to have_content(@delete_fingerprint.name)
          end
        end
      end
    end
    describe 'has pagination controls when table has more than 10 rows' do
      before(:each) do
        FactoryBot.create_list(:fingerprint, 11)
        visit fingerprints_path
      end
      it do
        expect(page).to have_selector('div.pagination')
      end
    end
    describe 'clicking the Add button' do
      it 'takes you to the new fingerprint page' do
        click_link('Add')
        expect(current_path).to eq(new_fingerprint_path)
      end
    end
    describe 'sort fingerprint' do
      describe 'by name'
    end
  end
end
