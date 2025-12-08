(module
    (import "env" "memory" (memory 10 10 shared))
    (import "env" "worker_index" (global $worker_index i32))
    (import "env" "performance_now" (func $performance_now (result f32)))

    ;; ------------------------------------------------------------------------------------------------------------
    ;; WORKER LIFECYCLE
    ;; ------------------------------------------------------------------------------------------------------------

    ;; Imported Task Logic
    (import "task" "execute_task" (func $execute_task (param i32) (result i32)))

    ;; ============================================================================================================
    ;; WORKER HEADER ARCHITECTURE
    ;; ============================================================================================================
    ;; 1 Global Header Block + 256 Individual Worker Blocks
    
    (global $WORKER_HEADER_SIZE                 i32 (i32.const 64))  ;; Size of one worker's header
    (global $GLOBAL_HEADER_SIZE                 i32 (i32.const 64))  ;; Size of the global controller header
    
    ;; Offsets
    (global $OFFSET_GLOBAL_WORKER_HEADER        i32 (i32.const 0))   ;; Starts at 0
    (global $OFFSET_INDIVIDUAL_WORKERS_START    i32 (i32.const 64))  ;; Starts after Global Header
    
    ;; ------------------------------------------------------------------------------------------------------------
    ;; GLOBAL WORKER HEADER (64 Bytes)
    ;; ------------------------------------------------------------------------------------------------------------
    ;; Allows tracking total active workers, global states, etc.
    (global $OFFSET_WORKER_MEMORY_BASE          i32 (i32.const 5120)) ;; Base Offset for Worker Module
    (global $OFFSET_GLOBAL_ACTIVE_WORKER_COUNT  i32 (i32.const 0))   ;; Relative to Base

    ;; ... Reserved for future global stats
    
    ;; ------------------------------------------------------------------------------------------------------------
    ;; INDIVIDUAL WORKER HEADER (64 Bytes per Worker)
    ;; ------------------------------------------------------------------------------------------------------------
    ;; Base = OFFSET_WORKER_MEMORY_BASE + OFFSET_INDIVIDUAL_WORKERS_START + (WorkerID * WORKER_HEADER_SIZE)
    
    (global $OFFSET_WORKER_MUTEX            i32 (i32.const 0))   ;; i32 
    (global $OFFSET_WINDOW_LAST_STATE       i32 (i32.const 4))   ;; i32
    (global $OFFSET_WORKER_LAST_STATE       i32 (i32.const 8))   ;; i32
    
    ;; Epochs (f32)
    (global $OFFSET_WINDOW_CREATE_EPOCH     i32 (i32.const 12))
    (global $OFFSET_WINDOW_DEPLOY_EPOCH     i32 (i32.const 16))
    (global $OFFSET_WINDOW_DESTROY_EPOCH    i32 (i32.const 20))
    (global $OFFSET_WINDOW_CLOSE_EPOCH      i32 (i32.const 24))
    
    (global $OFFSET_WORKER_CREATE_EPOCH     i32 (i32.const 28))
    (global $OFFSET_WORKER_DEPLOY_EPOCH     i32 (i32.const 32))
    (global $OFFSET_WORKER_DESTROY_EPOCH    i32 (i32.const 36))
    (global $OFFSET_WORKER_CLOSE_EPOCH      i32 (i32.const 40))

    ;; Reserved: 44..63

    ;; ------------------------------------------------------------------------------------------------------------
    ;; STATE CONSTANTS
    ;; ------------------------------------------------------------------------------------------------------------
    
    ;; Window-Side States (Commands/Status from Creator)
    (global $WINDOW_STATE_INITIALIZING      i32 (i32.const 0))
    (global $WINDOW_STATE_CREATED           i32 (i32.const 1))
    (global $WINDOW_STATE_REQUEST_CLOSE     i32 (i32.const 2))
    (global $WINDOW_STATE_CLOSED            i32 (i32.const 3))

    ;; Worker-Side States (Status from Worker)
    (global $WORKER_STATE_STARTED           i32 (i32.const 0))
    (global $WORKER_STATE_WORKING           i32 (i32.const 1))
    (global $WORKER_STATE_LOCKED            i32 (i32.const 2))
    (global $WORKER_STATE_CLOSING           i32 (i32.const 3))
    (global $WORKER_STATE_ERROR             i32 (i32.const 4))
    
    ;; ------------------------------------------------------------------------------------------------------------
    ;; ACCESSORS
    ;; ------------------------------------------------------------------------------------------------------------
    
    ;; Full accessor (takes worker_id as param)
    (func $get_worker_offset<i32>i32
        (param $worker_id i32)
        (result i32)
        (i32.add
            (global.get $OFFSET_WORKER_MEMORY_BASE)
            (i32.add
                (global.get $OFFSET_INDIVIDUAL_WORKERS_START)
                (i32.mul
                    (local.get $worker_id)
                    (global.get $WORKER_HEADER_SIZE)
                )
            )
        )
    )

    ;; Self accessor (uses imported $worker_index global)
    (func $my_offset (result i32)
        (i32.add
            (global.get $OFFSET_WORKER_MEMORY_BASE)
            (i32.add
                (global.get $OFFSET_INDIVIDUAL_WORKERS_START)
                (i32.mul
                    (global.get $worker_index)
                    (global.get $WORKER_HEADER_SIZE)
                )
            )
        )
    )

    ;; Simplified self-accessors (use $worker_index)
    (func $my_window_state (result i32)
        (i32.load offset=4 (call $my_offset))
    )
    
    (func $my_state (result i32)
        (i32.load offset=8 (call $my_offset))
    )
    
    (func $set_my_state (param $state i32)
        (i32.store offset=8 (call $my_offset) (local.get $state))
    )
    
    (func $set_my_deploy_epoch (param $epoch f32)
        (f32.store offset=32 (call $my_offset) (local.get $epoch))
    )
    
    (func $set_my_destroy_epoch (param $epoch f32)
        (f32.store offset=36 (call $my_offset) (local.get $epoch))
    )

    ;; ------------------------------------------------------------------------------------------------------------
    ;; MUTEX HANDLERS (i32)
    ;; ------------------------------------------------------------------------------------------------------------

    (func $get_worker_mutex<i32>i32
        (param $worker_id i32)
        (result i32)
        (i32.load offset=0 ;; OFFSET_WORKER_MUTEX
            (call $get_worker_offset<i32>i32 (local.get $worker_id))
        )
    )

    (func $set_worker_mutex<i32>
        (param $worker_id i32)
        (param $value i32)
        (i32.store offset=0 ;; OFFSET_WORKER_MUTEX
            (call $get_worker_offset<i32>i32 (local.get $worker_id))
            (local.get $value)
        )
    )

    ;; ------------------------------------------------------------------------------------------------------------
    ;; WINDOW STATE HANDLERS (i8)
    ;; ------------------------------------------------------------------------------------------------------------

    ;; ------------------------------------------------------------------------------------------------------------
    ;; WINDOW STATE HANDLERS (i32)
    ;; ------------------------------------------------------------------------------------------------------------

    (func $get_worker_window_last_state<i32>i32
        (param $worker_id i32)
        (result i32)
        (i32.load offset=4 ;; OFFSET_WINDOW_LAST_STATE (i32)
            (call $get_worker_offset<i32>i32 (local.get $worker_id))
        )
    )

    (func $set_worker_window_last_state<i32>
        (param $worker_id i32)
        (param $state i32)
        (i32.store offset=4 ;; OFFSET_WINDOW_LAST_STATE (i32)
            (call $get_worker_offset<i32>i32 (local.get $worker_id))
            (local.get $state)
        )
    )

    ;; ------------------------------------------------------------------------------------------------------------
    ;; WORKER STATE HANDLERS (i32)
    ;; ------------------------------------------------------------------------------------------------------------

    (func $get_worker_last_state<i32>i32
        (param $worker_id i32)
        (result i32)
        (i32.load offset=8 ;; OFFSET_WORKER_LAST_STATE (i32)
            (call $get_worker_offset<i32>i32 (local.get $worker_id))
        )
    )

    (func $set_worker_last_state<i32>
        (param $worker_id i32)
        (param $state i32)
        (i32.store offset=8 ;; OFFSET_WORKER_LAST_STATE (i32)
            (call $get_worker_offset<i32>i32 (local.get $worker_id))
            (local.get $state)
        )
    )

    ;; ------------------------------------------------------------------------------------------------------------
    ;; EPOCH HANDLERS (f32)
    ;; ------------------------------------------------------------------------------------------------------------

    (func $set_worker_deploy_epoch<i32>
        (param $worker_id i32)
        (param $epoch f32)
        (f32.store offset=32 ;; OFFSET_WORKER_DEPLOY_EPOCH
            (call $get_worker_offset<i32>i32 (local.get $worker_id))
            (local.get $epoch)
        )
    )

    (func $set_worker_destroy_epoch<i32>
        (param $worker_id i32)
        (param $epoch f32)
        (f32.store offset=36 ;; OFFSET_WORKER_DESTROY_EPOCH
            (call $get_worker_offset<i32>i32 (local.get $worker_id))
            (local.get $epoch)
        )
    )

    ;; ------------------------------------------------------------------------------------------------------------
    ;; CHAIN CONSTANTS (Must match chain_manager.wat)
    ;; ------------------------------------------------------------------------------------------------------------
    (global $OFFSET_TASK_STATE_BLOCK        i32 (i32.const 64))
    (global $OFFSET_TASK_HEADERS_START      i32 (i32.const 128))
    (global $TASK_HEADER_SIZE               i32 (i32.const 64))

    ;; ------------------------------------------------------------------------------------------------------------
    ;; CHAIN REGISTRY CONSTANTS (Must match chain_manager.wat)
    ;; ------------------------------------------------------------------------------------------------------------
    (global $CHAIN_REGISTRY_BASE            i32 (i32.const 4096))   ;; 0x1000
    (global $OFFSET_CHAIN_COUNT             i32 (i32.const 0))
    (global $OFFSET_CHAIN_PTRS              i32 (i32.const 4))

    ;; ------------------------------------------------------------------------------------------------------------
    ;; WORKER LIFECYCLE
    ;; ------------------------------------------------------------------------------------------------------------

    (func $start (export "start")
        ;; No parameters - uses $worker_index global for self-identification
        ;; No chain_ptr - discovers chains via registry
        
        (local $task_ptr i32)
        (local $state_block_ptr i32)
        (local $scan_vec v128)
        (local $task_index i32)
        (local $byte_offset i32)
        (local $inner_loop i32)
        (local $chain_ptr i32)
        (local $chain_index i32)
        (local $chain_count i32)
        (local $found_work i32)
        (local $worker_mutex_ptr i32)

        ;; 1. Record Deploy Epoch
        (call $set_my_deploy_epoch (call $performance_now))
        
        ;; 2. Signal STARTED
        (call $set_my_state (global.get $WORKER_STATE_STARTED))

        ;; Calculate Worker Mutex Pointer (for atomic wait)
        (local.set $worker_mutex_ptr (call $my_offset))

        ;; 3. Main Loop (Loop until Window says CLOSE)
        (loop $lifecycle
            
            ;; Reset found_work flag
            (local.set $found_work (i32.const 0))
            
            ;; Check Window State (Exit Check)
            (if (i32.eq (call $my_window_state) (global.get $WINDOW_STATE_REQUEST_CLOSE))
                (then
                    (call $set_my_state (global.get $WORKER_STATE_CLOSING))
                    (call $set_my_destroy_epoch (call $performance_now))
                    (return)
                )
            )

            ;; Get chain count from registry
            (local.set $chain_count (i32.load (global.get $CHAIN_REGISTRY_BASE)))
            
            ;; Loop through all registered chains
            (local.set $chain_index (i32.const 0))
            (block $chain_loop_done
                (loop $chain_loop
                    (br_if $chain_loop_done (i32.ge_u (local.get $chain_index) (local.get $chain_count)))
                    
                    ;; Get chain pointer
                    (local.set $chain_ptr
                        (i32.load
                            (i32.add
                                (i32.add (global.get $CHAIN_REGISTRY_BASE) (global.get $OFFSET_CHAIN_PTRS))
                                (i32.mul (local.get $chain_index) (i32.const 4))
                            )
                        )
                    )
                    
                    ;; Calculate State Block Pointer for this chain
                    (local.set $state_block_ptr 
                        (i32.add (local.get $chain_ptr) (global.get $OFFSET_TASK_STATE_BLOCK))
                    )

                    ;; ============================================================================
                    ;; v128 SCAN for this chain
                    ;; ============================================================================
                    (local.set $inner_loop (i32.const 0))
                    (block $scan_done
                        (loop $scan_vectors
                            (br_if $scan_done (i32.ge_u (local.get $inner_loop) (i32.const 4)))
                            
                            ;; Load v128 from State Block
                            (local.set $scan_vec
                                (v128.load
                                    (i32.add 
                                        (local.get $state_block_ptr) 
                                        (i32.mul (local.get $inner_loop) (i32.const 16))
                                    )
                                )
                            )
                            
                            ;; Check if any task in this vector is pending
                            (if (v128.any_true (local.get $scan_vec))
                                (then
                                    ;; Iterate through bytes to find pending tasks
                                    (local.set $byte_offset (i32.const 0))
                                    (block $find_done
                                        (loop $find_task
                                            (br_if $find_done (i32.ge_u (local.get $byte_offset) (i32.const 16)))
                                            
                                            (local.set $task_index 
                                                (i32.add 
                                                    (i32.mul (local.get $inner_loop) (i32.const 16))
                                                    (local.get $byte_offset)
                                                )
                                            )
                                            
                                            ;; Check if PENDING (1)
                                            (if (i32.eq 
                                                    (i32.load8_u 
                                                        (i32.add (local.get $state_block_ptr) (local.get $task_index))
                                                    )
                                                    (i32.const 1)
                                                )
                                                (then
                                                    ;; Atomic CAS: try to claim (1 -> 2)
                                                    (if (i32.eq
                                                            (i32.atomic.rmw8.cmpxchg_u
                                                                (i32.add (local.get $state_block_ptr) (local.get $task_index))
                                                                (i32.const 1)
                                                                (i32.const 2)
                                                            )
                                                            (i32.const 1)
                                                        )
                                                        (then
                                                            ;; CLAIMED! Execute task
                                                            (local.set $found_work (i32.const 1))
                                                            (call $set_my_state (global.get $WORKER_STATE_WORKING))
                                                            
                                                            (local.set $task_ptr
                                                                (i32.add
                                                                    (i32.add (local.get $chain_ptr) (global.get $OFFSET_TASK_HEADERS_START))
                                                                    (i32.mul (local.get $task_index) (global.get $TASK_HEADER_SIZE))
                                                                )
                                                            )
                                                            
                                                            ;; Execute
                                                            (drop (call $execute_task (local.get $task_ptr)))
                                                            
                                                            ;; Mark Done (0)
                                                            (i32.atomic.store8
                                                                (i32.add (local.get $state_block_ptr) (local.get $task_index))
                                                                (i32.const 0)
                                                            )
                                                            
                                                            ;; LOOP CHECK
                                                            (if (i32.gt_u (i32.load8_u offset=6 (local.get $task_ptr)) (i32.const 0))
                                                                (then
                                                                    (i32.store8 offset=6 (local.get $task_ptr)
                                                                        (i32.sub (i32.load8_u offset=6 (local.get $task_ptr)) (i32.const 1))
                                                                    )
                                                                    (i32.atomic.store8
                                                                        (i32.add (local.get $state_block_ptr) (local.get $task_index))
                                                                        (i32.const 1)
                                                                    )
                                                                )
                                                                (else
                                                                    ;; NEXT TASK branching
                                                                    (local.set $task_index (i32.load offset=0 (local.get $task_ptr)))
                                                                    (if (i32.ne (local.get $task_index) (i32.const -1))
                                                                        (then
                                                                            (i32.atomic.store8
                                                                                (i32.add (local.get $state_block_ptr) (local.get $task_index))
                                                                                (i32.const 1)
                                                                            )
                                                                        )
                                                                        (else
                                                                            (local.set $task_index (i32.load offset=8 (local.get $task_ptr)))
                                                                            (if (i32.ne (local.get $task_index) (i32.const -1))
                                                                                (then
                                                                                    (i32.atomic.store8
                                                                                        (i32.add (local.get $state_block_ptr) (local.get $task_index))
                                                                                        (i32.const 1)
                                                                                    )
                                                                                )
                                                                            )
                                                                        )
                                                                    )
                                                                )
                                                            )
                                                            
                                                            (call $set_my_state (global.get $WORKER_STATE_STARTED))
                                                            ;; Found work - restart main loop
                                                            (br $lifecycle)
                                                        )
                                                    )
                                                )
                                            )
                                            
                                            (local.set $byte_offset (i32.add (local.get $byte_offset) (i32.const 1)))
                                            (br $find_task)
                                        )
                                    )
                                )
                            )
                            
                            (local.set $inner_loop (i32.add (local.get $inner_loop) (i32.const 1)))
                            (br $scan_vectors)
                        )
                    )
                    ;; End v128 scan for this chain

                    (local.set $chain_index (i32.add (local.get $chain_index) (i32.const 1)))
                    (br $chain_loop)
                )
            )
            ;; End chain loop

            ;; No work found - continue loop (TODO: add atomic.wait for efficiency)
            (br $lifecycle)
        )
    )
)