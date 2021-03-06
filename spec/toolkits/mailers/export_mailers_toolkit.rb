module Toolkits
  module Mailers
    module ExportsMailerToolkit
      module SharedExamples
        RSpec.shared_examples "a complete submissions export email body" do
          it "includes the professor's first name" do
            should include_in_mail_body professor.first_name
          end

          it "includes the assignment name" do
            should include assignment.name
          end

          it "includes the assignment term for the course" do
            should include course.assignment_term.downcase
          end

          it "includes the course name" do
            should include_in_mail_body course.name
          end
        end

        RSpec.shared_examples "a team submissions export email" do
          it "includes the team term for the course" do
            should include course.team_term.downcase
          end

          it "includes the team name" do
            should include_in_mail_body team.name
          end
        end

        RSpec.shared_examples "a submissions export email with archive data" do
          it "includes the archive url" do
            should include downloads_path
          end
        end

        RSpec.shared_examples "a submissions export email without archive data" do
          it "doesn't include the archive url" do
            should_not include downloads_path
          end
        end
      end
    end
  end
end
