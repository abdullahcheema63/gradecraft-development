describe ChallengeGradeUpdaterJob do
  let(:challenge_grade) { create :challenge_grade }

  subject { described_class.new }

  describe "#perform" do
    it "caches the team's scores" do
      allow(subject).to receive(:notify_challenge_grade_released).and_return true
      expect_any_instance_of(ChallengeGrade).to receive(:cache_team_scores)
      subject.perform challenge_grade.id
    end
  end
end
