require 'rails_helper'

RSpec.describe 'fingerprint', type: :feature do
  describe 'edit page' do
    before(:each) do
      @fingerprint = FactoryGirl.create(:fingerprint)
      visit edit_fingerprint_path(@fingerprint)
    end
    it 'has the edit url' do
      expect(current_path).to eq(edit_fingerprint_path(@fingerprint))
    end
    it 'displays the current name' do
      expect(find_field('fingerprint_name').value).to eq(@fingerprint.name)
    end
    it 'displays the current tcp_ports' do
      expect(find_field('fingerprint_tcp_ports').value).to eq(@fingerprint.tcp_ports)
    end
    it 'displays the current udp_ports' do
      expect(find_field('fingerprint_udp_ports').value).to eq(@fingerprint.udp_ports)
    end
    it 'displays the current shares' do
      expect(find_field('fingerprint_shares').value).to eq(@fingerprint.shares)
    end
    context 'filling in field for' do
      context 'name and clicking save' do
        it 'changes the name' do
          old_name = @fingerprint.name
          fill_in 'Name', with: 'fred'
          click_button 'Save'
          expect(page.all('td')[0]).to have_content('fred')
          expect(page).not_to have_content(old_name)
        end
        it 'does not add a new fingerprint' do
          fingerprint_count = Fingerprint.count
          fill_in 'Name', with: 'freed'
          click_button 'Save'
          expect(Fingerprint.count).to eq(fingerprint_count)
          expect(Fingerprint.find_by_name('freed').valid?).to eq(true)
        end
        it 'displays success message' do
          fill_in 'Name', with: "Fred's Angels"
          click_button 'Save'
          expect(page).to have_content("Fingerprint updated")
        end
        describe 'cannot add' do
          before(:each) { @fingerprint2 = FactoryGirl.create(:fingerprint) }
          it 'blank name' do
            fill_in 'Name', with: ''
            click_button 'Save'
            expect(page).to have_content("Name can't be blank")
          end
          it 'duplicate name' do
            fill_in 'Name', with: @fingerprint2.name
            click_button 'Save'
            expect(page).to have_content("Name has already been taken")
          end
          it 'case-insensitive duplicate name' do
            fill_in 'Name', with: @fingerprint2.name.upcase
            click_button 'Save'
            expect(page).to have_content("Name has already been taken")
          end
        end
      end
      context 'tcp_ports and clicking save' do
        it 'changes the tcp_ports' do
          old_tcp_ports = @fingerprint.tcp_ports
          fill_in 'Tcp ports', with: '12345'
          click_button 'Save'
          expect(page.all('td')[1]).to have_content('12345')
          expect(page).not_to have_content(old_tcp_ports)
        end
        it 'does not add a new fingerprint' do
          fingerprint_count = Fingerprint.count
          fill_in 'Tcp ports', with: '12345'
          click_button 'Save'
          expect(Fingerprint.count).to eq(fingerprint_count)
        end
        it 'displays success message' do
          fill_in 'Tcp ports', with: "12345"
          click_button 'Save'
          expect(page).to have_content("Fingerprint updated")
        end        
      end
      it 'redirects to the fingerprints page' do
        click_button 'Save'
        expect(current_path).to eq(fingerprints_path)
      end
    end
    describe 'clicking cancel' do
      it 'does not change the name' do
        fill_in 'Name', with: 'fred'
        click_link 'Cancel'
        expect(page.all('td')[0]).to have_content(@fingerprint.name)
        expect(page).not_to have_content('fred')
      end
      it 'does not change the tcp_ports' do
        fill_in 'Tcp ports', with: '12345'
        click_link 'Cancel'
        expect(page.all('td')[1]).to have_content(@fingerprint.tcp_ports)
        expect(page).not_to have_content('12345')
      end
      it 'does not change the udp_ports' do
        fill_in 'Udp ports', with: '54321'
        click_link 'Cancel'
        expect(page.all('td')[2]).to have_content(@fingerprint.udp_ports)
        expect(page).not_to have_content('54321')
      end
      it 'does not change the shares' do
        fill_in 'Name', with: 'freds_share'
        click_link 'Cancel'
        expect(page.all('td')[3]).to have_content(@fingerprint.shares)
        expect(page).not_to have_content('freds_share')
      end
      it 'redirects to the fingerprints page' do
        click_link 'Cancel'
        expect(current_path).to eq(fingerprints_path)
      end
    end
  end
end