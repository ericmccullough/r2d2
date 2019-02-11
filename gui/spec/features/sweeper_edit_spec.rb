require 'rails_helper'

RSpec.describe 'sweeper', type: :feature do
  describe 'edit page' do
  end
  before(:each) do
    @pref = FactoryBot.create(:pref)
    @sweeper = FactoryBot.create(:sweeper)
    visit edit_sweeper_path(@sweeper)
  end
  it 'has the edit url' do
    expect(current_path).to eq(edit_sweeper_path(@sweeper))
  end
  it 'displays the current MAC' do
    expect(find_field('sweeper_mac').value).to eq(@sweeper.mac)
  end
  it 'displays the current IP' do
    expect(find_field('sweeper_ip').value).to eq(@sweeper.ip)
  end
  it 'displays the current description' do
    expect(find_field('sweeper_description').value).to eq(@sweeper.description)
  end
  it 'can change the MAC' do
    old_mac = @sweeper.mac
    new_mac = '111111111111'
    fill_in 'Mac', with: new_mac
    separator = @pref.mac_separator
    new_mac.insert(10, separator).insert(8, separator).insert(6, separator).insert(4, separator).insert(2, separator)
    click_button 'Save'
    expect(page.all('td')[2]).to have_content(new_mac)
    expect(page).not_to have_content(old_mac)
  end
  it 'can change the IP'do
    old_ip = @sweeper.ip
    fill_in 'Ip', with: '255.255.255.1'
    click_button 'Save'
    expect(page.all('td')[1]).to have_content('255.255.255.1')
    expect(page).not_to have_content(old_ip)
  end
  it 'can change the description' do
    old_description = @sweeper.description
    fill_in 'Description', with: 'CitySweeper'
    click_button 'Save'
    expect(page.all('td')[0]).to have_content('CitySweeper')
    expect(page).not_to have_content(old_description)
  end
  it 'does not create a new sweeper' do
    sweeper_count_b4 = Sweeper.count
    fill_in 'Description', with: 'freed'
    click_button 'Save'
    expect(Sweeper.count).to eq(sweeper_count_b4)
    expect(Sweeper.find_by_description('freed').valid?).to eq(true)
  end
  it 'after save, redirects to the sweepers page' do
    click_button 'Save'
    expect(current_path).to eq(sweepers_path)
  end
  it 'displays a success message' do
    fill_in 'Mac', with: '11:11:11:11:11:11'
    click_button 'Save'
    expect(page).to have_content("Sweeper updated.")
  end
  describe 'clicking cancel' do
    it 'does not change the sweeper' do
      separator = @pref.mac_separator
      @sweeper.mac.insert(10, separator).insert(8, separator).insert(6, separator).insert(4, separator).insert(2, separator)
      fill_in 'Description', with: 'fred'
      fill_in 'Mac', with: '11:11:11:11:11:11'
      fill_in 'Ip', with: '255.255.255.1'
      click_link 'Cancel'
      expect(page.all('td')[0]).to have_content(@sweeper.description)
      expect(page).not_to have_content('fred')
      expect(page.all('td')[1]).to have_content(@sweeper.ip)
      expect(page).not_to have_content('255.255.255.1')
      expect(page.all('td')[2]).to have_content(@sweeper.mac)
      expect(page).not_to have_content('111111111111')
    end
    it 'redirects to the sweepers page' do
      click_link 'Cancel'
      expect(current_path).to eq(sweepers_path)
    end
  end
end
  
