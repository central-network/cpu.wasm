(module
    (import "self" "memory" (memory $memory 10 65535 shared))

    (include "shared.wat")
    (include "handlers_worker.wat")
    (include "headers_io_worker.wat")

    (global $worker_index mut i32)
    
    (start $main
        $this.init<>()

        loop $while

            $lock_worker_mutex<>()
            $run_taskop_vector<>()

            (if (0 === $--active_worker_count<>i32()) 
                (then (call $notify_window_mutex<>)))

            (br_if $while
                (i32.ne 
                    (call $get_ready_state<>i32)
                    global($READY_STATE_CLOSING)
                ) 
            )

        end

        $self.close<>()
    )

    (func $this.init<>
        (global.set $worker_index 
            (call $new_worker_index<>i32)
        )

        (if (i32.eq $get_worker_count<>i32()
                global($worker_index)++
            )
            (then (call $notify_window_mutex<>))
        )
    )

    (func $run_taskop_vector<>
    
    )

    (func $lock_worker_mutex<>
        (if (memory.atomic.wait32 global($OFFSET_WORKER_MUTEX) false forever)
            (then (error<ref> text('Window mutex lock returned value!')))
        )
    )

    (func $--active_worker_count<>i32
        (result i32)
        (i32.sub (i32.atomic.rmw.sub global($OFFSET_ACTIVE_WORKERS) i32(1)) i32(1))
    )

    (func $notify_window_mutex<>
        (if (memory.atomic.notify global($OFFSET_WINDOW_MUTEX) true)
            (then return)
        )

        (error<ref> text('Window notification failed!'))
        (unreachable)
    )

)