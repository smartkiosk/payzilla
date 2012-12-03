require 'ostruct'

class ConfigStub < OpenStruct
  def initialize(keyword)
    super :keyword => keyword, :debug_level => Logger::DEBUG
  end
end