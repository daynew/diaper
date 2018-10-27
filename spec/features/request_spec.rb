RSpec.feature "Requests", type: :feature do
  before do
    sign_in(@user)
    @request = create(:request, organization: @organization)
    @storage_location = create(:storage_location, organization: @organization)
    # creates an inventory item for the request's first item and gives it a quantity of 234
    @storage_location.inventory_items.create!(
      quantity: 234,
      item: Item.find_by(
        canonical_item: CanonicalItem.find_by(
          partner_key: @request.request_items.keys.first
        )
      )
    )
  end
  let!(:url_prefix) { "/#{@organization.to_param}" }

  context "While viewing the requests index page" do
    before(:each) do
      visit url_prefix + "/requests"
    end

    scenario "the requests are listed" do
      expect(page).to have_xpath("//h1", text: "Requests")
    end
  end

  context "While viewing the request page" do
    scenario "the request is shown", js: true do
      visit url_prefix + "/requests/#{@request.id}"
      expect(page).to have_content("Request from #{@request.partner.name}")
      expect(page).to have_content("Estimated on-hand")
      expect(page).to have_content("234")
    end

    scenario "the request is fullfillable", js: true do
      visit url_prefix + "/requests/#{@request.id}"
      click_on "Fulfill request"
      expect(page).to have_content "fulfilled"
      select @storage_location.name, from: "From storage location"
      fill_in "Comment", with: "Take my wipes... please"
      click_on "Save"
      expect(page).to have_content "Distributions"
      expect(page).to have_content "Distribution created"
      expect(@request.reload.distribution_id).to eq Distribution.last.id
    end
  end
end
