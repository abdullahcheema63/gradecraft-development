describe GroupsController do
  let(:course) { build(:course) }
  let(:assignment) { create(:assignment, course: course) }
  let(:professor) { create(:user, courses: [course], role: :professor) }
  let(:student) { create(:course_membership, :student, course: course).user }
  let(:student_2) { create(:course_membership, :student, course: course).user }
  let(:student_3) { create(:course_membership, :student, course: course).user }
  let(:group) { create(:group, course: course) }

  context "as professor" do
    before(:each) { login_user(professor) }

    describe "GET index" do
      it "returns groups for the current course" do
        get :index
        expect(assigns(:pending_groups)).to eq([group])
        expect(response).to render_template(:index)
      end
    end

    describe "GET show" do
      it "displays the specified group" do
        get :show, params: { id: group.id }
        expect(assigns(:group)).to eq(group)
        expect(response).to render_template(:show)
      end
    end

    describe "GET new" do
      it "renders the new group form" do
        get :new
        expect(assigns(:group)).to be_a_new(Group)
        expect(response).to render_template(:new)
      end
    end

    describe "GET edit" do
      it "renders the edit group form" do
        get :edit, params: { id: group.id }
        expect(assigns(:group)).to eq(group)
        expect(response).to render_template(:edit)
      end
    end

    describe "POST create" do
      it "creates the group with valid attributes" do
        params = {"name"=>"Test Name", "assignment_ids"=>["#{assignment.id}"],
          "student_ids"=>["#{student.id}", "#{student_2.id}", "#{student_3.id}"] }
        expect{ post :create, params: { group: params }}.to change(Group, :count).by(1)
        expect(response).to redirect_to(Group.last)
      end

      it "redirects to new from with invalid attributes" do
        expect{ post :create, params: { group: attributes_for(:group, name: nil) }}
          .to_not change(Group,:count)
      end
    end

    describe "POST update" do
      it "updates the group" do
        params = { name: "new name" }
        post :update, params: { id: group.id, group: params }
        expect(response).to redirect_to(group_path(group))
        expect(group.reload.name).to eq("new name")
      end

      it "redirects to edit with invalid attributes" do
        post :update, params: { id: group.id, group: attributes_for(:group, name: nil) }
        expect(response).to render_template(:edit)
      end
    end

    describe "GET destroy" do
      it "destroys the group" do
        group
        expect{ get :destroy, params: { id: group }}.to change(Group,:count).by(-1)
      end
    end
  end

  context "as student" do
    before do
      login_user(student)
    end

    describe "GET new" do
      it "renders the new group form" do
        get :new
        assigns(id: student.id)
        expect(assigns(:group)).to be_a_new(Group)
        expect(response).to render_template(:new)
      end
    end

    describe "POST create" do
      it "creates the group with valid attributes"  do
        params = {"name"=>"Test Name", "assignment_ids"=>["#{assignment.id}"],
          "student_ids"=>["#{student_2.id}", "#{student_3.id}"] }
        expect{ post :create, params: { group: params }}.to change(Group, :count).by(1)
        expect(student.group_for_assignment(assignment).present?).to eq(true)
        expect(response).to redirect_to(Group.last)
      end

      it "redirects to new from with invalid attributes" do
        expect{ post :create, params: { group: attributes_for(:group, name: nil) }}
          .to_not change(Group,:count)
      end
    end

    describe "GET edit" do
      it "renders the edit group form" do
        get :edit, params: { id: group.id }
        expect(assigns(:group)).to eq(group)
        expect(response).to render_template(:edit)
      end
    end

    describe "POST update" do
      it "updates the group" do
        params = { name: "new name" }
        post :update, params: { id: group.id, group: params }
        group.reload
        expect(response).to redirect_to(group_path(group))
        expect(group.name).to eq("new name")
      end
    end

    describe "GET show" do
      it "displays the specified group" do
        get :show, params: { id: group.id }
        expect(assigns(:group)).to eq(group)
        expect(response).to render_template(:show)
      end
    end

    describe "protected routes" do
      [
        :index
      ].each do |route|
          it "#{route} redirects to root" do
            assigns(id: student.id)
            expect(get route).to redirect_to(:root)
          end
        end
    end

    describe "protected routes requiring id in params" do
      [
        :destroy
      ].each do |route|
        it "#{route} redirects to root" do
          expect(get route, params: { id: "1" }).to redirect_to(:root)
        end
      end
    end
  end
end
