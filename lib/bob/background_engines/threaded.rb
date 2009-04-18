require 'thread'
module Bob
  module BackgroundEngines
    class Threaded

      def initialize(pool_size = 2)
        @pool = ThreadPool.new(pool_size)
      end

      def call(job)
        @pool << job
      end

      def njobs
        @pool.njobs
      end

      def wait!
        Thread.pass until @pool.njobs == 0
      end

      class ThreadPool
        class Incrementor
          def initialize(v = 0)
            @m = Mutex.new
            @v = v
          end
          def inc(v = 1)
            sync { @v += v }
          end
          def dec(v = 1)
            sync { @v -= v }
          end
          def inspect
            @v.inspect
          end
          def to_i
            @v
          end
          private
          def sync(&b)
            @m.synchronize &b
          end
        end

        attr_reader :size, :jobs
        def size=(other)
          @size = other
          if @workers.size > @size
            (@workers.size - @size).times do
              @workers.shift[:run] = false
            end
          else
            (@size - @workers.size).times do
              @workers << spawn
            end
          end
        end

        def initialize(size = nil)
          size ||= 2
          @jobs = Queue.new
          @njobs = Incrementor.new
          @workers = Array.new(size) { spawn }
        end

        def add(*jobs, &blk)
          jobs = jobs + Array(blk)
          jobs.each do |job|
            @jobs << job
            @njobs.inc
          end
        end
        alias push add
        alias :<< add

        def njobs
          @njobs.to_i
        end

        private
        def spawn
          Thread.new do
            c = Thread.current
            c[:run] = true
            while c[:run]
              @jobs.pop.call
              @njobs.dec
            end
          end
        end
      end
    end
  end
end