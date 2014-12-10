require 'rspec/autorun'
require './lib/sswaffles.rb'

describe 'S3Object' do
  let(:object) { SSWaffles::S3Object.new 'key', nil }

  it 'has a key' do
    object.key.should eq('key')
  end

  it 'has acl' do
    object.acl.should be_a(Hash)
  end

  it '#public_url returns a string' do
    object.public_url.should be_a(String)
  end
end