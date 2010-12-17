# 
# Class implementing the MIME multipart message format (currently only containing the "Form Data" subtype)
# 
# Created 2008-10-30 by Joachim Fornallaz <fornallaz@kooaba.com>
# 

module Kooaba
  module TypedFile
    attr_accessor :content_type
  end

  class MultipartMessage

    def initialize
      @file_parts = []
      @text_parts = []
    end

    def add_file_part(name, file, type)
      case file
      when String
        io = open(file)
      else
        io = file
      end

      unless io.respond_to?(:content_type)
        io.extend(TypedFile)
        io.content_type = type
      end
      
      @file_parts << [name, io]
    end

    def add_text_part(name, text)
      @text_parts << [name, text]
    end

    def content_type
      "multipart/form-data; boundary=#{boundary_token}"
    end

    def body
      boundary_marker = "--#{boundary_token}\r\n"
      body = @text_parts.map { |param|
        (name, value) = param
        boundary_marker + text_to_multipart(name, value)
      }.join('') + @file_parts.map { |param|
        (name, value) = param
        boundary_marker + data_to_multipart(name, value)
      }.join('') + "--#{boundary_token}--\r\n"
    end

  protected

    def boundary_token
      @boundary_token ||= [Array.new(8) {rand(256)}].join
    end

    def data_to_multipart(key, data)
      filename = data.respond_to?(:original_filename) ? data.original_filename : File.basename(data.path)
      mime_type = data.content_type
      part = "Content-Disposition: form-data; name=\"#{key}\"; filename=\"#{filename}\"\r\n"
      part += "Content-Transfer-Encoding: binary\r\n"
      part += "Content-Type: #{mime_type}\r\n\r\n#{data.read}\r\n"
      data.rewind
      part
    end

    def text_to_multipart(key,value)
      "Content-Disposition: form-data; name=\"#{key}\"\r\n\r\n#{value}\r\n"
    end
  end
end