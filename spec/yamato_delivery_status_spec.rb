# coding: utf-8
require 'yamato_delivery_status'
describe YamatoDeliveryStatus, '問い合わせ番号ごとに現在の配送状況を返すこと' do 
  before do
    @status = YamatoDeliveryStatus.new
  end
  it { @status.search(['1']).should == 'OK' }
  it { @status.search(['2']).should == 'NOT FOUND' }
  context '配送状況を問い合わせできないとき' do 
    it { proc { @status.search(['3']) }.should raise_error(YamatoDeliveryStatus::Unreachable) }
  end
end

