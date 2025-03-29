class AddConfirmedAttendanceToAuditionApplications < ActiveRecord::Migration[7.1]
  def change
    add_column :audition_applications, :confirmed_attendance, :boolean, default: false
  end
end
