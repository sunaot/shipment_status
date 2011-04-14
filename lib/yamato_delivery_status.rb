#!/usr/bin/env ruby
# coding: utf-8
require 'uri'
require 'net/http'
require 'nokogiri'

module ShippingCarrier
  class ShipmentStatusAPI
    Limit = 10
    ApiEncoding = 'Shift_JIS'
    def ask(codes)
      raise('too many codes') unless codes.size <= Limit
      scrape(call_api(codes))
    end

    private
    def scrape(html)
      Hash[*(Nokogiri::HTML(html).search("//td[@class='denpyo' or @class='ct']").map {|n| n.content.strip})]
    end

    def call_api(codes)
      parameterize = proc {|numbers| numbers.each.with_index.inject({}) {|r, (n, i)| r["number#{'%02d' % (i+1)}".to_sym] = n; r} }
      net_http('toi.kuronekoyamato.co.jp').start do |http|
        param = {number00: 2, number01: '',
                              number02: '', 
                              number03: '', 
                              number04: '', 
                              number05: '', 
                              number07: '', 
                              number08: '', 
                              number09: '', 
                              number10: '' 
                }.update(parameterize.call(codes))
        extend_hash(param)
        response = http.post('/cgi-bin/tneko', param.to_query_string)
        response.body.force_encoding(ApiEncoding).encode(Encoding.default_external)
      end
    end

    def net_http(uri)
      Net::HTTP.version_1_2
      http = Net::HTTP.new(uri)
      http.open_timeout = 3
      http.read_timeout = 5
      http
    end

    def extend_hash(hash_instance)
      hash_instance.instance_eval do
        class <<self
          define_method(:to_query_string) do 
            self.map {|k,v| "#{URI.encode(k.to_s)}=#{URI.encode(v.to_s)}"}.join('&') 
          end
        end
      end
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
      parts = (codes.size / ShipmentStatusAPI::Limit) + 1
      codes.group_by.with_index {|n, i| i % parts }
    end
  
    def initialize(status)
      @status = status || ShipmentStatusAPI.new
    end
  end
end

