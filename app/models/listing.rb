class Listing < ActiveRecord::Base
  if Rails.env.development?
  	has_attached_file :image, :styles => { :medium => "200x200>", :thumb => "100x100>" }, :default_url => "missing.png"
  	validates_attachment_content_type :image, :content_type => ["image/jpg", "image/jpeg", "image/png", "image/gif"]

  else
  	has_attached_file :image, :styles => { :medium => "200x200>", :thumb => "100x100>" }, :default_url => "missing.png",
    :storage => :dropbox,
    :dropbox_credentials => Rails.root.join("config/dropbox.yml"),
    :path => ":style/:id_filename"
    validates_attachment_content_type :image, :content_type => ["image/jpg", "image/jpeg", "image/png", "image/gif"]
  end
  belongs_to :user
  has_many :orders
end
