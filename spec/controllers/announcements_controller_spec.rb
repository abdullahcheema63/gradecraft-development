require 'spec_helper'

describe AnnouncementsController do
  let(:course) { create :course }
  let(:professor) { create :user }

  before(:each) do
    professor.course_memberships << \
      CourseMembership.new(course_id: course.id, role: "professor")
    login_user(professor)
    session[:course_id] = course.id
  end

  describe "GET #index" do
    let!(:announcement) { create :announcement, course_id: course.id }
    let!(:non_course_announcement) { create :announcement }

    it "lists the announcements that are available for that course" do
      get :index
      expect(assigns(:announcements)).to eq [announcement]
    end
  end

  describe "POST #create" do
    context "with a successful announcement" do
      let(:body) { Faker::Lorem.sentence(3) }

      it "creates a new announcement" do
        post :create, announcement: { title: "New Tour", body: body }
        announcement = Announcement.unscoped.last
        expect(announcement.title).to eq "New Tour"
        expect(announcement.body).to eq body
        expect(announcement.course).to eq course
        expect(announcement.author).to eq professor
      end

      it "redirects back to the announcements page" do
        post :create, announcement: { title: "New Tour", body: body }
        expect(response).to redirect_to announcements_path
      end

      it "sends out the announcement to all the students in the course" do
        student = create :user
        CourseMembership.create! course_id: course.id,
          user_id: student.id, role: "student"
        expect {
          post :create, announcement: { title: "New Tour", body: body }
        }.to change  { ActionMailer::Base.deliveries.count }.by 1
      end
    end

    context "with an invalid announcement" do
      it "renders view with the errors" do
        post :create, announcement: { title: "", body: body }
        expect(response).to render_template :new
      end
    end
  end
end
