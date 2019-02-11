require 'rails_helper'

RSpec.describe 'sweeper', type: :feature do
  describe 'new page' do
    before(:each) do
      @pref = FactoryBot.create(:pref)
      visit new_sweeper_path
    end
    it 'has the new url' do
      expect(current_path).to eq(new_sweeper_path)
    end
    describe 'filling out form to add a sweeper' do
      describe 'cannot add with' do
        it 'blank MAC' do
          click_button 'Save'
          expect(page).to have_content("Mac can't be blank")
        end
        it 'duplicate MAC' do
          sweep = FactoryBot.create(:sweeper, mac: '11:22:33:44:55:66')
          fill_in 'sweeper_mac', with: sweep.mac
          click_button 'Save'
          expect(page).to have_content("Mac has already been taken")
        end
        it 'Invalid IP' do
          fill_in 'sweeper_ip', with: '1.1.1'
          click_button 'Save'
          expect(page).to have_content("Ip is invalid")
        end
      end
      describe 'adds it to the sweepers' do
        before(:each) do
          visit new_sweeper_path
          @mac = '112233445566'
          fill_in 'sweeper_mac', with: @mac
          fill_in 'sweeper_description', with: '1.1.1.0/24'
          fill_in 'sweeper_ip', with: '1.1.1.1'
        end
        it 'increases the sweeper count by one' do
          sweeper_count = Sweeper.count
          click_button 'Save'
          expect(Sweeper.count).to eq(sweeper_count+1)
        end
        it 'displays success message' do
          separator = @pref.mac_separator
          @mac.insert(10, separator).insert(8, separator).insert(6, separator).insert(4, separator).insert(2, separator)
          click_button 'Save'
          expect(page).to have_content("Added new sweeper #{@mac}")
        end
        it 'saves the MAC' do
          click_button 'Save'
          expect(Sweeper.find_by_mac('112233445566').valid?).to eq(true)
        end
        it 'saves the IP' do
          click_button 'Save'
          expect(Sweeper.find_by_ip('1.1.1.1').valid?).to eq(true)
        end
        it 'saves the description' do
          click_button 'Save'
          expect(Sweeper.find_by_description('1.1.1.0/24').valid?).to eq(true)
        end
        it 'redirects to the sweepers page' do
          click_button 'Save'
          expect(current_path).to eq(sweepers_path)
        end
      end
      describe 'clicking cancel' do
        it 'does not create a new sweeper' do
          sweeper_count_b4 = Sweeper.count
          fill_in 'Description', with: 'freed'
          click_link 'Cancel'
          expect(Sweeper.count).to eq(sweeper_count_b4)
        end
      end
    end
  end
end
