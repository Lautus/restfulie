module Restfulie::Common::Representation
  class Link
    def initialize(options = {})
      @options = options
    end
    def href
      @options["href"]
    end
    def rel
      @options["rel"]
    end
  end

  # Implements the interface for marshal Xml media type requests (application/xml)
  class XmlD

    cattr_reader :media_type_name
    @@media_type_name = 'application/xml'

    cattr_reader :headers
    @@headers = { 
      :post => { 'Content-Type' => media_type_name }
    }

    def unmarshal(string)
      h = Hash.from_xml(string)
      def h.links
        links = values[0].fetch("link", [])
        links = [links] unless links.kind_of? Array
        links.map do |l|
          Link.new(l)
        end
      end
      h
    end

    def marshal(string, rel)
      string
    end

  end

end
