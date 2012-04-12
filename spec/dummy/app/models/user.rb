class User < ActiveRecord::Base
  has_many :tweets
  attr_accessible :name, :protected

  def to_param
    name
  end
end
