require "rails_spec_helper"

describe ChallengeGradesController do

  let(:world) { World.create.with(:course, :student) }
  let(:professor) { create(:professor_course_membership, course: world.course).user }
  let(:team) { world.create_team.team }
  let(:challenge) { world.create_challenge.challenge }

  context "as professor" do
    before(:each) do
      @challenge_grade = create(:challenge_grade, team: team, challenge: challenge)
      login_user(professor)
    end

    describe "GET new" do
      it "shows the new challenge grade form" do
        get :new, {challenge_id: challenge, team_id: team}
        expect(assigns(:challenge)).to eq(challenge)
        expect(assigns(:team)).to eq(team)
        expect(response).to render_template(:new)
      end
    end

    describe "POST create" do
      it "creates the challenge grade with valid attributes and redirects to the challenge show page" do
        team2 = create(:team, course: world.course )
        params = attributes_for(:challenge_grade)
        params[:score] = "101"
        params[:challenge_id] = challenge.id
        params[:team_id] = team2.id
        params[:status] = "Released"
        post :create, challenge_grade: params
        expect(challenge.challenge_grades.where(:team_id => team2.id).first.score).to eq(101)
        expect(response).to redirect_to(challenge)
      end

      it "redirects to new form with invalid attributes" do
        expect{ post :create, challenge_id: challenge.id, challenge_grade: attributes_for(:challenge_grade, team_id: nil) }.to_not change(ChallengeGrade,:count)
      end
    end

    describe "GET show" do
      it "shows the challenge grade" do
        get :show, {id: @challenge_grade, challenge_id: challenge}
        expect(assigns(:challenge)).to eq(challenge)
        expect(assigns(:challenge_grade)).to eq(@challenge_grade)
        expect(assigns(:team)).to eq(team)
        expect(response).to render_template(:show)
      end
    end

    describe "GET edit" do
      it "shows the edit challenge grade form" do
        get :edit, {id: @challenge_grade, challenge_id: challenge, team_id: team.id }
        expect(assigns(:challenge)).to eq(challenge)
        expect(assigns(:challenge_grade)).to eq(@challenge_grade)
        expect(assigns(:team)).to eq(team)
        expect(response).to render_template(:edit)
      end
    end

    describe "POST update" do
      it "updates the challenge grade" do
        params = attributes_for(:challenge_grade)
        params[:score] = "100000"
        params[:challenge_id] = challenge.id
        params[:team_id] = team.id
        params[:status] = "Released"
        post :update, id: @challenge_grade.id, challenge_grade: params
        expect(response).to redirect_to(challenge_path(challenge))
        expect(@challenge_grade.reload.score).to eq(100000)
        expect(team.reload.challenge_grade_score).to eq(100000)
      end

      it "redirects to edit form with invalid attributes" do
        params = { team_id: nil }
        post :update, challenge_id: challenge.id, id: @challenge_grade.id, challenge_grade: params
        expect(response).to render_template(:edit)
      end
    end

    describe "GET destroy" do
      it "destroys the challenge grade" do
        expect{ get :destroy, {id: @challenge_grade, challenge_id: challenge.id } }.to change(ChallengeGrade,:count).by(-1)
      end

      it "recalculates the team score" do
        challenge = create(:challenge, course: world.course)
        @challenge_grade = create(:challenge_grade, challenge: challenge, team: team, score: 100, status: "Released")
        expect(team.challenge_grade_score).to eq(100)
        post :destroy, {id: @challenge_grade, challenge_id: challenge.id}
        expect(team.reload.challenge_grade_score).to eq(0)
        expect(response).to redirect_to(challenge_path(challenge))
      end
    end
  end

  context "as student" do
    before(:each) do
      @challenge_grade = create(:challenge_grade, team: team, challenge: challenge)
      login_user(world.student)
    end

    describe "GET show" do
      it "shows the challenge grade" do
        get :show, {id: @challenge_grade, challenge_id: challenge}
        expect(assigns(:challenge)).to eq(challenge)
        expect(assigns(:challenge_grade)).to eq(@challenge_grade)
        expect(assigns(:team)).to eq(team)
        expect(response).to render_template(:show)
      end
    end

    describe "protected routes" do
      [
        :new,
        :create
      ].each do |route|
          it "#{route} redirects to root" do
            expect(get route, {challenge_id: 2 }).to redirect_to(:root)
          end
        end
    end

    describe "protected routes requiring id in params" do
      [
        :edit,
        :update,
        :destroy
      ].each do |route|
        it "#{route} redirects to root" do
          expect(get route, {challenge_id: 2, id: "1"}).to redirect_to(:root)
        end
      end
    end
  end
end
