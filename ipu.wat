(module
    (memory 10 10)

    (include "const.wat")
    (include "func.wat")
    (include "memory.wat")

    (global $DEFAULT_MEMORY_INITIAL i32 i32(10))
    (global $DEFAULT_MEMORY_MAXIMUM i32 i32(65536))
    (global $DEFAULT_MEMORY_SHARED  i32 true)

    (global $memory mut extern)
    (global $buffer mut extern)
    (global $symbol mut extern)

    (global $i32View mut extern)
    (global $dataView mut extern)
    (global $workerURL mut extern)
    (global $workerScript 'onmessage = e => {
        const view = new Int32Array(e.data[1])
        Atomics.wait(view, 10, 1)
        setTimeout( () => {
            Atomics.store(view, 11, 1)
            Atomics.notify(view, 11, 1)
        }, 3200 )
    }')

    (global $self.DataView      externref)
    (global $self.Uint8Array    externref)
    (global $self.Uint16Array   externref)
    (global $self.Uint32Array   externref)
    (global $self.Float32Array  externref)
    
    (global $self.navigator.deviceMemory        i32)
    (global $self.navigator.hardwareConcurrency i32)

    (start $main
        (global.set $symbol 
            (call $self.Symbol<ref>ref 
                text('kArrayType')
            )
        )

        (global.set $memory
            $createMemory<i32.i32.i32>ref(
                global($DEFAULT_MEMORY_INITIAL)
                global($DEFAULT_MEMORY_MAXIMUM)
                global($DEFAULT_MEMORY_SHARED)
            )
        )

        (global.set $buffer
            $self.Reflect.get<ref.ref>ref(
                global($memory)
                text('buffer')
            )        
        )

        (global.set $i32View
            (new $self.Int32Array<ref>ref
                global($buffer)
            )
        )

        (global.set $dataView
            (new $self.DataView<ref>ref
                global($buffer)
            )
        )

        (call $set_zero<i32>            i32(0))
        (call $set_heap_ptr<i32>        global($HEAP_START))
        (call $set_capacity<i32>        (i32.mul global($DEFAULT_MEMORY_INITIAL) i32(65536)))
        (call $set_maxlength<i32>       (i32.mul global($DEFAULT_MEMORY_MAXIMUM) i32(65536)))

        (call $set_concurrency<i32>     global($self.navigator.hardwareConcurrency))
        (call $set_worker_count<i32>    $get_concurrency<>i32())
        (call $set_active_workers<i32>  i32(0))
        (call $set_locked_workers<i32>  i32(0))

        (call $set_func_index<i32>      i32(0))
        (call $set_stride<i32>          (i32.mul $get_worker_count<>i32() i32(16)))
        (call $set_worker_mutex<i32>    i32(0))
        (call $set_window_mutex<i32>    i32(0))

        (call $set_buffer_len<i32>      i32(0))
        (call $set_source_ptr<i32>      i32(0))
        (call $set_values_ptr<i32>      i32(0))
        (call $set_target_ptr<i32>      i32(0))

        (call $defineProperty<ref.ref.i32> global($self.Uint8Array)   global($symbol) global($TYPE_UINT8ARRAY))
        (call $defineProperty<ref.ref.i32> global($self.Uint16Array)  global($symbol) global($TYPE_UINT16ARRAY))
        (call $defineProperty<ref.ref.i32> global($self.Uint32Array)  global($symbol) global($TYPE_UINT32ARRAY))
        (call $defineProperty<ref.ref.i32> global($self.Float32Array) global($symbol) global($TYPE_FLOAT32ARRAY))

        (call $defineProperty<ref.ref.i32> global($self.DataView)     global($symbol) global($TYPE_DATAVIEW))

        (global.set $workerURL
            (call $self.URL.createObjectURL<ref>ref
                (new $self.Blob<ref>ref
                    (call $self.Array.of<ref>ref
                        global($workerScript)
                    )
                )
            )
        )

        $fork()
    )

    (func $defineProperty<ref.ref.i32>
        (param $ref ref)
        (param $key ref)
        (param $val i32)
        
        $self.Reflect.defineProperty<ref.ref.ref>(
            local($ref) 
            local($key)
            $self.Object.fromEntries<ref>ref(
                $self.Array.of<ref>ref(
                    $self.Array.of<ref.i32>ref(
                        text('value') local($val)
                    )
                )
            )
        )
    )

    (include "headers_dw.wat")

    (func $fork
        (local $worker <Worker>)
        
        (local.set $worker
            (new $self.Worker<ref>ref
                global($workerURL)
            )
        )

        (apply $self.Worker:postMessage<ref>
            local($worker)
            (param 
                $self.Array.of<ref.ref>ref(
                    global($memory)
                    global($buffer)
                )
            )
        )

        (log<ref> this)
    )
)   