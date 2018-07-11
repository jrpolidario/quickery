Dir[__dir__ + '/quickery/*.rb'].each {|file| require file }
Dir[__dir__ + '/quickery/active_record_extensions/*.rb'].each {|file| require file }

module Quickery
  # Your code goes here...
end
