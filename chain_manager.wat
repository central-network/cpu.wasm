(module
    (import "env" "memory" (memory 10 10 shared))

    ;; ============================================================================================================
    ;; CHAIN MANAGER (chain_manager.wat)
    ;; ============================================================================================================
    ;; Manages the 4224-byte Chain Block Structure.
    ;; - Chain Header (64 bytes)
    ;; - Task State Block (64 bytes)
    ;; - Task Headers (64 * 64 bytes = 4096 bytes)

    ;; ------------------------------------------------------------------------------------------------------------
    ;; CONSTANTS
    ;; ------------------------------------------------------------------------------------------------------------
    
    ;; Offsets (Relative to Chain Block Base)
    (global $OFFSET_CHAIN_HEADER            i32 (i32.const 0))
    (global $OFFSET_TASK_STATE_BLOCK        i32 (i32.const 64))
    (global $OFFSET_TASK_HEADERS_START      i32 (i32.const 128))

    ;; Sizes
    (global $CHAIN_HEADER_SIZE              i32 (i32.const 64))
    (global $TASK_STATE_BLOCK_SIZE          i32 (i32.const 64))
    (global $TASK_HEADER_SIZE               i32 (i32.const 64))
    (global $TOTAL_TASKS                    i32 (i32.const 64))

    (global $OFFSET_TASK_NEXT_INDEX         i32 (i32.const 0))
    (global $OFFSET_TASK_ID                 i32 (i32.const 0)) ;; Alias if needed, but we use index now
    (global $OFFSET_TASK_ATOMIC_COUNTER     i32 (i32.const 4))

    ;; ------------------------------------------------------------------------------------------------------------
    ;; CHAIN REGISTRY (Global at offset 0x1000 = 4096)
    ;; ------------------------------------------------------------------------------------------------------------
    ;; Tracks all allocated chains so workers can discover them.
    ;; Structure:
    ;; - [0x00] CHAIN_COUNT (i32): Number of registered chains
    ;; - [0x04] CHAIN_PTRS[16] (i32 array): Pointers to chain blocks

    (global $CHAIN_REGISTRY_BASE            i32 (i32.const 4096))   ;; 0x1000
    (global $CHAIN_REGISTRY_MAX             i32 (i32.const 16))     ;; Max chains
    (global $OFFSET_CHAIN_COUNT             i32 (i32.const 0))
    (global $OFFSET_CHAIN_PTRS              i32 (i32.const 4))

    ;; ------------------------------------------------------------------------------------------------------------
    ;; CHAIN REGISTRY FUNCTIONS
    ;; ------------------------------------------------------------------------------------------------------------

    ;; Get number of registered chains
    (func $get_chain_count (export "get_chain_count")
        (result i32)
        (i32.load (global.get $CHAIN_REGISTRY_BASE))
    )

    ;; Get chain pointer at index
    (func $get_chain_ptr (export "get_chain_ptr")
        (param $index i32)
        (result i32)
        (i32.load
            (i32.add
                (i32.add (global.get $CHAIN_REGISTRY_BASE) (global.get $OFFSET_CHAIN_PTRS))
                (i32.mul (local.get $index) (i32.const 4))
            )
        )
    )

    ;; Register a new chain, returns index (-1 if full)
    (func $register_chain (export "register_chain")
        (param $chain_ptr i32)
        (result i32)
        
        (local $count i32)
        (local $slot_ptr i32)
        
        ;; Get current count
        (local.set $count (i32.load (global.get $CHAIN_REGISTRY_BASE)))
        
        ;; Check if full
        (if (i32.ge_u (local.get $count) (global.get $CHAIN_REGISTRY_MAX))
            (then (return (i32.const -1)))
        )
        
        ;; Calculate slot pointer
        (local.set $slot_ptr
            (i32.add
                (i32.add (global.get $CHAIN_REGISTRY_BASE) (global.get $OFFSET_CHAIN_PTRS))
                (i32.mul (local.get $count) (i32.const 4))
            )
        )
        
        ;; Store chain pointer
        (i32.store (local.get $slot_ptr) (local.get $chain_ptr))
        
        ;; Increment count
        (i32.store 
            (global.get $CHAIN_REGISTRY_BASE) 
            (i32.add (local.get $count) (i32.const 1))
        )
        
        ;; Return index
        (local.get $count)
    )

    ;; ------------------------------------------------------------------------------------------------------------
    ;; CHAIN INITIALIZATION
    ;; ------------------------------------------------------------------------------------------------------------
    
    (func $init_chain (export "init_chain")
        (param $chain_ptr i32)
        
        ;; 1. Clear Chain Header (0..63)
        ;; (Simple loop or fill)
        (memory.fill (local.get $chain_ptr) (i32.const 0) (global.get $CHAIN_HEADER_SIZE))

        ;; 2. Clear Task State Block (64..127)
        (memory.fill 
            (i32.add (local.get $chain_ptr) (global.get $OFFSET_TASK_STATE_BLOCK)) 
            (i32.const 0) 
            (global.get $TASK_STATE_BLOCK_SIZE)
        )

        ;; 3. Clear Task Headers (128..4223)
        ;; Actually, let's just clear the whole block if possible, but step by step is fine.
        (memory.fill
            (i32.add (local.get $chain_ptr) (global.get $OFFSET_TASK_HEADERS_START))
            (i32.const 0)
            (i32.const 4096) ;; 64 * 64
        )
    )

    ;; ------------------------------------------------------------------------------------------------------------
    ;; PREPARE TASK
    ;; ------------------------------------------------------------------------------------------------------------
    (func $prepare_task (export "prepare_task")
        (param $chain_ptr i32)
        (param $task_index i32)
        (param $opcode i32)
        (param $next_task_index i32) ;; NEW PARAMETER
        
        (local $task_ptr i32)
        
        ;; Calculate Task Pointer
        (local.set $task_ptr
            (i32.add
                (local.get $chain_ptr)
                (i32.add
                    (global.get $OFFSET_TASK_HEADERS_START)
                    (i32.mul (local.get $task_index) (global.get $TASK_HEADER_SIZE))
                )
            )
        )

        ;; Write Next Task Index (Offset 0)
        (i32.store offset=0 (local.get $task_ptr) (local.get $next_task_index))

        ;; Write Opcode (Offset 5)
        (i32.store8 offset=5 (local.get $task_ptr) (local.get $opcode))
        
        ;; Reset Atomic Counter (Offset 4) -> 0 (Available)
        (i32.store8 offset=4 (local.get $task_ptr) (i32.const 0))
    )

    ;; ------------------------------------------------------------------------------------------------------------
    ;; ACTIVATE TASK (Set bit in Task State Block)
    ;; ------------------------------------------------------------------------------------------------------------
    
    (func $activate_task (export "activate_task")
        (param $chain_ptr i32)
        (param $task_index i32)
        
        (local $state_byte_ptr i32)
        
        ;; State Block is at Chain + 64.
        ;; It's a 64-byte vector. Each byte corresponds to a task? 
        ;; Wait, v128 scan checks for "any_true". 
        ;; If we use 64 bytes for 64 tasks, each byte is a task.
        ;; If byte != 0, task is pending.
        
        (local.set $state_byte_ptr
            (i32.add
                (i32.add (local.get $chain_ptr) (global.get $OFFSET_TASK_STATE_BLOCK))
                (local.get $task_index)
            )
        )
        
        ;; Set Byte to 1 (Pending)
        (i32.store8 (local.get $state_byte_ptr) (i32.const 1))
    )

)
