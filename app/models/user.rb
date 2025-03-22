class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  enum role: { student: 0, admin: 1 }

  has_one_attached :photo
  

  validates :name, presence: true
  validates :email, presence: true, uniqueness: true
  validates :dob, :address, presence: true, if: -> { student? }
  after_commit :send_registration_email, on: :create

  scope :students, -> { where(role: :student) }

  def self.ransackable_attributes(auth_object = nil)
    ["address", "created_at", "dob", "email", "encrypted_password", "id", "id_value", "name", "remember_created_at", "reset_password_sent_at", "reset_password_token", "role", "updated_at", "verified"]
  end

  def verified?
    self.verified
  end

  # **CSV Import & Export for Students**
  require 'csv'

  def self.import_students(file)
    CSV.foreach(file.path, headers: true) do |row|
      student = User.find_or_initialize_by(email: row["email"])
      student.assign_attributes(
        name: row["name"],
        dob: row["dob"],
        address: row["address"],
        role: :student,
        verified: row["verified"],
        is_created_by_admin: true
      )

      # Generate random password if new student
      if student.new_record?
        password = SecureRandom.alphanumeric(10)
        student.password = password
        student.password_confirmation = password
      end
      new_user = student.new_record?
      
      # Send email only for new students
      if student.save! && new_user
        UserMailer.registration_email(student, password).deliver_now
      end
    end
  end

  def self.students_to_csv
    attributes = %w[id name email verified dob address]

    CSV.generate(headers: true) do |csv|
      csv << attributes
      students.each do |user|
        csv << attributes.map { |attr| user.send(attr) }
      end
    end
  end

  private

  def send_registration_email
    return if Rails.env.test? # Avoid emails during tests
    puts "self.sign_in_count==============>#{self.is_created_by_admin}"
    unless self.is_created_by_admin
      UserMailer.registration_email(self).deliver_now
    end
  end
end
