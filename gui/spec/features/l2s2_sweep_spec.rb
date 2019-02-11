require 'rails_helper'

RSpec.describe "l2s2 sweep", type: :feature do
  describe "GET /sweeps" do
    describe 'index page' do
      let!(:sweep) { FactoryBot.create(:sweep) }
      before(:each) do
        visit '/sweeps'
      end
      after(:each) { Sweep.all.delete_all }
      it 'should have the program name' do
        expect(page).to have_title('Layer 2 Sweeper Service')
      end
      it 'should have link l2s2 to root' do
        expect(page).to have_link('Layer 2 Sweeper Service', :href => '/l2s2')
      end
      it 'should have Home as the page description in the navbar' do
        expect(page.all('.navbar')[0]).to have_content('Home')
      end
      it 'should have link to r2d2' do
        expect(page).to have_link('r2d2', :href => '/r2d2')
      end
      it 'should take you to the r2d2 home page when clicking the r2d2 link' do
        click_link('r2d2')
        expect(current_path).to eq('/r2d2')
      end
      it 'should display a table' do
        expect(page).to have_selector('table tr')
      end
      describe 'table' do
        it 'should have a header' do
          expect(page).to have_selector('thead')
        end
        describe 'header' do
          it 'should have Description' do
            expect(page.all('th')[0]).to have_content('Description')
          end
          it 'should have Date' do
            expect(page.all('th')[1]).to have_content('Date')
          end
          it 'should have Device Count' do
            expect(page.all('th')[2]).to have_content('Node Count')
          end
        end
        describe 'data row' do
          it 'should have a link to display the details' do
            expect(page.find_link(sweep.description, "/sweeps/#{sweep.id}"))
          end
          it 'should display the description' do
            expect(page.all('td')[0]).to have_content(sweep.description)
          end
          it 'should display the date' do
            expect(page.all('td')[1]).to have_content(sweep.created_at)
          end
          it 'should display the number of nodes' do
            expect(page.all('td')[2]).to have_content(sweep.nodes.count)
          end
        end
        describe 'should be sortable' do
          it 'by description'
          it 'by date'
          it 'by node count'
        end
      end
      describe 'big table' do
        before(:each) do
          10.times { FactoryBot.create(:sweep) }
          visit '/sweeps'
       end
        it 'should paginate if more than 10 rows' do
          expect(page).to have_selector('div.pagination')
        end
      end
    end
  end
  describe 'Get /sweeps/:id' do
    let!(:sweep) { FactoryBot.create(:sweep) }
    let!(:pref) { FactoryBot.create(:pref) }
    before(:each) { visit "/sweeps/#{sweep.id}" }
    it 'should have the sweep description in the navbar' do
      expect(page.all('.navbar-text')[0]).to have_content(sweep.description)
    end
    describe 'table' do
      it 'should be sortable by MAC'
      it 'should be sortable by IP'
      describe 'headings' do
        it 'has thead' do
          expect(page).to have_selector('thead')
        end
        it 'has MAC' do
          expect(page.all('th')[0]).to have_content('MAC')
        end
        it 'has IP' do
          expect(page.all('th')[1]).to have_content('IP')
        end
        it 'has vendor' do
          expect(page.all('th')[2]).to have_content('Vendor')
        end
      end
      describe 'data row' do
        it 'should have a link to display the details' do
          separator = pref.mac_separator
          mac = sweep.nodes[0].mac.dup
          mac.insert(10, separator).insert(8, separator).insert(6, separator).insert(4, separator).insert(2, separator)
          expect(page.find_link(mac,"/nodes/#{sweep.nodes[0].id}"))
        end
        it 'should display the MAC' do
          separator = pref.mac_separator
          mac = sweep.nodes[0].mac.dup
          mac.insert(10, separator).insert(8, separator).insert(6, separator).insert(4, separator).insert(2, separator)
          expect(page.all('td')[0]).to have_content(mac)
        end
        it 'should display the IP' do
          expect(page.all('td')[1]).to have_content(sweep.nodes[0].ip)
        end
        it 'should display the Vendor' do
          expect(page.all('td')[2]).to have_content(sweep.nodes[0].vendor)
        end
      end
    end
    describe 'big table' do
      before(:each) do
        11.times { sweep.nodes << FactoryBot.create(:node) }
        visit "/sweeps/#{sweep.id}"
      end
      it 'should paginate if more than 10 rows' do
        expect(page).to have_selector('div.pagination')
      end
    end
  end
  describe 'clicking MAC of a /sweeps/:id item' do
    let!(:pref) { FactoryBot.create(:pref) }
    let!(:sweep) { FactoryBot.create(:sweep) }
    before(:each) do
      separator = pref.mac_separator
      mac = sweep.nodes[0].mac.dup
      mac.insert(10, separator).insert(8, separator).insert(6, separator).insert(4, separator).insert(2, separator)
      visit "/sweeps/#{sweep.id}"
      click_link(mac)
    end
    it 'should go to /nodes/:id' do
      expect(current_path).to eq("/nodes/#{sweep.nodes[0].id}")
    end
  end
end
