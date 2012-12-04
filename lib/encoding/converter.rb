Encoding::Converter.instance_eval do
    def search_convpath(from, to, options={})
      new(from, to, options).convpath
    end
end
