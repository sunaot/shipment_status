# coding: utf-8
require 'yamato_delivery_status'
include ShippingCarrier
describe ShipmentStatus, '問い合わせ番号ごとに現在の配送状況を返すこと' do 
  before do
    status = double('status')
    status.stub(:ask) { {a: 'OK', b: 'NOT FOUND'} }
    @status = ShipmentStatus.new(status)
  end
  it { @status.search([:a, :b]).should == {a: 'OK', b: 'NOT FOUND'} }
  context '配送状況を問い合わせできないとき' do 
    it { proc { @status.search([:timeout]) }.should raise_error(ShipmentStatus::Unreachable) }
  end
end

