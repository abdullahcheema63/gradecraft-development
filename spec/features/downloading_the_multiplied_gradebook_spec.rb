feature "downloading multiplied gradebook file" do
  context "as a professor" do
    let(:course) { build :course, name: "Course Name", has_multipliers: true, total_weights: 1, max_weights_per_assignment_type: 2, max_assignment_types_weighted: 2, weight_term: "Multiplier", full_points: 1 }
    let!(:course_membership) { create :course_membership, :professor, user: professor, course: course }
    let(:professor) { create :user }

    before(:each) do
      login_as professor
      visit downloads_path
    end

    scenario "successfully" do
      within(".pageContent") do
        click_link "Multiplier Gradebook"
      end

      expect(page).to have_notification_message("notice", "Your request to export the multiplied gradebook for \"Course Name\" is currently being processed. We will email you the data shortly.")

    end
  end
end
