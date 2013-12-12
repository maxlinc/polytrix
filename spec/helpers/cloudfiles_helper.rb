require 'fog'

def test_file
  without_webmock do
    service = Fog::Storage.new({
      :provider             => 'rackspace',
      :rackspace_username   => ENV['RAX_USERNAME'],
      :rackspace_api_key    => ENV['RAX_API_KEY'],
    })

    directory = service.directories.create :key => 'asdf'
    file = directory.files.create :key => 'asdf', :body => 'efgh'
  end
end

def without_webmock
  WebMock.disable!
  ret_val = yield
  WebMock.enable!
  ret_val
end
