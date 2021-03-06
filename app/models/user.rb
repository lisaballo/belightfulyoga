class User < ActiveRecord::Base
  
  belongs_to :client_group
  has_many :addresses
    accepts_nested_attributes_for :addresses
  has_one :last_address, class_name: "Address", order: "created_at DESC"
  
  has_many :carts
  has_many :course_registrations, as: :registerable
    accepts_nested_attributes_for :course_registrations
  has_many :courses, through: :course_registrations
    
  has_many :course_attendees, as: :attendable
  has_many :walkins, -> { where(walk_in: true) }, :source => :course_attendees, :foreign_key => :attendable_id
    accepts_nested_attributes_for :walkins
  has_many :waivers
  
  
  
  
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :invitable

  # Setup accessible (or protected) attributes for your model
  attr_accessor :code
  attr_accessible :email, :password, :password_confirmation, :remember_me, :client_group_id, :synced_to_mailchimp, :first_name, :middle_initial, :last_name, :address_1, :address_2, 
  :city, :state, :zip, :home_phone, :work_phone, :work_phone_ext, :cell_phone, :occupation, :emergency_contact, :birthdate, :guardian, :code,
  :walkins_attributes, :course_registrations_attributes, :addresses_attributes
  
  validates_presence_of :first_name, :last_name, :email
  
  validates_presence_of :code, :if => lambda { self.code.present? && !self.code.blank? }
  before_validation :check_code, :if => lambda { self.code.present? && !self.code.blank? }

  
  def full_name
    return "#{first_name} #{last_name}"
  end
  
  def attended_course?(course_event_id)
    CourseEvent.find(course_event_id).attendees.find_by_attendable_type_and_attendable_id("User", self.id).present?
  end
  
  def sync_mailchimp
    gb = Gibbon::API.new(ENV['MAILCHIMP_API'])

            list_id = ENV['MAILCHIMP_LIST_ID']

            merge_vars = {
              'FNAME' => self.first_name,
              'LNAME' => self.last_name,
              'BDATE' => self.birthdate
            }

            double_optin = false
            #double_optin = false if !self.facebook_id.empty?
            send_welcome = !double_optin

            response = gb.listSubscribe({:id => list_id,
              :email_address => self.email,
              :merge_vars => merge_vars,
              :double_optin => double_optin,
              :send_welcome => send_welcome})
  end
  
  RailsAdmin.config do |config|
    config.model User do    
      label 'Site User'
      navigation_label 'Users'
      visible false
      weight -2
      
      object_label_method do
          :full_name
      end
    end
  end
  
  
protected
  
  def check_code
    client_group = ClientGroup.where('code iLike ?', code).first
    if client_group
      self.client_group_id = client_group.id
    else  
      self.errors.add :code, "does not match any registered groups"
    end  
  end
end
