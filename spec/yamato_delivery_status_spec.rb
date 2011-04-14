# coding: utf-8
require 'yamato_delivery_status'
describe YamatoDeliveryStatus, '問い合わせ番号ごとに現在の配送状況を返すこと' do 
  before do
    status_database = {a: {a: 'OK'}, b: {b: 'NOT FOUND'} }
    @status = YamatoDeliveryStatus.new(status_database)
  end
  it { @status.search([:a]).should == {a: 'OK'} }
  it { @status.search([:b]).should == {b: 'NOT FOUND'} }
  context '配送状況を問い合わせできないとき' do 
    it { proc { @status.search([:timeout]) }.should raise_error(YamatoDeliveryStatus::Unreachable) }
  end
end

