class Tweet < ActiveRecord::Base
  belongs_to :user
  attr_accessible :body

  def self.creatable?(creator, parent)
    creator == parent
  end

  def self.readable?(reader, parent)
    return true unless parent.protected?
    reader == parent
  end

  def readable?(reader)
    return true unless user.protected?
    reader == user
  end

  def updatable?(updater)
    updater == user
  end

  def destroyable?(destroyer)
    destroyer == user
  end
end
