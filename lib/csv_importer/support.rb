class Object
  # The hidden singleton lurks behind everyone
  def metaclass
    class << self
      self 
    end
  end
  
  # If class_eval is called on an object, add those methods to its metaclass
  def class_eval(*args, &block)
    metaclass.class_eval(*args, &block)
  end
  
  def self.to_db(value)
    value
  end
  
  def self.from_db(value)
    value
  end
end

class Boolean
  def self.to_db(value)
    if value.is_a?(Boolean)
      value
    else
      ['true', 't', '1'].include?(value.to_s.downcase)
    end
  end

  def self.from_db(value)
    !!value
  end
end

class Date
  def self.to_db(value)
    return nil if value.blank?
    
    date = Date.parse(value.to_s)
    Time.utc(date.year, date.month, date.day)
  rescue
    nil
  end
  
  def self.from_db(value)
    value.to_date unless value.blank?
  end
end

class Time
  def self.to_db(value)
    return nil if value.blank?
    
    time = Time.parse(value.to_s)
    Time.utc(time.year, time.month, time.day, time.hour, time.min, time.sec)
  rescue
    nil
  end
  
  def self.from_db(value)
    value.to_time unless value.blank?
  end
end

class Integer
  def self.to_db(value)
    value_to_i = value.to_i
    if value_to_i == 0
      value.to_s =~ /^(0x|0b)?0+/ ? 0 : nil
    else
      value_to_i
    end
  end
end

class NilClass
  def to_db(value)
    value
  end
  
  def from_db(value)
    value
  end
end

class String
  def self.to_db(value)
    value.nil? ? nil : value.to_s
  end
  
  def self.from_db(value)
    value.nil? ? nil : value.to_s
  end
end

class Array
  def self.to_db(value)
    if value.is_a? Array
      value
    elsif value.is_a? String
      value.split(",").map(&:strip)
    else
      []
    end
  end
  
  def self.from_db(value)
    if value.is_a? Array
      value
    else
      []
    end
  end
end

class PhotoFile
  def self.to_db(value)
    return nil if value.nil?
    return value if value.is_a? Paperclip::Attachment
    
    uri = URI.parse(value)
    path = "/tmp/#{Time.now.to_f}.jpg"
    Net::HTTP.start(uri.host) do |http|
      resp = http.get(uri.path)
      open(path, "wb") { |file|
        file.write(resp.body)
      }
    end
    ActionController::TestUploadedFile.new(path, "image/jpeg")
  rescue Exception => e
    nil
  end
  
  def self.from_db(value)
    return nil if value.nil?   
    return value if value.is_a? ActionController::TestUploadedFile
   
    if Presently.uses_s3?
      Presently::MediaPlug.image(value.url(:original))
    else
      value.url(:original)
    end
  end
end
