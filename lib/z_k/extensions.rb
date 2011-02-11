module ZK
  module Extensions
    # some extensions to the ZookeeperCallbacks classes, mainly convenience
    # interrogators
    module Callbacks
      module CallbackClassExt
        # allows for easier construction of a user callback block that will be
        # called with the callback object itself as an argument. 
        #
        # *args, if given, will be passed on *after* the callback
        #
        # example:
        #   
        #   WatcherCallback.create do |cb|
        #     puts "watcher callback called with argument: #{cb.inspect}"
        #   end
        #
        #   "watcher callback called with argument: #<ZookeeperCallbacks::WatcherCallback:0x1018a3958 @state=3, @type=1, ...>"
        #
        #
        def create(*args, &block)
          # honestly, i have no idea how this could *possibly* work, but it does...
          cb_inst = new { block.call(cb_inst) }
        end
      end

      module WatcherCallbackExt
        include ZookeeperConstants

        STATES = %w[connecting associating connected auth_failed expired_session].freeze unless defined?(STATES)

        EVENT_TYPES = %w[created deleted changed child session notwatching].freeze unless defined?(EVENT_TYPES)

        STATES.each do |state|
          class_eval <<-RUBY, __FILE__, __LINE__ + 1
            def #{state}?
              @state == ZOO_#{state.upcase}_STATE
            end
          RUBY
        end

        EVENT_TYPES.each do |ev|
          class_eval <<-RUBY, __FILE__, __LINE__ + 1
            def #{ev}?
              @type == ZOO_#{ev.upcase}_EVENT
            end
          RUBY
        end

        alias :not_watching? :notwatching?

        # has this watcher been called because of a change in connection state?
        def state_event?
          path.nil? or path.empty?
        end

        # has this watcher been called because of a change to a zookeeper node?
        def node_event?
          path and not path.empty?
        end
      end
    end   # Callbacks

    # aliases for long-names of properties from mb-zookeeper version
    module Stat
      [ %w[created_zxid czxid],
        %w[last_modified_zxid mzxid],
        %w[created_time ctime],
        %w[last_modified_time mtime],
        %w[child_list_version cversion],
        %w[acl_list_version aversion] ].each do |long, short|

        class_eval <<-RUBY, __FILE__, __LINE__ + 1
          def #{long}
            #{short}
          end
        RUBY
      end
    end
  end     # Extensions
end       # ZK

ZookeeperCallbacks::Callback.extend(ZK::Extensions::Callbacks::CallbackClassExt)
ZookeeperCallbacks::WatcherCallback.send(:include, ZK::Extensions::Callbacks::WatcherCallbackExt)
ZookeeperStat::Stat.send(:include, ZK::Extensions::Stat)

