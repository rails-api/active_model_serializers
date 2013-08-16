require 'active_record'

ActiveRecord::Base.establish_connection(
  :adapter  => 'sqlite3',
  :database => ':memory:'
)

ActiveRecord::Schema.define do
  create_table :ar_profiles, :force => true do |t|
    t.string :name
    t.string :description
    t.string :comments
  end
end

class ARProfile < ActiveRecord::Base
end

class ARProfileSerializer < ActiveModel::Serializer
  attributes :name, :description
end
