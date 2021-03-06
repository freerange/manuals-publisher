require "gds-sso/user"

class User
  include Mongoid::Document
  include Mongoid::Timestamps
  include GDS::SSO::User

  store_in collection: :manuals_publisher_users

  field :uid, type: String
  field :email, type: String
  field :version, type: Integer
  field :name, type: String
  field :permissions, type: Array
  field :remotely_signed_out, type: Boolean, default: false
  field :organisation_slug, type: String
  field :organisation_content_id, type: String
  field :disabled, type: Boolean, default: false

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :name, :uid
  attr_accessible :email, :name, :uid, :permissions, as: :oauth
end
