require 'rails_helper'

RSpec.describe "l2s2", type: :feature do
  describe "GET /l2s2" do
    describe 'Top Level page' do
      before(:each) do
        visit '/l2s2'
      end
      it 'should have the program name' do
        expect(page).to have_title('Layer 2 Sweeper Service')
      end
      it 'should have link l2s2 to root' do
        expect(page).to have_link('Layer 2 Sweeper Service', :href => '/l2s2')
      end
      it 'should have Top Level as the page description in the navbar' do
        expect(page.all('.navbar')[0]).to have_content('Top Level')
      end
      it 'should have link to r2d2' do
        expect(page).to have_link('r2d2', href:  '/r2d2')
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
          it 'has a Description column' do
            expect(page.all('th')[0]).to have_content('Sweeper Description')
          end
          it 'has an IP address column' do
            expect(page.all('th')[1]).to have_content('IP')
          end
          it 'has a MAC address column' do
            expect(page.all('th')[2]).to have_content('MAC')
          end
          it 'has an Action column' do
            expect(page.all('th')[3]).to have_content('Action')
          end
        end
        describe 'data row' do
          let!(:sweeper) { FactoryBot.create(:sweeper) }
          before(:each) do
            @pref = FactoryBot.create(:pref)
            separator = @pref.mac_separator
            @mac = sweeper.mac.dup
            @mac.insert(10, separator).insert(8, separator).insert(6, separator).insert(4, separator).insert(2, separator)
            visit "/sweepers"
          end
          it 'has a link to display the sweeper details' do
            expect(page.find_link(sweeper.description, href: "/sweepers/#{sweeper.id}"))
          end
          it 'displays the sweeper description' do
            expect(page.all('td')[0]).to have_content(sweeper.description)
          end
          it 'displays the sweeper IP address' do
            expect(page.all('td')[1]).to have_content(sweeper.ip)
          end
          describe 'displays the sweeper MAC address' do
            it 'with separators' do
              expect(page.all('td')[2].text).to match(%r{#{@mac}}i)
            end
            it 'with prefered case' #do
#              expect(page.all('td')[0].text).to match(%r{#{@lcMAC}})
#            end
            #expect(page.all('td')[2]).to have_content(sweeper.mac)
          end
          describe 'the action field' do
            it 'displays the edit icon' do
              within(page.all('td')[3]) do
                element = all('span')[0]
                expect(element['class']).to match('glyphicon-pencil')
              end
            end
            it 'clicking the edit icon takes you to the edit page' do
              within(page.all('td')[3]) do
                all('.btn')[0].click
              end
              expect(current_path).to eq(edit_sweeper_path(sweeper.id))
            end
            it 'displays the delete icon' do
              within(page.all('td')[3]) do
                element = all('span')[1]
                expect(element['class']).to match('glyphicon-remove')
              end
            end
            describe 'clicking the delete icon', :js => true do
              before(:each) do
                @delete_sweeper = FactoryBot.create(:sweeper)
                visit sweepers_path
                find("button[data-id=\"#{@delete_sweeper.id}\"]").click
              end
              it 'displays the delete modal with "Delete Sweeper <sweeper>?"' do
                expect(page).to have_content("Delete Sweeper '#{@delete_sweeper.description}'?")
              end
              it 'displays a warning' do
                expect(page).to have_content("This cannot be undone and will also delete the related sweeps.")
              end
              it 'deletes the list after confirmation' do
                click_link('Delete')
                expect(page).not_to have_content(@delete_sweeper.mac)
              end
              describe 'deletes the related sweeps' do
                before(:each) do
                  @sweep = FactoryBot.create(:sweep)
                  @sweep.nodes << Node.create(ip: @delete_sweeper.ip, mac: @delete_sweeper.mac)
                end
                it '(need to use the results link table somehow)' do
                  #@count_b4 = Sweep.includes(:nodes).where(nodes:{mac:@delete_sweeper.mac}).count
                  #click_link('Delete')
                  #expect(Sweep.includes(:nodes).where(nodes:{mac:@delete_sweeper.mac}).count).to eq(@count_b4-1)
                end
              end
              it 'displays success message' do
                click_link('Delete')
                expect(page).to have_content("Deleted sweeper with description '#{@delete_sweeper.description}'.")
              end
              it 'does not delete the sweeper if cancelled' do
                click_button('Cancel')
                visit sweepers_path
                expect(page).to have_content(@mac)
              end
            end
          end
        end
        describe 'should be sortable' do
          it 'by description'
          it 'by IP'
          it 'by MAC'
        end
      end
      describe 'big table' do
        before(:each) do
          @pref = FactoryBot.create(:pref)
          11.times { FactoryBot.create(:sweeper) }
          visit "/sweepers"
        end
        it 'should paginate if more than 10 rows' do
          expect(page).to have_selector('div.pagination')
        end
      end
      describe 'clicking a sweeper description' do
        let!(:sweeper) { FactoryBot.create(:sweeper) }
        before(:each) do
          @pref = FactoryBot.create(:pref)
          visit '/sweepers'
          click_link(sweeper.description)
        end
        it 'should go to /sweeps/:id' do
          expect(current_path).to eq("/sweepers/#{sweeper.id}")
        end
      end
      describe 'clicking the Add button' do
        it 'takes you to the new sweeper page' do
          click_link('Add')
          expect(current_path).to eq(new_sweeper_path)
        end
      end
    end
  end
end
