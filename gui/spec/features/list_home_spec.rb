require 'rails_helper'

RSpec.describe 'list', type: :feature do
  describe 'GET /lists' do
    before(:each) do
      Glyph.create([
           { name: 'glyphicon-unchecked' },
           { name: 'glyphicon-thumbs-up' },
           { name: 'glyphicon-thumbs-down' },
           { name: 'glyphicon-warning-sign' },
           { name: 'glyphicon-eye-open' },
           { name: 'glyphicon-star' }
          ])
      List.create([
           { name: 'Unassigned', glyph_id: Glyph.find_by_name('glyphicon-unchecked').id },
           { name: 'Whitelist', glyph_id: Glyph.find_by_name('glyphicon-thumbs-up').id },
           { name: 'Blacklist', glyph_id: Glyph.find_by_name('glyphicon-thumbs-down').id }
        ])
      visit lists_path
    end
    it 'has the program name as the title' do
      expect(page).to have_title('Remote Rogue Device Detector')
    end
    it 'has a link r2d2 to root' do
      expect(page).to have_link('Remote Rogue Device Detector', :href => '/r2d2')
    end
    it 'has Home as the page description in the navbar' do
      expect(page.all('.navbar')[0]).to have_content('Lists')
    end
    it 'displays a table' do
      expect(page).to have_selector('table')
    end
    describe 'table' do
      it 'has a header' do
        expect(page).to have_selector('thead')
      end
      describe 'header' do
        it 'has a Glyph column' do
          expect(page.all('th')[0]).to have_content('Glyph')
        end
        it 'has a Name column' do
          expect(page.all('th')[1]).to have_content('Name')
        end
        it 'has a Count column' do
          expect(page.all('th')[2]).to have_content('Count')
        end
        it 'has an Action column' do
          expect(page.all('th')[3]).to have_content('Action')
        end
      end
      describe 'data row' do
        before(:each) do
          FactoryBot.create(:device, list: List.first)
          visit lists_path
        end
        it 'displays the list glyph' do
          within(page.all('td')[0]) do
            element = all('span')[0]
            expect(element['class']).to match(List.first.glyph.name)
          end
        end
        it 'displays the list name' do
          expect(page.all('td')[1]).to have_content(List.first.name)
        end
        it 'displays the member count' do
          expect(page.all('td')[2]).to have_content('1')
        end
        it 'displays the member count if zero' do
          expect(page.all('td')[6]).to have_content('0')
        end
        it 'displays the edit icon' do
          within(page.all('td')[3]) do
            element = all('span')[0]
            expect(element['class']).to match('glyphicon-pencil')
          end
        end
        describe 'clicking the edit icon' do
          before(:each) do
            @edit_list = FactoryBot.create(:list)
            visit lists_path
          end
          after(:each) { @edit_list.delete }
          it 'takes you to the edit list page' do
            within(page.all('td')[15]) do
              all('.btn')[0].click
            end
            expect(current_path).to eq(edit_list_path(@edit_list.id))
          end
        end
        it 'displays the delete icon' do
          within(page.all('td')[3]) do
            element = all('span')[1]
            expect(element['class']).to match('glyphicon-remove')
          end
        end
        describe 'on the protected lists' do
          ['Unassigned', 'Whitelist', 'Blacklist'].each do |l|
            it 'is disabled' #do
              # find the relevent button
              # expect(element['class']).to match('disabled')
            #end
          end
        end
        describe 'clicking the delete icon on the unprotected lists', :js => true do
          before(:all) do
            Capybara.current_driver = :webkit
          end
          after(:all) do
            Capybara.use_default_driver
          end
          before(:each) do
            @delete_list = FactoryBot.create(:list)
            visit lists_path
            find("[data-id=\"#{@delete_list.id}\"]").click
          end
          it 'displays the delete modal with "Delete List <listname>?"' do
            expect(page).to have_content("Delete List '#{@delete_list.name}'?")
          end
          it 'displays "Any devices in the list will be moved to Unassigned."' do
            expect(page).to have_content("Any devices in the list will be moved to Unassigned.")
          end
          it 'deletes the list after confirmation' do
            click_link('Delete')
            visit lists_path # reload page because flash message has list name
            expect(page).not_to have_content(@delete_list.name)
          end
          it 'reassigns devices to unassigned' do
            @unassigned_count_b4 = Device.where(list: List.find_by_name('Unassigned')).count
            FactoryBot.create(:device, list: @delete_list)
            click_link('Delete')
            visit lists_path
            expect(Device.where(list: List.find_by_name('Unassigned')).count).to eq(@unassigned_count_b4+1)
          end
          it 'displays success message' do
            click_link('Delete')
            expect(page).to have_content("Deleted list named '#{@delete_list.name}'.")
          end
          it 'does not delete the list if cancelled' do
            click_button('Cancel')
            visit lists_path
            expect(page).to have_content(@delete_list.name)
          end
        end
      end
    end
    describe 'has pagination controls when table has more than 10 rows' do
      before(:each) do
        FactoryBot.create_list(:list, 11)
        visit lists_path
      end
      it do
        expect(page).to have_selector('div.pagination')
      end
    end
    describe 'clicking the Add button' do
      it 'takes you to the new list page' do
        click_link('Add')
        expect(current_path).to eq(new_list_path)
      end
    end
    describe 'sort list' do
      describe 'by name'
    end
  end
end
