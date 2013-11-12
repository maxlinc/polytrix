describe 'authentication' do
  SDKs.each do |sdk|
    context sdk, sdk.to_sym do
      it 'should authenticate' do
        validate_challenge sdk, "authenticate" do |success|
          # Assertions
          expect(success).to be_true
          expect(WebMock).to have_requested(:post, 'https://identity.api.rackspacecloud.com/v2.0/tokens')
        end
      end
    end
  end
end
