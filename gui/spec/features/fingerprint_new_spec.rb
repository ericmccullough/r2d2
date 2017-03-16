require 'rails_helper'

RSpec.describe 'fingerprint', type: :feature do
  describe 'new page' do
    before(:each) do
      @fingerprint = FactoryGirl.create(:fingerprint)
      visit new_fingerprint_path
    end
    it 'has the new url' do
      expect(current_path).to eq(new_fingerprint_path)
    end
    describe 'filling out Name to add a fingerprint' do
      describe 'cannot add' do
        it 'blank name' do
          fingerprint_count = Fingerprint.count
          click_button 'Save'
          expect(page).to have_content("Name can't be blank")
          expect(Fingerprint.count).to eq(fingerprint_count)
        end
        it 'duplicate name' do
          fingerprint_count = Fingerprint.count
          fill_in 'Name', with: @fingerprint.name
          click_button 'Save'
          expect(page).to have_content("Name has already been taken")
          expect(Fingerprint.count).to eq(fingerprint_count)
        end
        it 'case-insensitive duplicate name' do
          fingerprint_count = Fingerprint.count
          fill_in 'Name', with: @fingerprint.name.upcase
          click_button 'Save'
          expect(page).to have_content("Name has already been taken")
          expect(Fingerprint.count).to eq(fingerprint_count)
        end
        it 'with non-numeric tcp_port' do
          fingerprint_count = Fingerprint.count
          fill_in 'Name', with: 'tcp_port_test'
          fill_in 'Tcp ports', with: 'web'
          click_button 'Save'
          expect(page).to have_content("Port must be a number 1-65535")
          expect(Fingerprint.count).to eq(fingerprint_count)
        end
        it 'with non-numeric udp_port' do
          fingerprint_count = Fingerprint.count
          fill_in 'Name', with: 'udp_port_test'
          fill_in 'Udp ports', with: 'web'
          click_button 'Save'
          expect(page).to have_content("Port must be a number 1-65535")
          expect(Fingerprint.count).to eq(fingerprint_count)
        end
        it 'with invalid share name'
      end
      describe 'adds the fingerprint to fingerprints' do
        it 'with a valid name' do
          fingerprint_count = Fingerprint.count
          fill_in 'Name', with: 'fred'
          click_button 'Save'
          expect(Fingerprint.count).to eq(fingerprint_count+1)
          expect(Fingerprint.find_by_name('fred').valid?).to eq(true)
        end
        it 'with numeric tcp_port(s)' do
          fingerprint_count = Fingerprint.count
          fill_in 'Name', with: 'tcp_port_test'
          fill_in 'Tcp ports', with: '80'
          click_button 'Save'
          expect(Fingerprint.count).to eq(fingerprint_count+1)
        end
        it 'with non-numeric udp_port(s)' do
          fingerprint_count = Fingerprint.count
          fill_in 'Name', with: 'udp_port_test'
          fill_in 'Udp ports', with: '123'
          click_button 'Save'
          expect(Fingerprint.count).to eq(fingerprint_count+1)
        end
        it 'with valid share name'
        it 'displays success message' do
          fill_in 'Name', with: "Fred's Angels"
          click_button 'Save'
          expect(page).to have_content("Added new fingerprint Fred's Angels")
        end
      end
    end
    it 'redirects to the fingerprints page' do
      fill_in 'Name', with: "Team America"
      click_button 'Save'
      expect(current_path).to eq(fingerprints_path)
    end
  end
end