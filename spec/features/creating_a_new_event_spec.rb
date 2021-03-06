feature "creating a new event" do
  context "as a professor" do
    let!(:institution) { create :institution }
    let(:course) { build :course, institution: institution }
    let!(:course_membership) { create :course_membership, :professor, user: professor, course: course }
    let(:professor) { create :user }

    before(:each) do
      login_as professor
      visit events_path
    end

    scenario "successfully" do
      within(".context-menu") do
        click_link "New Event"
      end

      expect(current_path).to eq new_event_path

      within(".pageContent") do
        fill_in "Name", with: "New Event"
        click_button "Create Event"
      end

      expect(page).to have_notification_message("notice", "Event New Event was successfully created")
    end
  end
end
