
require 'zookeeper'
require 'forwardable'

require 'z_k/exceptions'
require 'z_k/event_handler_subscription'
require 'z_k/event_handler'
require 'z_k/message_queue'
require 'z_k/locker_base'
require 'z_k/locker'
require 'z_k/shared_locker'
require 'z_k/extensions'
require 'z_k/client'
require 'z_k/client_pool'

module ZK
  def self.new(*args)
    # XXX: might need to do some param parsing here
   
    opts = args.pop if args.last.kind_of?(Hash)

    # ignore opts for now
    Client.new(Zookeeper.new(*args))
  end
end
