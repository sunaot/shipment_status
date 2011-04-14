#!/usr/bin/env ruby
# coding: utf-8
require 'uri'
require 'net/http'
require 'nokogiri'
require 'pp'

class Hash
  def to_query_string
    self.map {|k,v| "#{URI.encode(k.to_s)}=#{URI.encode(v.to_s)}"}.join('&')
  end
  alias to_qs to_query_string
end

module ShippingCarrier
  class ShipmentStatusAPI
    def ask
      raise('too many bill numbers') unless bill_numbers.size <= 10
      parameterize = proc {|numbers| numbers.each.with_index.inject({}) {|r, (n, i)| r["number#{'%02d' % (i+1)}".to_sym] = n; r} }
      Net::HTTP.version_1_2
      Net::HTTP.start('toi.kuronekoyamato.co.jp', 80) do |http|
        param = {number00: 2, number01: '',
                              number02: '', 
                              number03: '', 
                              number04: '', 
                              number05: '', 
                              number07: '', 
                              number08: '', 
                              number09: '', 
                              number10: '' 
                }.update(parameterize.call(bill_numbers))
        response = http.post('/cgi-bin/tneko', param.to_qs)
        response.body.force_encoding('Shift_JIS').encode('UTF-8')
      end
      Hash[*(Nokogiri::HTML(ask_delivery_status.call(bill_numbers)).search("//td[@class='denpyo' or @class='ct']").map {|n| n.content.strip})]
    end
  end
  class ShipmentStatus
    class Unreachable < Exception; end
    def search(codes)
      raise Unreachable if codes.include? :timeout
      each_bulk(codes).map do |bulk_codes|
        @status.ask bulk_codes
      end.reduce(:merge)
    end
  
    def each_bulk(codes)
      parts = (codes.size / 10) + 1
      codes.group_by.with_index {|n, i| i % parts }
    end
  
    def initialize(status)
      @status = status || ShipmentStatusAPI.new
    end
  end

end

ask_delivery_status = lambda do |bill_numbers|
  raise('too many bill numbers') unless bill_numbers.size <= 10
  parameterize = proc {|numbers| numbers.each.with_index.inject({}) {|r, (n, i)| r["number#{'%02d' % (i+1)}".to_sym] = n; r} }
  Net::HTTP.version_1_2
  Net::HTTP.start('toi.kuronekoyamato.co.jp', 80) {|http|
    param = {number00: 2, number01: '',
                          number02: '', 
                          number03: '', 
                          number04: '', 
                          number05: '', 
                          number07: '', 
                          number08: '', 
                          number09: '', 
                          number10: '' 
            }.update(parameterize.call(bill_numbers))
    response = http.post('/cgi-bin/tneko', param.to_qs)
    response.body.force_encoding('Shift_JIS').encode('UTF-8')
  }
end

bill_numbers = %w[
]
status = Hash[*(Nokogiri::HTML(ask_delivery_status.call(bill_numbers)).search("//td[@class='denpyo' or @class='ct']").map {|n| n.content.strip})]
pp status

