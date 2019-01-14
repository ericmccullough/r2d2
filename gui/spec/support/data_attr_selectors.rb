Capybara.add_selector(:data_id) do
  css { |num| "*[data-id='#{num}']" }
end
