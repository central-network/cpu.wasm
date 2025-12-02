
    (table $func 10 funcref)
    
    (func $add
        (export "add")
        (param  $source <TypedArray>)
        (param  $values <TypedArray>)
        (param  $target <TypedArray>)
        (result $promise   <Promise>)

        (call $calc global($OP_ADD) local($source) local($values) local($target))
    )

    (func $calc
        (param  $func_index           i32)
        (param  $source      <TypedArray>)
        (param  $values      <TypedArray>)
        (param  $target      <TypedArray>)
        (result $promise        <Promise>)
        (local  $promise        <Promise>)

        (call $set_func_index<i32> local($func_index))        
        (call $set_buffer_len<i32> $get_used_bytes<ref>i32(local($target)))
        (call $set_source_ptr<i32> $get_byteoffset<ref>i32(local($source)))
        (call $set_values_ptr<i32> $get_byteoffset<ref>i32(local($values)))
        (call $set_target_ptr<i32> $get_byteoffset<ref>i32(local($target)))

        (local.set $promise 
            (call $create_wait_promise<>ref)
        )

        (if (i32.eq $get_ready_state<>i32()
                global($READY_STATE_OPEN)
            ) 
            (then
                (call $set_active_workers<i32>
                    (call $notify_worker_mutex<>i32)
                )
            )
        )

        local($promise)
    )

    (func $notify_worker_mutex<>i32
        (result $notifiedWorkerCount i32)

        (call $self.Atomics.notify<ref.i32.i32>i32
            global($i32View) 
            global($INDEX_WORKER_MUTEX)
            (call $get_worker_count<>i32)
        )
    )

    (func $create_wait_promise<>ref
        (result ref)

        (call $self.Reflect.get<ref.ref>ref
            (call $self.Atomics.waitAsync<ref.i32.i32>ref
                global($i32View) 
                global($INDEX_WINDOW_MUTEX) 
                false
            )
            text('value')
        )
    )

    (func 
        (export "new")
        (param  $constructor    <Object>)
        (param  $length              i32)
        (result $typedArray <TypedArray>)

        (local  $offset              i32)
        (local  $byteLength          i32)
        (local  $BYTES_PER_ELEMENT   i32)
        (local  $arguments       <Array>)

        (if (i32.eqz
                (local.tee $BYTES_PER_ELEMENT 
                    (call $self.Reflect.get<ref.ref>i32
                        local($constructor)
                        text('BYTES_PER_ELEMENT')
                    )
                )
            )
            (then
                (local.set $BYTES_PER_ELEMENT i32(1))
            )
        )
        
        (local.set $byteLength 
            (i32.mul 
                local($length) 
                local($BYTES_PER_ELEMENT)
            )
        )

        (local.set $offset 
            (call $malloc
                local($byteLength)
            )
        )

        (call $set_array_type<i32.i32>
            local($offset) 
            (call $self.Reflect.get<ref.ref>i32
                local($constructor) 
                (call $get_self_symbol<>ref)
            )
        )

        (call $set_item_count<i32.i32>
            local($offset) 
            local($length)
        )

        (local.set $arguments 
            new($self.Array<>ref)
        )

        (apply $self.Array:push<ref> local($arguments) (param (call $get_buffer<>ref)))
        (apply $self.Array:push<i32> local($arguments) (param local($offset)))
        (apply $self.Array:push<i32> local($arguments) (param local($length)))

        $self.Reflect.construct<ref.ref>ref(
            local($constructor)
            local($arguments)
        )
    )
