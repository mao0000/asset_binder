class Office < ActiveHash::Base
  self.data = [
    { id: 1, name: '東京営業所' },
    { id: 2, name: '千葉営業所' },
    { id: 3, name: '神奈川営業所' },
    { id: 4, name: '埼玉センター' },
  ]

  include ActiveHash::Associations
  has_many :vehicles
end
