require 'rails_helper'

RSpec.describe 'r2d2', type: :feature do
  describe 'GET /r2d2' do
    let!(:server ) { FactoryGirl.create(:server, scope_count: 11) }
    before(:each) do
      visit '/r2d2'
    end
    it 'should have the program name' do
      expect(page).to have_title('Remote Rogue Device Detector')
    end
    it 'should have link r2d2 to root' do
      expect(page).to have_link('Remote Rogue Device Detector', :href => '/r2d2')
    end
    it 'should have Home as the page description in the navbar' do
      expect(page.all('.navbar')[0]).to have_content('Home')
    end
    it 'should have link to l2s2' do
      expect(page).to have_link('l2s2', :href => '/l2s2')
    end
    it 'should take you to the l2s2 home page when clicking the l2s2 link' do
      click_link('l2s2')
      expect(current_path).to eq('/l2s2')
    end
    it 'should display a table' do
      expect(page).to have_selector('table')
    end
    describe 'table' do
      it 'should have a header' do
        expect(page).to have_selector('thead')
      end
      describe 'header' do
        it 'should have DHCP-MAC' do
          expect(page.all('th')[0]).to have_content('DHCP-MAC')
        end
        it 'should have Status' do
          expect(page.all('th')[1]).to have_content('Status')
        end
        it 'should have DHCP-HOST' do
          expect(page.all('th')[2]).to have_content('DHCP-HOST')
        end
        it 'should have IP' do
          expect(page.all('th')[3]).to have_content('IP')
        end
        it 'should have Lease' do
          expect(page.all('th')[4]).to have_content('Lease')
        end
        it 'should have Vendor' do
          expect(page.all('th')[5]).to have_content('Vendor')
        end

      end
      describe 'data row' do
        it 'should have a link to display the details' do
          expect(page.find_link(server.scopes[0].leases[0].mac, "/leases/#{server.scopes[0].leases[0].id}"))
        end
        describe 'status column' do
          describe 'should display' do
            it 'a thumbs up icon if on the whitelist'
            it 'a thumbs down icon if on the blacklist'
            it 'an unchecked square if not on either list'
            it 'a dropdown to select value if hovered over'
          end
          describe 'should display a fingerprint icon' do
            it 'with a checkmark if all fingerprint fields are set'
            it 'with an x if not all the fingerprint fields are set'
            it 'with an i if hovered over'
          end
        end
        it 'should have DHCP name' do
          expect(page.all('td')[2]).to have_content(server.scopes[0].leases[0].name)
        end
        it 'should have IP' do
          expect(page.all('td')[3]).to have_content(server.scopes[0].leases[0].ip)
        end
        it 'should have lease expiration datetime' do
          expect(page.all('td')[4]).to have_content(server.scopes[0].leases[0].expiration)
        end
      end
    end
    it 'should have pagination controls' do
      expect(page).to have_selector('div.pagination')
    end
  end
  describe 'clicking a DHCP MAC link' do
    #let!(:scope) { FactoryGirl.create(:scope, lease_count: 1) }
    let!(:server) { FactoryGirl.create(:server, scope_count:1) }
    before(:each) do
      visit "/leases/#{server.scopes[0].leases[0].id}"
    end
    it 'should take you to /leases/:id' do
      expect(current_path).to eq("/leases/#{server.scopes[0].leases[0].id}")
    end
    it 'should have the lease MAC in the description in the navbar' do
      expect(page.all('.navbar-text')[0]).to have_content(server.scopes[0].leases[0].mac)
    end
    describe 'should display the lease' do
      it 'IP' do
        expect(page.all('p')[1]).to have_content(server.scopes[0].leases[0].ip)
      end
      it 'mask' do
        expect(page.all('p')[1]).to have_content(server.scopes[0].leases[0].mask)
      end
      it 'expiration' do
        expect(page.all('p')[2]).to have_content(server.scopes[0].leases[0].expiration)
      end
      it 'kind' do
        expect(page.all('p')[3]).to have_content(server.scopes[0].leases[0].kind)
      end
      it 'name' do
        expect(page.all('p')[4]).to have_content(server.scopes[0].leases[0].name)
      end
      it 'created_at' do
        expect(page.all('p')[5]).to have_content(server.scopes[0].leases[0].created_at)
      end
      it 'updated_at' do
        expect(page.all('p')[6]).to have_content(server.scopes[0].leases[0].updated_at)
      end
      it 'scope description' do
        expect(page.all('p')[7]).to have_content(server.scopes[0].description)
      end
      it 'scope server name' do
        expect(page.all('p')[8]).to have_content(server.name)
      end
    end
  end
end