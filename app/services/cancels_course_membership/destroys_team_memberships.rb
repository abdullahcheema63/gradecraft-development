module Services
  module Actions
    class DestroysTeamMemberships
      extend LightService::Action

      expects :membership

      executed do |context|
        membership = context[:membership]

        TeamMembership.for_course(membership.course).for_student(membership.user).destroy_all

        if membership.user.team_leaderships_for_course(membership.course).length > 0
          puts "Member is a leader for at least one team"
        end

        puts "Member: #{membership.user.first_name} #{membership.user.last_name}"
        
        membership.user.team_leaderships_for_course(membership.course).each do |team_leadership|
          team = team_leadership.team 
          puts "Team: #{team.name}"
          puts "Team leaders: #{team.leaders.pluck("first_name")}"
          team.leadership = team.leaders.reject {|member| member["id"] == membership.user.id}
          puts "Team leaders: #{team.leaders.pluck("first_name")}"
          team.save
        end

      end
    end
  end
end
