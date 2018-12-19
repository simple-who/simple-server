class Api::Current::FacilitiesController < Api::Current::SyncController
  skip_before_action :authenticate, only: [:sync_to_user]
  skip_before_action :validate_facility, only: [:sync_to_user]
  skip_before_action :validate_current_facility_belongs_to_users_facility_group, only: [:sync_to_user]

  def sync_to_user
    __sync_to_user__('facilities')
  end

  private

  def transform_to_response(facility)
    facility.as_json
  end
end
