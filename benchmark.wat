(module 
    (import "self" "local_memory" (memory $memory/local 1000 65535))
    (import "self" "shared_memory" (memory $memory/shared 1000 65535 shared))
    (import "self" "worker_index" (global $worker_index i32))

    (global $TOTAL_BYTES i32 (i32.const 65536000))

    ;; ============================================================================
    ;; BENCHMARK: OPTIMIZED SIMD on SHARED memory - ONLY ADD
    ;; ============================================================================
    (func $benchmark_shared (export "benchmark_shared")
        (local $task_vector v128)
        (local $adding_value v128)
        (local $loop_iterator v128)
        
        (local.set $task_vector (v128.const i32x4 65536000 0 0 0))
        (local.set $loop_iterator (v128.const i32x4 -16 16 16 16))
        (local.set $adding_value (f32x4.splat (f32.const 1.00001)))

        (loop $main
            (if (i32x4.extract_lane 0 (local.get $task_vector))
                (then
                    (v128.store $memory/shared
                        (i32x4.extract_lane 3 (local.get $task_vector))
                        (f32x4.add 
                            (v128.load $memory/shared (i32x4.extract_lane 1 (local.get $task_vector)))
                            (local.get $adding_value)
                        )
                    )
                    
                    (local.set $task_vector 
                        (i32x4.add (local.get $task_vector) (local.get $loop_iterator))
                    )
                    (br $main)
                )
            )
        )
    )

    ;; ============================================================================
    ;; BENCHMARK: SIMPLE i32 counter SIMD on SHARED memory
    ;; ============================================================================
    (func $benchmark_shared_simple (export "benchmark_shared_simple")
        (local $ptr i32)
        (local $end i32)
        (local $adding_value v128)
        
        (local.set $ptr (i32.const 0))
        (local.set $end (global.get $TOTAL_BYTES))
        (local.set $adding_value (f32x4.splat (f32.const 1.00001)))

        (loop $main
            (v128.store $memory/shared
                (local.get $ptr)
                (f32x4.add 
                    (v128.load $memory/shared (local.get $ptr))
                    (local.get $adding_value)
                )
            )
            
            (local.set $ptr (i32.add (local.get $ptr) (i32.const 16)))
            (br_if $main (i32.lt_u (local.get $ptr) (local.get $end)))
        )
    )

    ;; ============================================================================
    ;; BENCHMARK: OPTIMIZED SIMD on LOCAL, then COPY - ONLY ADD
    ;; ============================================================================
    (func $benchmark_local_then_copy (export "benchmark_local_then_copy")
        (local $task_vector v128)
        (local $adding_value v128)
        (local $loop_iterator v128)
        
        (local.set $task_vector (v128.const i32x4 65536000 0 0 0))
        (local.set $loop_iterator (v128.const i32x4 -16 16 16 16))
        (local.set $adding_value (f32x4.splat (f32.const 1.00001)))

        (loop $main
            (if (i32x4.extract_lane 0 (local.get $task_vector))
                (then
                    (v128.store $memory/local
                        (i32x4.extract_lane 3 (local.get $task_vector))
                        (f32x4.add 
                            (v128.load $memory/local (i32x4.extract_lane 1 (local.get $task_vector)))
                            (local.get $adding_value)
                        )
                    )
                    
                    (local.set $task_vector 
                        (i32x4.add (local.get $task_vector) (local.get $loop_iterator))
                    )
                    (br $main)
                )
            )
        )
        
        (memory.copy $memory/shared $memory/local 
            (i32.const 0)
            (i32.const 0)
            (global.get $TOTAL_BYTES)
        )
    )

    ;; ============================================================================
    ;; BENCHMARK 3: READ from LOCAL, WRITE to SHARED (no copy)
    ;; ============================================================================
    (func $benchmark_local_read_shared_write (export "benchmark_local_read_shared_write")
        (local $task_vector v128)
        (local $adding_value v128)
        (local $loop_iterator v128)
        
        (local.set $task_vector (v128.const i32x4 65536000 0 0 0))
        (local.set $loop_iterator (v128.const i32x4 -16 16 16 16))
        (local.set $adding_value (f32x4.splat (f32.const 1.00001)))

        (loop $main
            (if (i32x4.extract_lane 0 (local.get $task_vector))
                (then
                    ;; READ from LOCAL, WRITE to SHARED
                    (v128.store $memory/shared
                        (i32x4.extract_lane 3 (local.get $task_vector))
                        (f32x4.add 
                            (v128.load $memory/local (i32x4.extract_lane 1 (local.get $task_vector)))
                            (local.get $adding_value)
                        )
                    )
                    
                    (local.set $task_vector 
                        (i32x4.add (local.get $task_vector) (local.get $loop_iterator))
                    )
                    (br $main)
                )
            )
        )
    )
)