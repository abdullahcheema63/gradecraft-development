describe Presenters::Downloads::Base do
  subject do
    described_class.new \
      current_course: course,
      current_user: user
  end

  let(:course) { export.course }
  let(:export) { create :submissions_export }
  let(:user) { export.professor }

  describe "#submissions_exports" do
    it "gets the ordered exports from the course" do
      expect(course).to receive_message_chain \
        :submissions_exports,
        :order,
        :includes

      subject.submissions_exports
    end

    it "includes exports for the course" do
      expect(subject.submissions_exports).to include export
    end
  end

  it "has the current course" do
    expect(subject.current_course).to eq course
  end

  it "has the current user" do
    expect(subject.current_user).to eq user
  end
end
