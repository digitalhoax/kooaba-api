require 'uri'
require 'net/http'
require 'time'
require 'base64'  
require 'md5'
require File.dirname(__FILE__) + "/multipart_message"
require 'rexml/document'

module Kooaba
  class Item < Struct.new(:title, :reference_id); end
  
  class Query
    attr_accessor :item
    
    def self.default_options
      @default_options ||= {
        :api_credentials => { :access_key_id => "access", :secret_access_key  => "secret" },
        :api_adress => "http://search.kooaba.com/queries.xml"
      }
    end
    
    def initialize(file, type, group_id, options = {})
      options = self.class.default_options.merge(options)
      @api_credentials = options[:api_credentials]
      @api_adress = options[:api_adress]
      @message = MultipartMessage.new
      @message.add_file_part('query[file]', file, type)
      @message.add_text_part('query[group_ids][]', group_id)
      @group_id = group_id
    end
    
    def submit
      url = URI.parse(@api_adress)
      req = Net::HTTP::Post.new(url.path)
      req.body = @message.body
      req['date'] = Time.new.httpdate
      req['content-type'] = @message.content_type
      req['authorization'] = "KWS #{@api_credentials[:access_key_id]}:" + kws_signature(@api_credentials[:secret_access_key], req)
      
      res = Net::HTTP.new(url.host, url.port).start { |http| http.request(req) }
      case res
      when Net::HTTPSuccess, Net::HTTPRedirection
        parse(res)
      end
      res
    end

  private
  
    def parse(response)
      doc = REXML::Document.new(response.body)
      title_element = doc.root.elements["item/title"]
      reference_id = doc.root.elements["item/reference-id"]
      if title_element
        self.item = Item.new(title_element.text, reference_id.text)
      end
    end

    def kws_signature(secret_key, request)
      to_sign = [
        [:method, request.method],
        [:content_md5, MD5.hexdigest(request.body)],
        [:content_type, request.content_type],
        [:date, request['date']],
        [:path, request.path]
      ]
      Base64::encode64(Digest::SHA1.digest(secret_key + "\n\n" + to_sign.map{ |key, value| value }.join("\n"))).strip
    end
    
  end
end