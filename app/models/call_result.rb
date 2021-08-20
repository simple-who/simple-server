class CallResult < ApplicationRecord
  include Mergeable
  belongs_to :appointment, optional: true
  belongs_to :user, optional: true

  validates :device_created_at, presence: true
  validates :device_updated_at, presence: true

  enum result: {
    agreed_to_visit: "agreed_to_visit",
    removed_from_overdue_list: "removed_from_overdue_list",
    remind_to_call_later: "remind_to_call_later"
  }

  enum cancel_reason: {
    not_responding: "not_responding",
    moved: "moved",
    dead: "dead",
    invalid_phone_number: "invalid_phone_number",
    public_hospital_transfer: "public_hospital_transfer",
    moved_to_private: "moved_to_private",
    other: "other"
  }
end
