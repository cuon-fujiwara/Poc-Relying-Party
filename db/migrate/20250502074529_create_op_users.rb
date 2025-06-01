class CreateOpUsers < ActiveRecord::Migration[7.2]
  def change
    create_table :op_users do |t|
      t.string :provider
      t.string :uid
      t.string :email

      t.timestamps
    end

    add_index :op_users, %i[provider uid], unique: true
  end
end
