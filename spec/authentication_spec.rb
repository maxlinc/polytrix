describe 'authentication' do
  SDKs.each do |sdk|
    context sdk, sdk.to_sym do
      it 'should authenticate' do
        validate_challenge sdk, "authenticate" do |success|
          # Assertions
          expect(Pacto).to have_validated(:post, 'https://identity.api.rackspacecloud.com/v2.0/tokens')
          expect(Pacto).to_not have_failed_validations
          expect(Pacto).to_not have_unmatched_requests
        end
      end
    end
  end
end
