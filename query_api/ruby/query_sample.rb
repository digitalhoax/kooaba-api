#!/usr/bin/env ruby -wKU

# 
# Sample code in Ruby for using the kooaba REST API
# 
# Created 2008-10-30 by Joachim Fornallaz
# Updated 2010-09-13 by Joachim Fornallaz
# 
# Contact: support@kooaba.com
# 

require 'kooaba/query'

Kooaba::Query.default_options[:api_credentials] = { 
  :access_key_id => 'df8d23140eb443505c0661c5b58294ef472baf64', 
  :secret_access_key => '054a431c8cd9c3cf819f3bc7aba592cc84c09ff7'
}

group_id = 32
query = Kooaba::Query.new("../lena.jpg", "image/jpeg", group_id)
res = query.submit
puts "Server Response"
puts "==============="
puts res.body
puts ""
puts "Recognized Item"
puts "==============="
puts query.item.inspect