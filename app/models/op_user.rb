class OpUser < ApplicationRecord
  def self.find_or_create_from_auth_hash!(auth_hash)
    provider = auth_hash[:provider]
    uid = auth_hash[:uid]
    email = auth_hash[:info][:email]
  
    OpUser.find_or_create_by!(provider: provider, uid: uid) do |op_user|
      op_user.email = email
    end
  end
end
