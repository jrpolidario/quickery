Dir[__dir__ + '/quickery/*.rb'].each {|file| require file }
Dir[__dir__ + '/quickery/active_record_extensions/*.rb'].each {|file| require file }
Dir[__dir__ + '/quickery/errors/*.rb'].each {|file| require file }

module Quickery
end
