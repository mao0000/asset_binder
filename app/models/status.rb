class Status < ActiveHash::Base
  self.data = [
    { id: 1, name: '稼働中' },
    { id: 2, name: '点検中' },
    { id: 3, name: '廃車' },
    { id: 4, name: '売却' }
  ]

  include ActiveHash::Associations
  has_many :vehicles
end
