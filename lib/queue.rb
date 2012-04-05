class TQueue
    @@queue = Array.new

    def push(task_args)
        if task_args != nil
            @@queue.unshift(task_args)
        end
    end

    def pull()
        task_current = @@queue[-1]
        @@queue.delete_at(-1)
        return task_current
    end
    
    def list()
        output = ""
        @@queue.each do |task|
            output += "#{task}"
        end
        return output
    end

    def remove(number)
        @@queue.delete_at(Integer(number))
        return @@queue.size
    end
end
