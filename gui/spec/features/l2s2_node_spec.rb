require 'rails_helper'

RSpec.describe "l2s2 node/:id", type: :feature do
  describe "GET /nodes/:id" do
    let!(:sweep) { FactoryBot.create(:sweep) }
    before(:each) do
      visit "/nodes/#{sweep.nodes[0].id}"
    end
    it 'should have the node MAC in the description in the navbar' do
      expect(page.all('.navbar-text')[0]).to have_content(sweep.nodes[0].mac)
    end
    describe 'table' do
      describe 'headings' do
        it 'should have Sweep' do
          expect(page.all('th')[0]).to have_content('Sweep')
        end
        it 'should have Timestamp' do
          expect(page.all('th')[1]).to have_content('Timestamp')
        end
        it 'should have Node Count' do
          expect(page.all('th')[2]).to have_content('Node Count')
        end
      end
      describe 'data row' do
        it 'should display the description' do
          expect(page.all('td')[0]).to have_content(sweep.description)
        end
        it 'should have a link to the Sweep' do
          expect(page).to have_link(sweep.description, :href => "/sweeps/#{sweep.id}")
        end
        it 'should display the Sweep timestamp' do
          expect(page.all('td')[1]).to have_content(sweep.nodes[0].created_at)
        end
        it 'should display the node count' do
          expect(page.all('td')[2]).to have_content(sweep.nodes.count)
        end
      end
    end
    describe 'big table' do
      before(:each) do
        10.times do
          Sweep.create(description: sweep.description, nodes: sweep.nodes)
        end
        visit "/nodes/#{sweep.nodes[0].id}"
      end
      it 'should paginate if more than 10 rows' do
        expect(page).to have_selector('div.pagination')
      end
    end
  end
end
