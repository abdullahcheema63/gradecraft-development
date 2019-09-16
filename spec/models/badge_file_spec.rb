describe BadgeFile do
  let(:badge) { build(:badge) }

  subject { new_badge_file }
  let(:new_badge_file) { badge.badge_files.new image_file_attrs }

  extend Toolkits::Models::Shared::Files
  define_context # pull in attrs for image and text files

  describe "validations" do
    it { is_expected.to be_valid }

    it "requires a filename" do
      subject.filename = nil
      expect(subject).to_not be_valid
      expect(subject.errors[:filename]).to include "can't be blank"
    end
  end

  describe "as a dependency of the submission" do
    it "is saved when the parent submission is saved" do
      subject.badge.save!
      expect(subject.badge_id).to equal badge.id
      expect(subject.new_record?).to be_falsey
    end

    it "is deleted when the parent submission is destroyed" do
      subject.badge.save!
      expect {badge.destroy}.to change(BadgeFile, :count).by(-1)
    end
  end

  describe "formatting name of mounted file" do
    subject { new_badge_file.read_attribute(:file) }
    let(:save_badge) { new_badge_file.badge.save! }

    it "accepts text files as well as images" do
      new_badge_file.file = fixture_file("test_file.txt", "txt")
      save_badge
      expect expect(subject).to match(/\d+_test_file\.txt/)
    end

    it "has an accessible url" do
      save_badge
      expect expect(subject).to match(/\d+_test_image\.jpg/)
    end

    it "shortens and removes non-word characters from file names on save" do
      new_badge_file.file = fixture_file("Too long, strange characters, and Spaces (In) Name.jpg", "img/jpg")
      save_badge
      expect(subject).to match(/\d+_too_long__strange_characters__and_spaces_\.jpg/)
    end
  end

  describe "#course" do
    it "returns the associated course" do
      course = create(:course)
      badge.course = course
      expect(subject.course).to eq(course)
    end
  end
end
