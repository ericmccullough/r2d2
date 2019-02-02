require 'rails_helper'

RSpec.describe 'prefs', type: :feature do
  describe 'GET /pref' do
    before(:each) do
      @pref = FactoryBot.create(:pref)
      visit 'prefs/0'
    end
    it 'has the program name as the title' do
      expect(page).to have_title('Remote Rogue Device Detector')
    end
    it 'has a link r2d2 to root' do
      expect(page).to have_link('Remote Rogue Device Detector', :href => '/r2d2')
    end
    it 'has Home as the page description in the navbar' do
      expect(page.all('.navbar')[0]).to have_content('Prefs')
    end
    
    describe 'has a form' do
      describe 'with a MAC Separator dropdown' do
        it 'that has the current values selected' do
          expect(find('#pref_mac_separator').value).to eq(@pref.mac_separator)
        end
        it 'that has all the mac_separators as options' do
          @pref.mac_separators.split('').each { |s|
            expect(find('#pref_mac_separator')).to have_content(s)
          }
        end
        describe 'and when you select a value and' do
          describe 'click save' do
            it 'the mac_separator changes' do
              select('.', from: 'pref_mac_separator')
              click_button('Save')
              visit 'prefs/0'
              expect(find('#pref_mac_separator > option[selected]').value).to eq('.')
            end
            it 'displays a success message' do
              select('.', from: 'pref_mac_separator')
              click_button('Save')
              expect(page).to have_content("Preference updated")
            end
            it 'redirects to the root path' do
              select('.', from: 'pref_mac_separator')
              click_button('Save')
              expect(current_path).to eq(root_path)
            end
          end
          describe 'click cancel' do
            it 'does not change the mac_separator' do
              select('.', from: 'pref_mac_separator')
              click_link('Cancel')
              visit 'prefs/0'
              expect(find('#pref_mac_separator > option[selected]').value).to eq(':')
            end
            it 'redirects to the root path' do
              select('.', from: 'pref_mac_separator')
              click_link('Cancel')
              expect(current_path).to eq(root_path)
            end
          end
        end
      end
      describe 'with MAC case radio buttons' do
        it 'that displays the current setting' do
          expect(find('#pref_mac_uppercase_true')).to be_checked 
        end
        it 'that if changed and saved' do
          choose('pref_mac_uppercase_false')
          click_button('Save')
          visit 'prefs/0'
          expect(find('#pref_mac_uppercase_false')).to be_checked
        end
      end
    end
  end
end
