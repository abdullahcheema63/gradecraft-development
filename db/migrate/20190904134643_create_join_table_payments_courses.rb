class CreateJoinTablePaymentsCourses < ActiveRecord::Migration[5.2]
  def change
    create_join_table :payments, :courses do |t|
      t.index [:payment_id, :course_id]
    end
  end
end
