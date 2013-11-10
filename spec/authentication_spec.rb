SDKs = ['fog', 'pyrax']
describe 'authentication' do
  SDKs.each do |sdk|
    context sdk do
      it 'should authenticate' do
        success = invoke_challenge sdk, "authenticate"
        expect(success).to be_true
        # expect(Pacto).to have_validated 'Authentication'
      end
    end
  end
end
