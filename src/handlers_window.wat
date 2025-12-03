
    (table $func 30 funcref)

    (type $arg3     
        (func 
            (param $source externref) 
            (param $values externref) 
            (param $target externref) 
            (result $promise <Promise>)
        )
    )

    (type $arg2     
        (func 
            (param $source externref) 
            (param $target externref) 
            (result $promise <Promise>)
        )
    )
    
    (func $add      (export "add")     (type $arg3) (call $calc global($OP_ADD)     local(0) local(1) local(2)))
    (func $sub      (export "sub")     (type $arg3) (call $calc global($OP_SUB)     local(0) local(1) local(2)))
    (func $mul      (export "mul")     (type $arg3) (call $calc global($OP_MUL)     local(0) local(1) local(2)))
    (func $div      (export "div")     (type $arg3) (call $calc global($OP_DIV)     local(0) local(1) local(2)))
    (func $max      (export "max")     (type $arg3) (call $calc global($OP_MAX)     local(0) local(1) local(2)))
    (func $min      (export "min")     (type $arg3) (call $calc global($OP_MIN)     local(0) local(1) local(2)))
    (func $eq       (export "eq")      (type $arg3) (call $calc global($OP_EQ)      local(0) local(1) local(2)))
    (func $ne       (export "ne")      (type $arg3) (call $calc global($OP_NE)      local(0) local(1) local(2)))
    (func $lt       (export "lt")      (type $arg3) (call $calc global($OP_LT)      local(0) local(1) local(2)))
    (func $gt       (export "gt")      (type $arg3) (call $calc global($OP_GT)      local(0) local(1) local(2)))
    (func $le       (export "le")      (type $arg3) (call $calc global($OP_LE)      local(0) local(1) local(2)))
    (func $ge       (export "ge")      (type $arg3) (call $calc global($OP_GE)      local(0) local(1) local(2)))
    (func $floor    (export "floor")   (type $arg2) (call $calc global($OP_FLOOR)   local(0)     null local(1)))
    (func $trunc    (export "trunc")   (type $arg2) (call $calc global($OP_TRUNC)   local(0)     null local(1)))
    (func $ceil     (export "ceil")    (type $arg2) (call $calc global($OP_CEIL)    local(0)     null local(1)))
    (func $nearest  (export "nearest") (type $arg2) (call $calc global($OP_NEAREST) local(0)     null local(1)))
    (func $sqrt     (export "sqrt")    (type $arg2) (call $calc global($OP_SQRT)    local(0)     null local(1)))
    (func $abs      (export "abs")     (type $arg2) (call $calc global($OP_ABS)     local(0)     null local(1)))
    (func $neg      (export "neg")     (type $arg2) (call $calc global($OP_NEG)     local(0)     null local(1)))
    (func $and      (export "and")     (type $arg3) (call $calc global($OP_AND)     local(0) local(1) local(2)))
    (func $or       (export "or")      (type $arg3) (call $calc global($OP_OR)      local(0) local(1) local(2)))
    (func $xor      (export "xor")     (type $arg3) (call $calc global($OP_XOR)     local(0) local(1) local(2)))
    (func $not      (export "not")     (type $arg3) (call $calc global($OP_NOT)     local(0) local(1) local(2)))
    (func $shl      (export "shl")     (type $arg3) (call $calc global($OP_SHL)     local(0) local(1) local(2)))
    (func $shr      (export "shr")     (type $arg3) (call $calc global($OP_SHR)     local(0) local(1) local(2)))

    (global $target/userView mut extern)
    (global $target/mallocView mut extern)
    (global $target/needsUpdate mut i32)

    (func $import
        (param  $userView ref)
        (param  $sourceView ref)
        (param  $isntTarget i32)
        (result $view ref)
        
        (local  $mallocView ref)
        (local  $isNotArray i32)
        (local  $hasSrcView i32)
        (local  $byteOffset i32)

        (local.set $isNotArray (i32.eqz (call $self.ArrayBuffer.isView<ref>i32 local($userView))))
        (local.set $hasSrcView (i32.eqz (ref.is_null local($sourceView))))

        (if (local.get $hasSrcView)
            (; target or values checking ;)
            (then
                (if (local.get $isntTarget)
                    (; values view check -- same buffer with zero length of source ;)
                    (then
                        (if (local.get $isNotArray)
                            (then 
                                (local.set $userView 
                                    (apply $self.TypedArray:subarray<i32x2>ref
                                        local($sourceView) (param i32(0) i32(0))
                                    )
                                )
                            )
                        )
                    )
                    (; target view check -- no clone needed make it source ;)
                    (else
                        (if (local.get $isNotArray)
                            (then 
                                (local.set $userView local($sourceView))
                            )
                        )
                    )
                )
            )
            (; source is checking ;)
            (else (if (local.get $isNotArray) (then unreachable)))
        )

        (if (call $self.Object.is<ref.ref>i32
                local($userView).buffer global($buffer) 
            )
            (then
                (return local($userView))
            )
        )

        (local.set $mallocView
            (call $new
                local($userView).constructor
                local($userView).length
            )
        )

        (if (local.get $isntTarget)
            (then
                (apply $self.TypedArray:set<ref>
                    local($mallocView) 
                    (param
                        local($userView)
                    )
                )
            )
            (else
                (global.set $target/userView local($userView))
                (global.set $target/mallocView local($mallocView))
                (global.set $target/needsUpdate true)
            )
        )

        local($mallocView)
    )

    (func $is_mixed_space<i32.i32.i32>i32
        (param  $type_space          i32)
        (param  $source_ptr          i32)
        (param  $values_ptr          i32)
        (result i32)

        (if (i32.ne local($type_space) (call $get_array_type<i32>i32 local($source_ptr)))
            (then (return true))
        )

        (if local($values_ptr)
            (then
                (return (i32.ne local($type_space) (call $get_array_type<i32>i32 local($values_ptr))))
            )
        )

        (return false)
    )

    (func $find_variant_code<i32.i32>i32
        (param  $write_length       i32)
        (param  $read_length        i32)
        (result i32)

        (if (0 === local($read_length))
            (then (return global($VARIANT_0)))
        )

        (if (1 === local($read_length))
            (then (return global($VARIANT_1)))
        )

        (if (i32.eq local($read_length) local($write_length))
            (then (return global($VARIANT_N)))
        )

        (if (i32.eq local($read_length) (i32.div_u local($write_length) i32(2)))
            (then (return global($VARIANT_H)))
        )

        (if (i32.eq local($read_length) (i32.div_u local($write_length) i32(4)))
            (then (return global($VARIANT_Q)))
        )

        unreachable
    )

    (func $find_func_index<i32.i32.i32.i32.i32>i32
        (param  $opcode               i32)
        (param  $buffer_len           i32)
        (param  $source_ptr           i32)
        (param  $values_ptr           i32)
        (param  $target_ptr           i32)
        (result i32)

        (local  $values_len           i32)
        (local  $type_space           i32)
        (local  $is_mixed_space       i32)
        (local  $variant_code         i32)
        (local  $func_index           i32)

        (local.set $type_space
            (call $get_array_type<i32>i32 local($target_ptr))
        )

        (local.set $is_mixed_space  
            (call $is_mixed_space<i32.i32.i32>i32 
                local($type_space) 
                local($source_ptr)
                local($values_ptr)
            )
        )

        (if local($values_ptr)
            (then
                (local.set $values_len
                    (call $get_used_bytes<i32>i32 
                        local($values_ptr)
                    )
                )

                (local.set $variant_code  
                    (call $find_variant_code<i32.i32>i32 
                        local($buffer_len)
                        local($values_len)
                    )
                )
            )
            (else
                (local.set $variant_code
                    global($VARIANT_0)
                )   
            )
        )

        
        (local.set $func_index
            (call $fni local($opcode) local($type_space) local($variant_code))
        )

        local($func_index)
    )

    (global $isBusy mut i32)

    (func $calc
        (param  $opcode               i32)
        (param  $source      <TypedArray>)
        (param  $values      <TypedArray>)
        (param  $target      <TypedArray>)
        (result $promise        <Promise>)
        
        (local  $source_ptr           i32)
        (local  $values_ptr           i32)
        (local  $target_ptr           i32)
        (local  $buffer_len           i32)
        (local  $func_index           i32)

        (if global($isBusy) (then 
            (error<ref> (new $self.Error<ref>ref text('CPU is busy')))
            (unreachable)
        ))

        (global.set $isBusy true)

        (local.set $source      (call $import local($source) null true))
        (local.set $target      (call $import local($target) local($source) false))

        (local.set $source_ptr  local($source).byteOffset)
        (local.set $target_ptr  local($target).byteOffset)

        (if (i32.eqz (ref.is_null local($values)))
            (then
                (local.set $values      (call $import local($values) local($source) true))
                (local.set $values_ptr  local($values).byteOffset)
            )
        )

        (local.set $buffer_len
            (call $get_used_bytes<ref>i32 
                local($target)
            )
        )

        (local.set $func_index
            (call $find_func_index<i32.i32.i32.i32.i32>i32
                local($opcode)
                local($buffer_len)
                local($source_ptr)
                local($values_ptr)
                local($target_ptr)
            )
        )
                
        (call $set_func_index<i32> local($func_index))
        (call $set_buffer_len<i32> local($buffer_len))
        (call $set_source_ptr<i32> local($source_ptr))
        (call $set_values_ptr<i32> local($values_ptr))
        (call $set_target_ptr<i32> local($target_ptr))

        (if (i32.eq global($READY_STATE_OPEN)
                (call $get_ready_state<>i32)
            ) 
            (then
                (call $set_active_workers<i32>
                    (call $notify_worker_mutex<>i32)
                )
            )
        )

        (apply $self.Promise.prototype.then<fun>ref
            (call $create_wait_promise<>ref)
            (param func($ontaskcomplete<>))
        )
    )

    (func $ontaskcomplete<>
        (global.set $isBusy false)
    
        (if global($target/needsUpdate)
            (then
                (apply $self.TypedArray:set<ref>
                    global($target/userView)
                    (param global($target/mallocView))
                )

                (global.set $target/userView null)
                (global.set $target/mallocView null)
                (global.set $target/needsUpdate false)
            )
        )
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

    (func $new
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
                    local($constructor).BYTES_PER_ELEMENT
                )
            )
            (then (local.set $BYTES_PER_ELEMENT i32(1)))
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
            (new $self.Array<>ref)
        )

        (apply $self.Array:push<ref> local($arguments) (param (call $get_buffer<>ref)))
        (apply $self.Array:push<i32> local($arguments) (param local($offset)))
        (apply $self.Array:push<i32> local($arguments) (param local($length)))

        (call $self.Reflect.construct<ref.ref>ref
            local($constructor)
            local($arguments)
        )
    )
