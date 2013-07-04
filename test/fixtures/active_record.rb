require 'active_record'

ActiveRecord::Base.establish_connection(
  :adapter  => 'sqlite3',
  :database => ':memory:'
)

ActiveRecord::Schema.define do
  create_table :ar_models, :force => true do |t|
    t.string :attr1
    t.string :attr2
  end
end

class ARModel < ActiveRecord::Base
end

class ARModelSerializer < ActiveModel::Serializer
  attributes :attr1, :attr2
end
