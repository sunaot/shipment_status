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

# thanks to Ryan Heath
#  - http://rpheath.com/posts/341-ruby-inject-with-index
module Enumerable
  def inject_with_index(injected)
    each_with_index{ |obj, index| injected = yield(injected, obj, index) }
    injected
  end
end

class YamatoDeliveryStatus
  class Unreachable < Exception; end
  def search(codes)
    code = codes.shift
    raise Unreachable if code == '3'
    code == '1' ? 'OK' : 'NOT FOUND'
  end
end

ask_delivery_status = lambda do |bill_numbers|
  raise('too many bill numbers') unless bill_numbers.size <= 10
  parameterize = proc {|numbers| numbers.inject_with_index({}) {|r, n, i| r["number#{'%02d' % (i+1)}".to_sym] = n; r} }
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

