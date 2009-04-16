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
        t = Thread
        t.pass until @pool.njobs == 0
      end

      class ThreadPool
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
          @workers = Array.new(size) { spawn }
        end

        def add(*jobs, &blk)
          (jobs + Array(blk)).each { |j| @jobs << j }
        end
        alias push add
        alias :<< add

        def njobs
          @jobs.size + @workers.select { |w| w.status == "run" }.size
        end

        private
        def spawn
          Thread.new do
            c = Thread.current
            c[:run] = true
            while c[:run]
              @jobs.pop.call
            end
          end
        end
      end
    end
  end
end