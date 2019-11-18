describe Services::Actions::RecalculatesStudentScore do
  let(:earned_badge) { create :earned_badge }

  it "expects an earned badge to recalculate the score for" do
    expect { described_class.execute }.to \
      raise_error LightService::ExpectedKeysNotInContextError
  end

  it "recalculates the score if there is a point total" do
    expect{ described_class.execute earned_badge: earned_badge }.to \
      change(ScoreRecalculatorJob.jobs, :size).by 1
  end

  it "does not recalculate the score if there is no point total" do
    earned_badge.badge.update_attributes(full_points: nil)
    expect{ described_class.execute earned_badge: earned_badge }.not_to \
      change(ScoreRecalculatorJob.jobs, :size)
  end
end
