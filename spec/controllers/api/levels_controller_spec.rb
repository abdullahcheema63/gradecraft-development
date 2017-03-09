require "rails_spec_helper"

describe API::LevelsController do
  let(:course) { build :course }
  let(:student)  { create(:course_membership, :student, course: course).user }
  let(:professor) { create(:course_membership, :professor, course: course).user }
  let(:assignment) { create(:assignment, course: course) }
  let(:rubric) { create(:rubric, assignment: assignment) }
  let(:criterion) { create(:criterion, rubric: rubric) }

  context "as professor" do
    before(:each) { login_user(professor) }

    describe "PUT update" do
      let(:level) { criterion.levels.last }
      let(:params) do
        { id: level.id, level: { description: "You have reached a new level", meets_expectations: true }}
      end

      it "updates the level attributes" do
        put :update, params: params, format: :json
        expect(level.reload.meets_expectations).to be_truthy
        expect(level.description).to eq("You have reached a new level")
      end

      it "insures only one level per criterion meets expectations" do
        l_1 = criterion.levels.first
        l_1.update_attributes(meets_expectations: true)
        put :update, params: params, format: :json
        expect(l_1.reload.meets_expectations).to be_falsey
      end

      it "renders success message when request format is JSON" do
        put :update, params: params
        expect(response.status).to eq(200)
        expect(JSON.parse(response.body)).to eq("message" => "level successfully updated", "success" => true)
      end

      describe "on error" do
        it "describes failure to update" do
          allow_any_instance_of(Level).to receive(:update_attributes) { false }
          put :update, params: params
          expect(JSON.parse(response.body)).to eq("errors"=>[{"detail"=>"failed to update level"}], "success"=>false)
          expect(response.status).to eq(500)
        end
      end
    end
  end

  context "as student" do
    before(:each) { login_user(student) }

    it "redirects protected routes to root" do
      [
        -> { put :update, params: { id: 144 }, format: :json}
      ].each do |protected_route|
        expect(protected_route.call).to redirect_to(:root)
      end
    end
  end
end
