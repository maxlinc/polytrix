describe 'Files' do
  SDKs.each do |sdk|
    context sdk, sdk.to_sym do
      it 'lists containers' do
        vars = standard_env_vars
        validate_challenge sdk, "list_containers", vars do |success|
          # Assertions
          expect(Pacto).to have_validated(:get, /\/v1\/[\w-]+/) #.twice
          expect(Pacto).to_not have_failed_validations
          expect(Pacto).to_not have_unmatched_requests
        end
      end
    end
  end
end
