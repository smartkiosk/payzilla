String.class_eval do
  # Changes case of the string into lowerCamelCase.
  #
  # @return [String] in lowerCamelCase style.
  def lower_camelcase
    str = dup
    str.gsub!(/\/(.?)/) { "::#{$1.upcase}" }
    str.gsub!(/(?:_+|-+)([a-z])/) { $1.upcase }
    str.gsub!(/(\A|\s)([A-Z])/) { $1 + $2.downcase }
    str
  end
end
