# Retries marshalling to an acceptable media type if
# the server returns with 406: content negotiation. This means looking for
# another media type that both server and client
# understands, picking its converter and using it
# to marshal the original payload again.
#
# To use it, load it in your dsl:
# Restfulie.at("http://localhost:3000/product/2").conneg_when_unaccepted.get
module Restfulie::Client::Feature
  class ConnegWhenUnaccepted
    
  	def execute(chain, request, response, env)
			resp = chain.continue(request, response, env)
			return resp if resp.code.to_i!=406
		  
			accept = Restfulie::Common::Converter.find_for(response.headers["Accept"])
		  return resp if accept.nil?
		  
    	request.with("Content-type", accept)
    	env = env.dup.merge(:body => env[:payload])
    	Restfulie::Client::Feature::SerializeBody.new.execute(chain, request, response, env)
  	end

  end
end