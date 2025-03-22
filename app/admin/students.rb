ActiveAdmin.register User, as: "Student" do
  permit_params :name, :dob, :photo, :address, :email, :password, :password_confirmation, :role, :is_created_by_admin

  scope :all, default: true do |users|
    users.where(role: :student)
  end
  scope("Verified") { |users| users.where(verified: true, role: :student) }
  scope("Unverified") { |users| users.where(verified: false, role: :student) }

  filter :name
  filter :email
  filter :verified

  # **Index Page**
  index do
    selectable_column
    id_column
    column :name
    column :email
    column :verified
    column :dob
    column :address
    actions
  end

  # **Show Page**
  show do
    attributes_table do
      row :name
      row :email
      row :verified
      row :dob
      row :address
      row :photo do |user|
        if user.photo.attached?
          image_tag user.photo.variant(resize: "100x100")
        else
          "No photo uploaded"
        end
      end
    end
    active_admin_comments
  end

  # **Form for Adding/Editing Student**
  form do |f|
    f.inputs "Student Details" do
      f.input :name
      f.input :email
      f.input :dob
      f.input :address
      f.input :photo, as: :file
      f.input :verified
    end
    f.actions
  end

  # **Verify Student Action**
  member_action :verify, method: :put do
    student = User.find(params[:id])
    student.update(verified: true)
    UserMailer.verification_email(student).deliver_later
    redirect_to admin_student_path(student), notice: "Student verified!"
  end

  action_item :verify, only: :show, if: proc { !resource.verified? } do
    link_to "Verify Student", verify_admin_student_path(resource), method: :put
  end

  # **Import Students via CSV**
  collection_action :import_csv, method: :post do
    if params[:file].present?
      begin
        User.import_students(params[:file])
        redirect_to admin_students_path, notice: "Students imported successfully!"
      rescue StandardError => e
        redirect_to admin_students_path, alert: "Failed to import CSV: #{e.message}"
      end
    else
      redirect_to admin_students_path, alert: "Please upload a valid CSV file."
    end
  end  

  # action_item :import, only: :index do
  #   link_to "Import CSV", "#", id: "import-csv-link"
  # end

  # sidebar "Import Students", only: :index do
  #   form_tag import_csv_admin_students_path, multipart: true do
  #     file_field_tag :file
  #     submit_tag "Upload CSV"
  #   end
  # end
  action_item :import, only: :index do
    raw <<-HTML
      <form id="csv-import-form" action="#{import_csv_admin_students_path}" method="post" enctype="multipart/form-data" style="display: none;">
        <input type="hidden" name="authenticity_token" value="#{form_authenticity_token}">
        <input type="file" name="file" id="csv-file-input" required>
      </form>
      <a href="#" id="import-csv-link" class="button">Import CSV</a>
      <script>
        document.getElementById('import-csv-link').addEventListener('click', function(event) {
          event.preventDefault();
          document.getElementById('csv-file-input').click();
        });
  
        document.getElementById('csv-file-input').addEventListener('change', function() {
          document.getElementById('csv-import-form').submit();
        });
      </script>
    HTML
  end

  # **Export Students as CSV**
  action_item :export, only: :index do
    link_to "Export CSV", export_admin_students_path, method: :get
  end

  collection_action :export, method: :get do
    send_data User.students_to_csv, filename: "students-#{Date.today}.csv"
  end

  controller do
    def create
      params[:user][:password] = SecureRandom.alphanumeric(10) # Generate a random 10-character password
      params[:user][:password_confirmation] = params[:user][:password]
      params[:user][:is_created_by_admin] = true
  
      user = User.new(permitted_params[:user])
  
      if user.save
        UserMailer.registration_email(user, params[:user][:password]).deliver_now
        redirect_to admin_students_path, notice: "User created successfully. Email has been sent."
      else
        redirect_to new_admin_student_path, alert: user.errors.full_messages.to_sentence
      end
    end
  
    def update
      user = User.find(params[:id])
      if params[:user][:verified] == "1" && !user.verified?
        user.update(verified: true)
        UserMailer.verification_email(user).deliver_now
      else
        user.update(verified: false)
      end
      super
    end
  end
  
end
  