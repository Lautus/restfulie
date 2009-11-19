
module Restfulie
  def to_json
    super :methods => :following_states
  end
  
  def to_xml(options = {})
    return super unless respond_to?(:status)

    controller = options[:controller]
    return super if controller.nil?

    options[:skip_types] = true
    super options do |xml|
      possible_following = []
      default_transitions_map = available_transitions
      default_transitions = default_transitions_map[:allow] unless default_transitions_map.nil?
    
      possible_following += default_transitions unless default_transitions.nil?
      extra = self.following_transitions if self.respond_to?(:following_transitions)
      
      extra.each do |t|
        if t.class.name!="Array"
          possible_following << t
        else
          t = Transition.new(t[0], t[1], t[2], nil)
          possible_following << t
        end
      end if extra
      
      return super if possible_following.empty?
      
      possible_following.each do |result|
        
        result = self.class._transitions(result.to_sym) if result.class!=Restfulie::Transition
        
        if result.action
          action = result.action
          body = result.body
          action = body.call(self) if body

          rel = action[:rel] || result.name || action[:action]
          action[:rel] = nil
        else
          action = {}
          rel = result.name
        end
    
        action[:action] ||= result.name
        translate_href = controller.url_for(action)
        if options[:use_name_based_link]
          xml.tag!(rel, translate_href)
        else
          xml.tag!('atom:link', 'xmlns:atom' => 'http://www.w3.org/2005/Atom', :rel => rel, :href => translate_href)
        end
      end
    end
  end

  def create_method(name, &block)
    self.class.send(:define_method, name, &block)
  end
  
end
