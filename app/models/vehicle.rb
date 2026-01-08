class Vehicle < ApplicationRecord
  extend ActiveHash::Associations::ActiveRecordExtensions
  
  attr_accessor :obe_number_part1, :obe_number_part2, :obe_number_part3
  after_initialize :split_obe_number
  before_validation :combine_obe_number

  validates :v_location, presence: true, length: { maximum: 4 }, format: { with: /\A[ぁ-ん一-龥]+\z/ }
  validates :v_code,     presence: true, length: { maximum: 3 }, format: { with: /\A[A-Z0-9]+\z/ }
  validates :v_kana,     presence: true, length: { is: 1 },      format: { with: /\A[ぁ-ん]\z/ }
  validates :v_serial,   presence: true, length: { maximum: 4 }, format: { with: /\A[0-9]+\z/ }
  validates :office_id,  presence: true
  validates :status_id,  presence: true
  validates :user_id,    presence: true
  validates :obe_number, length: { is: 19 }, format: { with: /\A[0-9]+\z/ }, uniqueness: true, allow_blank: true

  belongs_to :user
  belongs_to :office
  belongs_to :status

  def formatted_obe_number
    return if obe_number.blank?
    "#{obe_number[0..4]}-#{obe_number[5..12]}-#{obe_number[13..18]}"
  end

  private

  def split_obe_number
    return if obe_number.blank?
    self.obe_number_part1 = obe_number[0..4]
    self.obe_number_part2 = obe_number[5..12]
    self.obe_number_part3 = obe_number[13..18]
  end

  def combine_obe_number
    return unless obe_number_part1 || obe_number_part2 || obe_number_part3
    self.obe_number = "#{obe_number_part1}#{obe_number_part2}#{obe_number_part3}"
  end
end
