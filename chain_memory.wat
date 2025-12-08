(module 
    (import "window" "memory" (memory $memory/window<i32> 10 65535 shared))
    (import "worker" "memory" (memory $memory/worker<i32> 10 65535))
    (import "window" "memory" (memory $memory/window<i64> i64 10 65535 shared))
    (import "worker" "memory" (memory $memory/worker<i64> i64 10 65535))

    (func $test    
        (call $memory.copy/window->worker<i32.i32.i32> (i32.const 0) (i32.const 0) (i32.const 10))
        (call $memory.copy/window->worker<i64.i64.i64> (i64.const 0) (i64.const 0) (i64.const 10))
        (call $memory.copy/window->worker<i64.i32.i32> (i64.const 0) (i32.const 0) (i32.const 10))
        (call $memory.copy/window->worker<i32.i64.i32> (i32.const 0) (i64.const 0) (i32.const 10))
    )

    (func $memory.copy/window->worker<i32.i32.i32>
        (param $offset/target i32)
        (param $offset/source i32)
        (param $length i32)

        (memory.copy $memory/worker<i32> $memory/window<i32> 
            (local.get $offset/target) 
            (local.get $offset/source) 
            (local.get $length)
        )
    )

    (func $memory.copy/window->worker<i32.i64.i32>
        (param $offset/target i32)
        (param $offset/source i64)
        (param $length i32)

        (memory.copy $memory/worker<i32> $memory/window<i64> 
            (local.get $offset/target) 
            (local.get $offset/source) 
            (local.get $length)
        )
    )

    (func $memory.copy/worker->window<i32.i32.i32>
        (param $offset/target i32)
        (param $offset/source i32)
        (param $length i32)

        (memory.copy $memory/window<i32> $memory/worker<i32> 
            (local.get $offset/target) 
            (local.get $offset/source) 
            (local.get $length)
        )
    )

    (func $memory.copy/window->worker<i64.i32.i32>
        (param $offset/target i64)
        (param $offset/source i32)
        (param $length i32)

        (memory.copy $memory/worker<i64> $memory/window<i32> 
            (local.get $offset/target) 
            (local.get $offset/source) 
            (local.get $length)
        )
    )

    (func $memory.copy/worker->window<i32.i64.i32>
        (param $offset/target i32)
        (param $offset/source i64)
        (param $length i32)

        (memory.copy $memory/window<i32> $memory/worker<i64> 
            (local.get $offset/target) 
            (local.get $offset/source) 
            (local.get $length)
        )
    )

    (func $memory.copy/window->worker<i64.i64.i64>
        (param $offset/target i64)
        (param $offset/source i64)
        (param $length i64)

        (memory.copy $memory/worker<i64> $memory/window<i64> 
            (local.get $offset/target) 
            (local.get $offset/source) 
            (local.get $length)
        )
    )

    (func $memory.copy/worker->window<i64.i64.i64>
        (param $offset/target i64)
        (param $offset/source i64)
        (param $length i64)

        (memory.copy $memory/window<i64> $memory/worker<i64> 
            (local.get $offset/target) 
            (local.get $offset/source) 
            (local.get $length)
        )
    )

    (func $memory.copy/window->worker<i64.i64.i32>
        (param $offset/target i64)
        (param $offset/source i64)
        (param $length i32)

        (call $memory.copy/window->worker<i64.i64.i64>
            (local.get $offset/target) 
            (local.get $offset/source) 
            (i64.extend_i32_u (local.get $length))
        )
    )

    (func $memory.copy/worker->window<i64.i64.i32>
        (param $offset/target i64)
        (param $offset/source i64)
        (param $length i32)

        (call $memory.copy/worker->window<i64.i64.i64> 
            (local.get $offset/target) 
            (local.get $offset/source) 
            (i64.extend_i32_u (local.get $length))
        )
    )    
)