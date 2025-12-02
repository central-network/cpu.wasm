
    (func $get_worker_count<>i32
        (result $value i32)
        (i32.atomic.load global($OFFSET_WORKER_COUNT))
    )

    (func $new_worker_index<>i32
        (result $value i32)
        (i32.atomic.rmw.add global($OFFSET_ACTIVE_WORKERS) i32(1))
    )

    (func $get_active_workers<>i32
        (result $value i32)
        (i32.atomic.load global($OFFSET_ACTIVE_WORKERS))
    )

    (func $get_ready_state<>i32
        (result $value i32)
        (i32.atomic.load global($OFFSET_READY_STATE))
    )
