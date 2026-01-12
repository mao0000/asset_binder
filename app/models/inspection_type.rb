class InspectionType < ActiveHash::Base
  self.data = [
    { id: 1, name: '車検' },
    { id: 2, name: '3ヶ月点検' },
    { id: 3, name: '12ヶ月点検' }
  ]

  include ActiveHash::Associations
  has_many :inspections
end