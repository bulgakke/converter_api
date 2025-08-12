module Serialization
  def serialize(data)
    if data.is_a? ActiveRecord::Relation
      data.map { |record| serialize_one(record) }
    elsif data.is_a? ActiveRecord::Base
      serialize_one(data)
    else
      raise ArgumentError, "Can't serialize #{data.class.name}"
    end
  end

  def serialize_one(record)
    serializer = "#{record.class.name}Serializer".constantize
    serializer.new(record).as_json
  end
end
