require 'rails_helper'

RSpec.describe 'list', type: :feature do
  describe 'new page' do
    before(:each) do
      FactoryBot.create(:glyph, name: 'glyphicon-warning-sign')
      FactoryBot.create(:glyph, name: 'glyphicon-star')
      @list = FactoryBot.create(:list)
      visit new_list_path
    end
    it 'has the new url' do
      expect(current_path).to eq(new_list_path)
    end
    describe 'filling out Name to add a list' do
      describe 'cannot add' do
        it 'blank name' do
          click_button 'Save'
          expect(page).to have_content("Name can't be blank")
          #expect(current_path).to eq(new_list_path)
        end
        it 'duplicate name' do
          fill_in 'Name', with: @list.name
          click_button 'Save'
          expect(page).to have_content("Name has already been taken")
          #expect(current_path).to eq(new_list_path)
        end
        it 'case-insensitive duplicate name' do
          fill_in 'Name', with: @list.name.upcase
          click_button 'Save'
          expect(page).to have_content("Name has already been taken")
          #expect(current_path).to eq(new_list_path)
        end
      end
      it 'adds the list to lists' do
        list_count = List.count
        fill_in 'Name', with: 'fred'
        click_button 'Save'
        expect(List.count).to eq(list_count+1)
        expect(List.find_by_name('fred').valid?).to eq(true)
      end
      it 'displays success message' do
        fill_in 'Name', with: "Fred's Angels"
        click_button 'Save'
        expect(page).to have_content("Added new list Fred's Angels")
      end
      it 'has a count of zero' do
        fill_in 'Name', with: "A-Team"
        click_button 'Save'
        expect(page.all('td')[2]).to have_content('0')
      end
    end
    describe 'glyph' do
      before(:each) { fill_in 'Name', with: "Avengers" }
      it 'assigns the default glyph if not changed' do
        click_button 'Save'
        expect(List.find_by_name('Avengers').glyph.name).to eq('glyphicon-warning-sign')
      end
      it 'assigns the selected glyph' do
        select('glyphicon-star', :from => 'list_glyph_id')
        click_button 'Save'
        expect(List.find_by_name('Avengers').glyph.name).to eq('glyphicon-star')
      end
    end
    it 'redirects to the lists page' do
      fill_in 'Name', with: "Team America"
      click_button 'Save'
      expect(current_path).to eq(lists_path)
    end
  end
end
