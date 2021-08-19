FactoryBot.define do
  factory :call_result do
    id { SecureRandom.uuid }
    association :user
    association :appointment
    cancel_reason { nil }
    result { CallResult.results.keys.sample }
    device_created_at { Time.current }
    device_updated_at { Time.current }
    deleted_at { nil }
  end
end

def build_call_result_payload(call_result = FactoryBot.build(:call_result))
  call_result.attributes.with_payload_keys
end

def build_invalid_call_result_payload
  build_call_result_payload.merge(
    "user_id" => nil,
    "result" => "foo"
  )
end

def updated_call_result_payload(existing_call_result)
  update_time = 10.days.from_now

  build_call_result_payload(existing_call_result).merge(
    "updated_at" => update_time,
    "cancel_reason" => CallResult.cancel_reasons.keys.sample
  )
end
