require 'rails_helper'

RSpec.describe 'list', type: :feature do
  describe 'edit page' do
    before(:each) do
      @list = FactoryBot.create(:list)
      visit edit_list_path(@list)
    end
    it 'has the edit url' do
      expect(current_path).to eq(edit_list_path(@list))
    end
    it 'displays the current name' do
      expect(find_field('list_name').value).to eq(@list.name)
    end
    it 'displays the current glyph' do
      expect(find_field('list_glyph_id').value).to eq(@list.id.to_s)
    end
    describe 'filling in field for name and clicking save' do
      it 'changes the name' do
        old_name = @list.name
        fill_in 'Name', with: 'fred'
        click_button 'Save'
        expect(page.all('td')[1]).to have_content('fred')
        expect(page).not_to have_content(old_name)
      end
      it 'does not add a new list' do
        list_count = List.count
        fill_in 'Name', with: 'freed'
        click_button 'Save'
        expect(List.count).to eq(list_count)
        expect(List.find_by_name('freed').valid?).to eq(true)
      end
      it 'displays success message' do
        fill_in 'Name', with: "Fred's Angels"
        click_button 'Save'
        expect(page).to have_content("List updated")
      end
      describe 'cannot add' do
        before(:each) { @list2 = FactoryBot.create(:list) }
        it 'blank name' do
          fill_in 'Name', with: ''
          click_button 'Save'
          expect(page).to have_content("Name can't be blank")
        end
        it 'duplicate name' do
          fill_in 'Name', with: @list2.name
          click_button 'Save'
          expect(page).to have_content("Name has already been taken")
        end
        it 'case-insensitive duplicate name'
      end
      it 'assigns the selected glyph'
      it 'redirects to the lists page' do
        click_button 'Save'
        expect(current_path).to eq(lists_path)
      end
    end
    describe 'clicking cancel' do
      it 'does not change the name' do
        fill_in 'Name', with: 'fred'
        click_link 'Cancel'
        expect(page.all('td')[1]).to have_content(@list.name)
        expect(page).not_to have_content('fred')
      end
      it 'does not change the glyph'
      it 'redirects to the lists page' do
        click_link 'Cancel'
        expect(current_path).to eq(lists_path)
      end
    end
  end
end
