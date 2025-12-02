
    (table $func 10 funcref)
    
    (func 
        (export "add")
        (param  $source <TypedArray>)
        (param  $values <TypedArray>)
        (param  $target <TypedArray>)
        (result $promise   <Promise>)

        (call $calc global($OP_ADD) local($source) local($values) local($target))
    )

    (func $calc
        (param $func_index       i32)
        (param $source  <TypedArray>)
        (param $values  <TypedArray>)
        (param $target  <TypedArray>)
        (result $promise   <Promise>)
        
        (local $waitAsync ref)
        (local $buffer_len i32)
        (local $source_ptr i32)
        (local $values_ptr i32)
        (local $target_ptr i32)

        (local.set $buffer_len $get_used_bytes<ref>i32(local($target)))
        (local.set $source_ptr $get_byteoffset<ref>i32(local($source)))
        (local.set $values_ptr $get_byteoffset<ref>i32(local($values)))
        (local.set $target_ptr $get_byteoffset<ref>i32(local($target)))

        (call $set_func_index<i32> local($func_index))
        (call $set_buffer_len<i32> local($buffer_len))
        (call $set_source_ptr<i32> local($source_ptr))
        (call $set_values_ptr<i32> local($values_ptr))
        (call $set_target_ptr<i32> local($target_ptr))

        (local.set $waitAsync
            (call $self.Atomics.waitAsync<ref.i32.i32>ref
                global($i32View)
                global($INDEX_WINDOW_MUTEX)
                i32(0)
            )
        )

        (call $self.Atomics.store<ref.i32.i32>
            global($i32View)
            global($INDEX_WORKER_MUTEX)
            i32(1)
        )

        (call $set_active_workers<i32>
            (call $self.Atomics.notify<ref.i32.i32>i32
                global($i32View)
                global($INDEX_WORKER_MUTEX)
                i32(1)
            )
        )

        $self.Reflect.get<ref.ref>ref(
            local($waitAsync) text('value')
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
                    $self.Reflect.get<ref.ref>i32(
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
            (call $malloc<i32>i32 
                local($byteLength)
            )
        )

        (call $set_array_type<i32.i32>
            local($offset) 
            $self.Reflect.get<ref.ref>i32(
                local($constructor) 
                global($symbol)
            )
        )

        (call $set_item_count<i32.i32>
            local($offset) 
            local($length)
        )

        (local.set $arguments 
            new($self.Array<>ref)
        )

        (apply $self.Array:push<ref> local($arguments) (param global($buffer)))
        (apply $self.Array:push<i32> local($arguments) (param local($offset)))
        (apply $self.Array:push<i32> local($arguments) (param local($length)))

        $self.Reflect.construct<ref.ref>ref(
            local($constructor)
            local($arguments)
        )
    )
