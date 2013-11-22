describe 'managing servers' do
  SDKs.each do |sdk|
    context sdk, sdk.to_sym do
      it 'create 2 servers' do
        vars = standard_env_vars
        vars.merge!({
          'RAX_REGION' => 'DFW',
          'SERVER1_IMAGE' => 'f70ed7c7-b42e-4d77-83d8-40fa29825b85',
          'SERVER1_FLAVOR' => '2'
        })
        validate_challenge sdk, "servers", vars do |success|
          # Assertions
          expect(Pacto).to have_validated(:post, /dfw.servers.api.rackspacecloud.com\/v2\/\d+\/servers/) #.twice
          expect(Pacto).to_not have_failed_validations
          expect(Pacto).to_not have_unmatched_requests
        end
      end
    end
  end
end