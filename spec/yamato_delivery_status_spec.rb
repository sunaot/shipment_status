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

describe ShipmentStatusAPI, 'キャリアへ問い合わせて配送状況を得る' do
  before do
    @api = ShipmentStatusAPI.new
    @test_code = "10000000000" + (10000000000 % 7).to_s
  end
  it { @api.ask([@test_code]).should == {'1000-0000-0004' => '伝票番号未登録'} }
end
