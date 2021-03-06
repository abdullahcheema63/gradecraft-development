describe "api/grades/group_index" do
  let(:course) { build(:course) }
  let(:assignment) { create(:assignment, course: course) }
  let(:student) { create(:course_membership, :student, course: course).user }
  let(:grade) { create(:grade, assignment: assignment, student: student) }

  before(:all) do
    # Expected instance variables on render:
    @grades = [create(:grade)]
    @student_ids = [1,2,3,4,5]
    @assignment = @grades[0].assignment
  end

  it "responds with an array of grades" do
    render
    json = JSON.parse(response.body)
    expect(json["data"][0]["type"]).to eq("grades")
  end

  it "adds the attributes to the grade" do
    render
    json = JSON.parse(response.body)
    expect(json["data"][0]["attributes"]["id"]).to eq(@grades[0].id)
    expect(json["data"][0]["attributes"]["assignment_id"]).to eq(@grades[0].assignment_id)
    expect(json["data"][0]["attributes"]["student_id"]).to eq(@grades[0].student_id)
    expect(json["data"][0]["attributes"]["feedback"]).to eq(@grades[0].feedback)
    expect(json["data"][0]["attributes"]["status"]).to eq(@grades[0].status)
    expect(json["data"][0]["attributes"]["adjustment_points"]).to eq(@grades[0].adjustment_points)
    expect(json["data"][0]["attributes"]["adjustment_points_feedback"]).to eq(@grades[0].adjustment_points_feedback)
  end
end
