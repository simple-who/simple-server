require 'swagger_helper'

describe 'Patients API' do

  path '/patients/sync' do

    post 'Syncs patient, address and phone number data from device to server.' do
      tags 'patient'
      consumes 'application/json'
      parameter name: :patients, in: :body, schema: patient_sync_request_spec

      response '200', 'patients created' do
        let(:patients) { { patients: (1..10).map { build_patient } } }

        before do |example|
          submit_request(example.metadata)
        end

        it 'returns a valid 201 response' do |example|
          assert_response_matches_metadata(example.metadata)
        end
      end
    end
  end
end