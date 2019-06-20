namespace :licenses do
  desc "Convert has_paid to licenses by generating a license for each"
  task convert_has_paid_to_licenses: :environment do |task, args|
    # This requires more polish and extensive testing before it is run in production.
    paid_courses = Course.where has_paid: true
    puts "Number of paid courses:"
    puts paid_courses.length
    paid_courses.each do |c|
      puts c.name
      puts c.id
      u = c.staff.first # This is probably flawed - how do users know which prof owns their new license?
      puts u.username
      l = u.license
      if !l
        puts "User has no license, so create one."
        l = License.new({
          license_type: LicenseType.first, # Should use a specific LicenseType ("Legacy") instead. Create LicenseTypes as part of this script?
          user: u, 
          courses: [
            c,
          ],
        })
        p = Payment.new({
          first_name: u.first_name,
          last_name: u.last_name,
          organization: "Unknown",
          phone: "Unknown",
          addr1: "Unknown",
          city: "Unknown",
          country: "Unknown",
          amount_usd: 0.0,
          source: "Legacy",
        })
        l.start! p
      else
        puts "User already has a license, so add this course to it."
        l.courses << c
        l.save!
      end
    end
  end
end
