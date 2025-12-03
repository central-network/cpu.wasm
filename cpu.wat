(module
    
    (import "self" "Array"              (func $wat4wasm/Array<>ref (param) (result externref)))
    (import "Reflect" "set"             (func $wat4wasm/Reflect.set<ref.i32x2> (param externref i32 i32) (result)))
    (import "Reflect" "getOwnPropertyDescriptor" (func $wat4wasm/Reflect.getOwnPropertyDescriptor<refx2>ref (param externref externref) (result externref)))
    (import "Reflect" "construct"       (func $wat4wasm/Reflect.construct<refx2>ref (param externref externref) (result externref)))
    (import "Reflect" "get"             (func $wat4wasm/Reflect.get<refx2>ref (param externref externref) (result externref)))
    (import "Reflect" "get"             (func $wat4wasm/Reflect.get<refx2>i32 (param externref externref) (result i32)))
    (import "Reflect" "get"             (func $wat4wasm/Reflect.get<refx2>f32 (param externref externref) (result f32)))
    (import "Reflect" "get"             (func $wat4wasm/Reflect.get<refx2>i64 (param externref externref) (result i64)))
    (import "Reflect" "get"             (func $wat4wasm/Reflect.get<refx2>f64 (param externref externref) (result f64)))
    (import "Reflect" "apply"           (func $wat4wasm/Reflect.apply<refx3>ref (param externref externref externref) (result externref)))
    (import "self" "self"               (global $wat4wasm/self externref))
    (import "String" "fromCharCode"     (global $wat4wasm/String.fromCharCode externref))
   
	(import "Reflect" "apply" (func $self.Reflect.apply<refx3>ref (param externref externref externref) (result externref)))
	(import "Array" "of" (func $self.Array.of<i32>ref (param i32) (result externref)))
	(import "Reflect" "apply" (func $self.Reflect.apply<refx3> (param externref externref externref)))
	(import "Array" "of" (func $self.Array.of<>ref  (result externref)))
	(import "Array" "of" (func $self.Array.of<i32.i32>ref (param i32 i32) (result externref)))
	(import "Reflect" "construct" (func $self.Reflect.construct<refx2>ref (param externref externref) (result externref)))
	(import "Array" "of" (func $self.Array.of<ref.ref>ref (param externref externref) (result externref)))
	(import "Array" "of" (func $self.Array.of<ref>ref (param externref) (result externref)))
	(import "Reflect" "set" (func $self.Reflect.set<ref.i32.i32> (param externref i32 i32)))
	(import "URL" "createObjectURL" (func $self.URL.createObjectURL<ref>ref (param externref) (result externref)))
	(import "Object" "fromEntries" (func $self.Object.fromEntries<ref>ref (param externref) (result externref)))
	(import "Array" "of" (func $self.Array.of<ref.ref.ref>ref (param externref externref externref) (result externref)))
	(import "Array" "of" (func $self.Array.of<ref.i32>ref (param externref i32) (result externref)))
	(import "Reflect" "get" (func $self.Reflect.get<ref.ref>ref (param externref externref) (result externref)))
	(import "Reflect" "deleteProperty" (func $self.Reflect.deleteProperty<ref.ref> (param externref externref)))
	(import "Reflect" "deleteProperty" (func $self.Reflect.deleteProperty<fun.ref> (param funcref externref)))
	(import "self" "Symbol" (func $self.Symbol<ref>ref (param externref) (result externref)))
	(import "Reflect" "get" (func $self.Reflect.get<ref.ref>i32 (param externref externref) (result i32)))
	(import "Reflect" "setPrototypeOf" (func $self.Reflect.setPrototypeOf<fun.ref> (param funcref externref)))
	(import "Reflect" "defineProperty" (func $self.Reflect.defineProperty<ref.ref.ref> (param externref externref externref)))
	(import "Reflect" "defineProperty" (func $self.Reflect.defineProperty<fun.ref.ref> (param funcref externref externref)))
	(import "Array" "of" (func $self.Array.of<ref.fun>ref (param externref funcref) (result externref)))
	(import "Array" "of" (func $self.Array.of<i32.i32.i32>ref (param i32 i32 i32) (result externref)))
	(import "Reflect" "apply" (func $self.Reflect.apply<refx3>i32 (param externref externref externref) (result i32)))
	(import "ArrayBuffer" "isView" (func $self.ArrayBuffer.isView<ref>i32 (param externref) (result i32)))
	(import "Array" "of" (func $self.Array.of<i32x2>ref (param i32 i32) (result externref)))
	(import "Object" "is" (func $self.Object.is<ref.ref>i32 (param externref externref) (result i32)))
	(import "Reflect" "get" (func $self.Reflect.get<refx2>ref (param externref externref) (result externref)))
	(import "Reflect" "get" (func $self.Reflect.get<refx2>i32 (param externref externref) (result i32)))
	(import "Array" "of" (func $self.Array.of<fun>ref (param funcref) (result externref)))
	(import "Atomics" "notify" (func $self.Atomics.notify<ref.i32.i32>i32 (param externref i32 i32) (result i32)))
	(import "Atomics" "waitAsync" (func $self.Atomics.waitAsync<ref.i32.i32>ref (param externref i32 i32) (result externref)))
	(import "Reflect" "construct" (func $self.Reflect.construct<ref.ref>ref (param externref externref) (result externref)))
	 

    
    (memory 1)
    
    
	(; externref  ;)
	;; ============================================================================================================
    ;; CONSTANTS & OPCODES (BITWISE COMPOSITION)
    ;; ============================================================================================================
    ;; ID Structure (16-bit):
    ;; [ Reserved (3) ] [ Operation (6) ] [ Type (4) ] [ Variant (3) ]
    ;;
    ;; Formula:
    ;; ID = (Operation << 7) | (Type << 3) | Variant
    ;; 
    ;; Note: Shifts are adjusted to:
    ;; Variant:   Bits 0-2 (Mask: 0x07)
    ;; Type:      Bits 3-6 (Mask: 0x78)  -> Shift 3
    ;; Operation: Bits 7-12 (Mask: 0x1F80) -> Shift 7
    ;; ============================================================================================================

    ;; ------------------------------------------------------------------------------------------------------------
    ;; SHIFTS
    ;; ------------------------------------------------------------------------------------------------------------
    (global $SHIFT_TYPE                            i32 (i32.const 3))
    (global $SHIFT_OP                              i32 (i32.const 7))

    ;; ------------------------------------------------------------------------------------------------------------
    ;; VARIANTS (3 Bits: 1-7)
    ;; ------------------------------------------------------------------------------------------------------------
    (global $VARIANT_N                             i32 (i32.const 1)) ;; Exact Length
    (global $VARIANT_1                             i32 (i32.const 2)) ;; 1 Uniform / Scalar Source
    (global $VARIANT_0                             i32 (i32.const 3)) ;; 0 Source (Unary)
    (global $VARIANT_Q                             i32 (i32.const 4)) ;; Quarter Source
    (global $VARIANT_H                             i32 (i32.const 5)) ;; Half Source
    ;; Reserved 6-7

    ;; ------------------------------------------------------------------------------------------------------------
    ;; TYPES (4 Bits: 1-15)
    ;; ------------------------------------------------------------------------------------------------------------
    (global $TYPE_Float32                          i32 (i32.const 1))
    (global $TYPE_Int32                            i32 (i32.const 2))
    (global $TYPE_Uint32                           i32 (i32.const 3))
    (global $TYPE_Int8                             i32 (i32.const 4))
    (global $TYPE_Uint8                            i32 (i32.const 5))
    (global $TYPE_Int16                            i32 (i32.const 6))
    (global $TYPE_Uint16                           i32 (i32.const 7))
    (global $TYPE_Float64                          i32 (i32.const 8))
    (global $TYPE_BigInt64                         i32 (i32.const 9))
    (global $TYPE_BigUint64                        i32 (i32.const 10))
    ;; Reserved 11-15

    ;; ------------------------------------------------------------------------------------------------------------
    ;; OPERATIONS (6 Bits: 1-64)
    ;; ------------------------------------------------------------------------------------------------------------
    (global $OP_ADD                                i32 (i32.const 1))
    (global $OP_SUB                                i32 (i32.const 2))
    (global $OP_MUL                                i32 (i32.const 3))
    (global $OP_DIV                                i32 (i32.const 4))
    (global $OP_MAX                                i32 (i32.const 5))
    (global $OP_MIN                                i32 (i32.const 6))
    (global $OP_EQ                                 i32 (i32.const 7))
    (global $OP_NE                                 i32 (i32.const 8))
    (global $OP_LT                                 i32 (i32.const 9))
    (global $OP_GT                                 i32 (i32.const 10))
    (global $OP_LE                                 i32 (i32.const 11))
    (global $OP_GE                                 i32 (i32.const 12))
    (global $OP_FLOOR                              i32 (i32.const 13))
    (global $OP_TRUNC                              i32 (i32.const 14))
    (global $OP_CEIL                               i32 (i32.const 15))
    (global $OP_NEAREST                            i32 (i32.const 16))
    (global $OP_SQRT                               i32 (i32.const 17))
    (global $OP_ABS                                i32 (i32.const 18))
    (global $OP_NEG                                i32 (i32.const 19))
    (global $OP_AND                                i32 (i32.const 20))
    (global $OP_OR                                 i32 (i32.const 21))
    (global $OP_XOR                                i32 (i32.const 22))
    (global $OP_NOT                                i32 (i32.const 23))
    (global $OP_SHL                                i32 (i32.const 24))
    (global $OP_SHR                                i32 (i32.const 25))
    ;; ... Add more as needed

    ;; ------------------------------------------------------------------------------------------------------------
    ;; PRE-CALCULATED GLOBAL IDs (For Table & Exports)
    ;; Formula: (OP << 7) | (TYPE << 3) | VARIANT
    ;; Base: Type=1 (Float32) -> Shift 3 -> 8
    ;; ------------------------------------------------------------------------------------------------------------
    
    ;; ADD (OP=1) -> 128
    (global $f32v_add_n                            i32 (i32.const 137)) ;; 128 + 8 + 1
    (global $f32v_add_1                            i32 (i32.const 138)) ;; 128 + 8 + 2

    ;; SUB (OP=2) -> 256
    (global $f32v_sub_n                            i32 (i32.const 265)) ;; 256 + 8 + 1
    (global $f32v_sub_1                            i32 (i32.const 266)) ;; 256 + 8 + 2

    ;; MUL (OP=3) -> 384
    (global $f32v_mul_n                            i32 (i32.const 393)) ;; 384 + 8 + 1
    (global $f32v_mul_1                            i32 (i32.const 394)) ;; 384 + 8 + 2

    ;; DIV (OP=4) -> 512
    (global $f32v_div_n                            i32 (i32.const 521)) ;; 512 + 8 + 1
    (global $f32v_div_1                            i32 (i32.const 522)) ;; 512 + 8 + 2

    ;; MAX (OP=5) -> 640
    (global $f32v_max_n                            i32 (i32.const 649))
    (global $f32v_max_1                            i32 (i32.const 650))

    ;; MIN (OP=6) -> 768
    (global $f32v_min_n                            i32 (i32.const 777))
    (global $f32v_min_1                            i32 (i32.const 778))

    ;; EQ (OP=7) -> 896
    (global $f32v_eq_n                             i32 (i32.const 905))
    (global $f32v_eq_1                             i32 (i32.const 906))

    ;; NE (OP=8) -> 1024
    (global $f32v_ne_n                             i32 (i32.const 1033))
    (global $f32v_ne_1                             i32 (i32.const 1034))

    ;; LT (OP=9) -> 1152
    (global $f32v_lt_n                             i32 (i32.const 1161))
    (global $f32v_lt_1                             i32 (i32.const 1162))

    ;; GT (OP=10) -> 1280
    (global $f32v_gt_n                             i32 (i32.const 1289))
    (global $f32v_gt_1                             i32 (i32.const 1290))

    ;; LE (OP=11) -> 1408
    (global $f32v_le_n                             i32 (i32.const 1417))
    (global $f32v_le_1                             i32 (i32.const 1418))

    ;; GE (OP=12) -> 1536
    (global $f32v_ge_n                             i32 (i32.const 1545))
    (global $f32v_ge_1                             i32 (i32.const 1546))

    ;; FLOOR (OP=13) -> 1664
    (global $f32v_floor_0                          i32 (i32.const 1675)) ;; 1664 + 8 + 3

    ;; TRUNC (OP=14) -> 1792
    (global $f32v_trunc_0                          i32 (i32.const 1803)) ;; 1792 + 8 + 3

    ;; CEIL (OP=15) -> 1920
    (global $f32v_ceil_0                           i32 (i32.const 1931)) ;; 1920 + 8 + 3

    ;; NEAREST (OP=16) -> 2048
    (global $f32v_nearest_0                        i32 (i32.const 2059)) ;; 2048 + 8 + 3

    ;; ------------------------------------------------------------------------------------------------------------
    ;; MEMORY OFFSETS (64-Byte Header)
    ;; ------------------------------------------------------------------------------------------------------------
    
    ;; Block 0: Memory Info (0x00 - 0x0F)
    (global $OFFSET_ZERO                           i32 (i32.const 0))
    (global $OFFSET_HEAP_PTR                       i32 (i32.const 4))
    (global $OFFSET_CAPACITY                       i32 (i32.const 8))
    (global $OFFSET_MAXLENGTH                      i32 (i32.const 12))

    ;; Block 1: Worker Info (0x10 - 0x1F)
    (global $OFFSET_READY_STATE                    i32 (i32.const 16))
    (global $OFFSET_WORKER_COUNT                   i32 (i32.const 20))
    (global $OFFSET_ACTIVE_WORKERS                 i32 (i32.const 24))
    (global $OFFSET_LOCKED_WORKERS                 i32 (i32.const 28))

    (global $INDEX_ACTIVE_WORKERS                  i32 (i32.const 6))
    (global $INDEX_LOCKED_WORKERS                  i32 (i32.const 7))


    ;; Block 2: Control Info (0x20 - 0x2F)
    (global $OFFSET_FUNC_INDEX                     i32 (i32.const 32)) ;; 0x20
    (global $OFFSET_STRIDE                         i32 (i32.const 36)) ;; 0x24
    (global $OFFSET_WORKER_MUTEX                   i32 (i32.const 40)) ;; 0x28
    (global $OFFSET_WINDOW_MUTEX                   i32 (i32.const 44)) ;; 0x2C

    (global $INDEX_WORKER_MUTEX                    i32 (i32.const 10)) ;; 0x28
    (global $INDEX_WINDOW_MUTEX                    i32 (i32.const 11)) ;; 0x2C

    ;; Block 3: Task State Vector (0x30 - 0x3F) -> 48
    (global $OFFSET_TASK_VECTOR                    i32 (i32.const 48))
    (global $OFFSET_BUFFER_LEN                     i32 (i32.const 48))
    (global $OFFSET_SOURCE_PTR                     i32 (i32.const 52))
    (global $OFFSET_VALUES_PTR                     i32 (i32.const 56))
    (global $OFFSET_TARGET_PTR                     i32 (i32.const 60))

    ;; Heap Start
    (global $HEAP_START                            i32 (i32.const 64))
    (global $LENGTH_MALLOC_HEADERS                 i32 (i32.const 16)) 

    ;; Malloc Header Offsets (Relative to Data Pointer)
    (global $OFFSET_ARRAY_TYPE                     i32 (i32.const -16))
    (global $OFFSET_USED_BYTES                     i32 (i32.const -12))
    (global $OFFSET_BYTELENGTH                     i32 (i32.const -8))
    (global $OFFSET_ITEM_COUNT                     i32 (i32.const -4))

    ;; Legacy / Helper
    (global $SINGLE_VALUE                          i32 (i32.const 4))
    (global $EXACT_LENGTH                          i32 (i32.const 75))
    (global $ZERO_UNIFORM                          i32 (i32.const 150))
    (global $QUARTER_BITS                          i32 (i32.const 225))
    (global $HALF_OF_BITS                          i32 (i32.const 300))
    (global $SIGNED                                i32 (i32.const 2))
    (global $UNSIGNED                              i32 (i32.const 3))

    (global $TYPE_DataView                         i32 (i32.const 11)) ;; Added DataView

    (global $READY_STATE_CLOSED                    i32 (i32.const 0))
    (global $READY_STATE_OPEN                      i32 (i32.const 1))
    (global $READY_STATE_OPENING                   i32 (i32.const 2))
    (global $READY_STATE_CLOSING                   i32 (i32.const 3))
    (global $READY_STATE_ERROR                     i32 (i32.const 4))
    (global $READY_STATE_BUSY                      i32 (i32.const 5))
    (global $READY_STATE_IDLE                      i32 (i32.const 6))
    
    (global $worker/length i32 (i32.const 1949))
    (data $worker/buffer "\00\61\73\6d\01\00\00\00\01\45\0d\60\00\01\6f\60\03\6f\7f\7f\00\60\02\6f\6f\01\6f\60\02\6f\6f\01\7f\60\02\6f\6f\01\7d\60\02\6f\6f\01\7e\60\02\6f\6f\01\7c\60\03\6f\6f\6f\01\6f\60\01\6f\00\60\00\00\60\00\01\7f\60\00\01\7b\60\02\7f\7f\01\6f\02\fc\01\0f\04\73\65\6c\66\05\41\72\72\61\79\00\00\07\52\65\66\6c\65\63\74\03\73\65\74\00\01\07\52\65\66\6c\65\63\74\18\67\65\74\4f\77\6e\50\72\6f\70\65\72\74\79\44\65\73\63\72\69\70\74\6f\72\00\02\07\52\65\66\6c\65\63\74\09\63\6f\6e\73\74\72\75\63\74\00\02\07\52\65\66\6c\65\63\74\03\67\65\74\00\02\07\52\65\66\6c\65\63\74\03\67\65\74\00\03\07\52\65\66\6c\65\63\74\03\67\65\74\00\04\07\52\65\66\6c\65\63\74\03\67\65\74\00\05\07\52\65\66\6c\65\63\74\03\67\65\74\00\06\07\52\65\66\6c\65\63\74\05\61\70\70\6c\79\00\07\04\73\65\6c\66\04\73\65\6c\66\03\6f\00\06\53\74\72\69\6e\67\0c\66\72\6f\6d\43\68\61\72\43\6f\64\65\03\6f\00\07\63\6f\6e\73\6f\6c\65\05\65\72\72\6f\72\00\08\04\73\65\6c\66\06\6d\65\6d\6f\72\79\02\03\0a\ff\ff\03\04\73\65\6c\66\05\63\6c\6f\73\65\00\09\03\15\14\09\09\09\0a\0a\0a\0a\0a\0a\0b\0a\0a\0a\0a\09\09\09\0a\09\0c\04\09\02\70\00\b8\17\6f\01\07\07\06\86\05\74\7f\00\41\03\0b\7f\00\41\07\0b\7f\00\41\01\0b\7f\00\41\02\0b\7f\00\41\03\0b\7f\00\41\04\0b\7f\00\41\05\0b\7f\00\41\01\0b\7f\00\41\02\0b\7f\00\41\03\0b\7f\00\41\04\0b\7f\00\41\05\0b\7f\00\41\06\0b\7f\00\41\07\0b\7f\00\41\08\0b\7f\00\41\09\0b\7f\00\41\0a\0b\7f\00\41\01\0b\7f\00\41\02\0b\7f\00\41\03\0b\7f\00\41\04\0b\7f\00\41\05\0b\7f\00\41\06\0b\7f\00\41\07\0b\7f\00\41\08\0b\7f\00\41\09\0b\7f\00\41\0a\0b\7f\00\41\0b\0b\7f\00\41\0c\0b\7f\00\41\0d\0b\7f\00\41\0e\0b\7f\00\41\0f\0b\7f\00\41\10\0b\7f\00\41\11\0b\7f\00\41\12\0b\7f\00\41\13\0b\7f\00\41\14\0b\7f\00\41\15\0b\7f\00\41\16\0b\7f\00\41\17\0b\7f\00\41\18\0b\7f\00\41\19\0b\7f\00\41\89\01\0b\7f\00\41\8a\01\0b\7f\00\41\89\02\0b\7f\00\41\8a\02\0b\7f\00\41\89\03\0b\7f\00\41\8a\03\0b\7f\00\41\89\04\0b\7f\00\41\8a\04\0b\7f\00\41\89\05\0b\7f\00\41\8a\05\0b\7f\00\41\89\06\0b\7f\00\41\8a\06\0b\7f\00\41\89\07\0b\7f\00\41\8a\07\0b\7f\00\41\89\08\0b\7f\00\41\8a\08\0b\7f\00\41\89\09\0b\7f\00\41\8a\09\0b\7f\00\41\89\0a\0b\7f\00\41\8a\0a\0b\7f\00\41\89\0b\0b\7f\00\41\8a\0b\0b\7f\00\41\89\0c\0b\7f\00\41\8a\0c\0b\7f\00\41\8b\0d\0b\7f\00\41\8b\0e\0b\7f\00\41\8b\0f\0b\7f\00\41\8b\10\0b\7f\00\41\00\0b\7f\00\41\04\0b\7f\00\41\08\0b\7f\00\41\0c\0b\7f\00\41\10\0b\7f\00\41\14\0b\7f\00\41\18\0b\7f\00\41\1c\0b\7f\00\41\06\0b\7f\00\41\07\0b\7f\00\41\20\0b\7f\00\41\24\0b\7f\00\41\28\0b\7f\00\41\2c\0b\7f\00\41\0a\0b\7f\00\41\0b\0b\7f\00\41\30\0b\7f\00\41\30\0b\7f\00\41\34\0b\7f\00\41\38\0b\7f\00\41\3c\0b\7f\00\41\c0\00\0b\7f\00\41\10\0b\7f\00\41\70\0b\7f\00\41\74\0b\7f\00\41\78\0b\7f\00\41\7c\0b\7f\00\41\04\0b\7f\00\41\cb\00\0b\7f\00\41\96\01\0b\7f\00\41\e1\01\0b\7f\00\41\ac\02\0b\7f\00\41\02\0b\7f\00\41\03\0b\7f\00\41\0b\0b\7f\00\41\00\0b\7f\00\41\01\0b\7f\00\41\02\0b\7f\00\41\03\0b\7f\00\41\04\0b\7f\00\41\05\0b\7f\00\41\06\0b\7f\01\41\00\0b\7b\01\fd\0c\00\00\00\00\10\00\00\00\10\00\00\00\10\00\00\00\0b\7b\01\fd\0c\ff\ff\ff\ff\01\00\00\00\01\00\00\00\01\00\00\00\0b\6f\01\d0\6f\0b\08\01\1a\09\06\01\01\00\02\0d\0e\0c\01\01\0a\ac\04\14\0e\00\23\2c\d2\0d\26\00\23\30\d2\0e\26\00\0b\41\01\01\7b\23\73\10\15\fd\ae\01\21\00\03\40\20\00\fd\1b\00\04\40\20\00\fd\1b\03\20\00\fd\1b\01\fd\00\04\00\20\00\fd\1b\02\fd\00\04\00\fd\e4\01\fd\0b\04\00\23\74\20\00\fd\ae\01\21\00\0c\01\0b\0b\0b\41\01\01\7b\23\73\10\15\fd\ae\01\21\00\03\40\20\00\fd\1b\00\04\40\20\00\fd\1b\03\20\00\fd\1b\01\fd\00\04\00\20\00\fd\1b\02\fd\00\04\00\fd\e6\01\fd\0b\04\00\23\74\20\00\fd\ae\01\21\00\0c\01\0b\0b\0b\08\00\23\4d\fe\10\02\00\0b\0a\00\23\4e\41\01\fe\1e\02\00\0b\08\00\23\4e\fe\10\02\00\0b\08\00\23\4c\fe\10\02\00\0b\07\00\23\52\28\02\00\0b\07\00\23\53\28\02\00\0b\08\00\23\58\fd\00\04\00\0b\07\00\23\59\28\02\00\0b\07\00\23\5a\28\02\00\0b\07\00\23\5b\28\02\00\0b\07\00\23\5c\28\02\00\0b\7e\00\41\01\41\00\41\84\01\10\1f\26\01\41\02\41\84\01\41\ec\00\10\1f\26\01\41\03\41\f0\01\41\30\10\1f\26\01\41\04\41\a0\02\41\24\10\1f\26\01\41\05\41\c4\02\41\10\10\1f\26\01\41\06\41\d4\02\41\0c\10\1f\26\01\23\00\41\03\25\01\10\04\41\04\25\01\10\04\41\05\25\01\10\02\41\06\25\01\10\04\24\75\10\1b\03\40\10\1c\10\13\11\09\00\10\1d\45\04\40\10\1e\0b\10\12\23\6e\47\0d\00\0b\10\0b\0b\2b\00\10\10\24\72\23\73\23\72\fd\11\fd\b5\01\24\73\23\74\10\14\fd\11\fd\b5\01\24\74\10\0f\23\72\41\01\6a\46\04\40\10\1e\0b\10\0c\0b\15\00\23\54\41\00\42\7f\fe\01\02\00\04\40\41\01\25\01\10\0a\0b\0b\0d\00\23\4e\41\01\fe\25\02\00\41\01\6b\0b\15\00\23\55\41\01\fe\00\02\00\04\40\0f\0b\41\02\25\01\10\0a\00\0b\53\02\01\6f\01\7f\20\01\45\04\40\d0\6f\0f\0b\10\00\21\02\41\00\28\02\00\21\03\03\40\20\01\41\04\6b\21\01\41\00\20\00\20\01\6a\41\04\fc\08\00\00\20\02\20\01\41\04\6e\41\00\2a\02\00\a9\10\01\20\01\0d\00\0b\41\00\20\03\36\02\00\23\01\d0\6f\20\02\10\09\0b\0b\e4\02\01\01\e0\02\00\00\ae\42\00\00\d2\42\00\00\dc\42\00\00\c8\42\00\00\de\42\00\00\ee\42\00\00\00\42\00\00\da\42\00\00\ea\42\00\00\e8\42\00\00\ca\42\00\00\f0\42\00\00\00\42\00\00\d8\42\00\00\de\42\00\00\c6\42\00\00\d6\42\00\00\00\42\00\00\e4\42\00\00\ca\42\00\00\e8\42\00\00\ea\42\00\00\e4\42\00\00\dc\42\00\00\ca\42\00\00\c8\42\00\00\00\42\00\00\ec\42\00\00\c2\42\00\00\d8\42\00\00\ea\42\00\00\ca\42\00\00\04\42\00\00\ae\42\00\00\d2\42\00\00\dc\42\00\00\c8\42\00\00\de\42\00\00\ee\42\00\00\00\42\00\00\dc\42\00\00\de\42\00\00\e8\42\00\00\d2\42\00\00\cc\42\00\00\d2\42\00\00\c6\42\00\00\c2\42\00\00\e8\42\00\00\d2\42\00\00\de\42\00\00\dc\42\00\00\00\42\00\00\cc\42\00\00\c2\42\00\00\d2\42\00\00\d8\42\00\00\ca\42\00\00\c8\42\00\00\04\42\00\00\9a\42\00\00\ca\42\00\00\e6\42\00\00\e6\42\00\00\c2\42\00\00\ce\42\00\00\ca\42\00\00\8a\42\00\00\ec\42\00\00\ca\42\00\00\dc\42\00\00\e8\42\00\00\e0\42\00\00\e4\42\00\00\de\42\00\00\e8\42\00\00\de\42\00\00\e8\42\00\00\f2\42\00\00\e0\42\00\00\ca\42\00\00\c8\42\00\00\c2\42\00\00\e8\42\00\00\c2\42\00\00\ce\42\00\00\ca\42\00\00\e8\42")
    

    
	(; externref  ;)
	(func $onlastworkeropen<>
        (call $set_ready_state<i32>
            (global.get $READY_STATE_OPEN)
        )

        (; check is calc requested ;)
        (if (call $get_func_index<>i32)
            (then            
                (call $set_active_workers<i32>
                    (call $notify_worker_mutex<>i32)
                )
            )
        )
    )

    (func $terminate_all_workers<>
        (local $threads externref )
        (local $worker externref )
        (local $index            i32)

        (local.set $index (call $get_worker_count<>i32 ))
        (local.set $threads (global.get $worker.threads))

        (loop $workerCount--

            (local.set $index (local.get $index) (i32.const 1) (i32.sub))

            (local.set $worker
                (call $self.Reflect.apply<refx3>ref 
            (global.get $self.Array:at)
                    (local.get 0) (call $self.Array.of<i32>ref (local.get $index))
                )
            )

            (call $self.Reflect.apply<refx3> 
            (global.get $self.Worker:terminate) 
                (local.get $worker) (call $self.Array.of<>ref)
            )

            (br_if $workerCount-- (local.get $index))
        )
        
        (call $self.Reflect.apply<refx3> 
            (global.get $self.Array:splice) 
            (local.get 0) (call $self.Array.of<i32.i32>ref (i32.const 0) (call $notify_worker_mutex<>i32))
        )

        (call $set_worker_count<i32> (i32.const 0))
    )

    (func $create_worker_threads<>
        (local $workerCount          i32)
        (local $worker externref )

        (local.set $workerCount
            (call $get_worker_count<>i32)
        )

        (loop $fork
            (local.set $worker
                (call $self.Reflect.construct<refx2>ref 
            (global.get $self.Worker) 
            (call $self.Array.of<ref.ref>ref 
                    (call $get_worker_url<>ref)
                    (call $get_worker_config<>ref)
                ))
            )

            (call $self.Reflect.apply<refx3> 
            (global.get $self.Worker:postMessage)
                (local.get $worker) (call $self.Array.of<ref>ref (call $get_worker_data<>ref ))
            )

            (call $self.Reflect.apply<refx3> 
            (global.get $self.Array:push)
                (global.get $worker.threads) (call $self.Array.of<ref>ref (local.get $worker))
            )

            (br_if $fork (local.tee $workerCount (local.get $workerCount) (i32.const 1) (i32.sub)))
        )        
    )


    (func $get_worker_module<>ref
        (result externref)
        (local $i i32)
        (local $zero i32)
        (local $module externref)

        (if (ref.is_null (global.get $module))
            (then
                (local.set $i (global.get $worker/length))
                (local.set $zero (i32.load (i32.const 0)))
                (local.set $module (call $self.Reflect.construct<refx2>ref 
            (global.get $self.Uint8Array) 
            (call $self.Array.of<i32>ref  (local.get $i))))

                (loop $i-- (local.tee $i (local.get $i) (i32.const 1) (i32.sub))
                    (if (then
                            (memory.init $worker/buffer (i32.const 0) (local.get $i) (i32.const 1))

                            (call $self.Reflect.set<ref.i32.i32>
                                (local.get $module) (local.get $i) (i32.load (i32.const 0))
                            )

                            (br $i--)
                        )
                    )
                )

                (i32.store (i32.const 0) (local.get $zero))
                (global.set $module (local.get $module))
            )
        )

        (global.get $module)
    )

    (func $get_worker_url<>ref
        (result externref)

        (if (ref.is_null (global.get $worker.URL))
            (then
                (global.set $worker.URL
                    (call $self.URL.createObjectURL<ref>ref
                        (call $self.Reflect.construct<refx2>ref 
            (global.get $self.Blob) 
            (call $self.Array.of<ref>ref 
                            (call $self.Array.of<ref>ref
                                (global.get $worker.code)
                            )
                        ))
                    )
                )
            )
        )

        (global.get $worker.URL)
    )

    (func $get_worker_data<>ref
        (result externref)

        (if (ref.is_null (global.get $worker.data))
            (then
                (global.set $worker.data
                    (call $self.Object.fromEntries<ref>ref
                        (call $self.Array.of<ref.ref>ref
                            (call $self.Array.of<ref.ref>ref (table.get $extern (i32.const 1)) (call $get_worker_module<>ref ))
                            (call $self.Array.of<ref.ref>ref (table.get $extern (i32.const 2)) (global.get $memory))
                        )
                    )
                )
            )
        )

        (global.get $worker.data)
    )

    (func $get_worker_config<>ref
        (result externref)

        (if (ref.is_null (global.get $worker.config))
            (then
                (global.set $worker.config
                    (call $self.Object.fromEntries<ref>ref
                        (call $self.Array.of<ref>ref
                            (call $self.Array.of<ref.ref>ref
                                (table.get $extern (i32.const 3)) (table.get $extern (i32.const 4))
                            )
                        )
                    )
                )
            )
        )

        (global.get $worker.config)
    )
    
	(; externref  ;)
	(func $get_memory<>ref
        (result externref)

        (if (ref.is_null (global.get $memory))
            (then
                (global.set $memory
                    (call $self.Reflect.construct<refx2>ref 
            (global.get $self.WebAssembly.Memory) 
            (call $self.Array.of<ref>ref 
                        (call $self.Object.fromEntries<ref>ref
                            (call $self.Array.of<ref.ref.ref>ref
                                (call $self.Array.of<ref.i32>ref (table.get $extern (i32.const 5)) (global.get $DEFAULT_MEMORY_INITIAL))
                                (call $self.Array.of<ref.i32>ref (table.get $extern (i32.const 6)) (global.get $DEFAULT_MEMORY_MAXIMUM))
                                (call $self.Array.of<ref.i32>ref (table.get $extern (i32.const 7))  (global.get $DEFAULT_MEMORY_SHARED))
                            )
                        )
                    ))
                )
            )
        )

        (global.get $memory)
    )

    (func $get_buffer<>ref
        (result externref)

        (if (ref.is_null (global.get $buffer))
            (then
                (global.set $buffer
                    (call $self.Reflect.get<ref.ref>ref
                        (call $get_memory<>ref) 
                        (table.get $extern (i32.const 8))
                    ) 
                )
            )
        )

        (global.get $buffer)
    )

    (func $create_memory_links<>
        (global.set $i32View
            (call $self.Reflect.construct<refx2>ref 
            (global.get $self.Int32Array) 
            (call $self.Array.of<ref>ref 
                (call $get_buffer<>ref)
            ))
        )

        (global.set $dataView
            (call $self.Reflect.construct<refx2>ref 
            (global.get $self.DataView) 
            (call $self.Array.of<ref>ref 
                (call $get_buffer<>ref)
            ))
        )
    )

    (func $reset_memory_values<i32>
        (param $workerCount i32)
        
        (call $set_zero<i32>            (i32.const 0))
        (call $set_heap_ptr<i32>        (global.get $HEAP_START))
        (call $set_capacity<i32>        (i32.mul (global.get $DEFAULT_MEMORY_INITIAL) (i32.const 65536)))
        (call $set_maxlength<i32>       (i32.mul (global.get $DEFAULT_MEMORY_MAXIMUM) (i32.const 65536)))

        (call $set_ready_state<i32>     (global.get $READY_STATE_OPENING))
        (call $set_worker_count<i32>    (local.get $workerCount))
        (call $set_active_workers<i32>  (i32.const 0))
        (call $set_locked_workers<i32>  (i32.const 0))

        (call $set_func_index<i32>      (i32.const 0))
        (call $set_stride<i32>          (i32.mul (local.get $workerCount) (i32.const 16)))
        (call $set_worker_mutex<i32>    (i32.const 0))
        (call $set_window_mutex<i32>    (i32.const 0))

        (call $set_buffer_len<i32>      (i32.const 0))
        (call $set_source_ptr<i32>      (i32.const 0))
        (call $set_values_ptr<i32>      (i32.const 0))
        (call $set_target_ptr<i32>      (i32.const 0))
    )
    
	(; externref  ;)
	(func $delete_self_symbols<>
        (call $self.Reflect.deleteProperty<ref.ref> (global.get $self.Uint8Array)   (call $get_self_symbol<>ref))
        (call $self.Reflect.deleteProperty<ref.ref> (global.get $self.Uint16Array)  (call $get_self_symbol<>ref))
        (call $self.Reflect.deleteProperty<ref.ref> (global.get $self.Uint32Array)  (call $get_self_symbol<>ref))
        (call $self.Reflect.deleteProperty<ref.ref> (global.get $self.Float32Array) (call $get_self_symbol<>ref))
        (call $self.Reflect.deleteProperty<ref.ref> (global.get $self.DataView)     (call $get_self_symbol<>ref))

        (call $self.Reflect.deleteProperty<fun.ref> (ref.func $this) (table.get $extern (i32.const 9)))
        (call $self.Reflect.deleteProperty<fun.ref> (ref.func $this) (table.get $extern (i32.const 10)))
        (call $self.Reflect.deleteProperty<fun.ref> (ref.func $this) (table.get $extern (i32.const 2)))
    )

    (func $get_self_symbol<>ref
        (result externref)

        (if (ref.is_null (global.get $kSymbol))
            (then
                (global.set $kSymbol 
                    (call $self.Symbol<ref>ref 
                        (global.get $kSymbol.tag)
                    )
                )
            )
        )

        (global.get $kSymbol)
    )

    (func $get_self_symbol<ref>i32
        (param $this externref)
        (result i32)
        (call $self.Reflect.get<ref.ref>i32 (local.get $this) (call $get_self_symbol<>ref))
    )

    (func $define_self_symbols<>
        (call $define_property<ref.ref.i32> (global.get $self.Uint8Array)   (call $get_self_symbol<>ref) (global.get $TYPE_Uint8))
        (call $define_property<ref.ref.i32> (global.get $self.Uint16Array)  (call $get_self_symbol<>ref) (global.get $TYPE_Uint16))
        (call $define_property<ref.ref.i32> (global.get $self.Uint32Array)  (call $get_self_symbol<>ref) (global.get $TYPE_Uint32))
        (call $define_property<ref.ref.i32> (global.get $self.Float32Array) (call $get_self_symbol<>ref) (global.get $TYPE_Float32))
        (call $define_property<ref.ref.i32> (global.get $self.DataView)     (call $get_self_symbol<>ref) (global.get $TYPE_DataView))
        
        (call $define_property<fun.ref.ref> (ref.func $this) (table.get $extern (i32.const 11)) (global.get $worker.threads))
        (call $define_property<fun.ref.ref> (ref.func $this) (table.get $extern (i32.const 2)) (call $get_memory<>ref))
        (call $define_property<fun.ref.fun> (ref.func $this) (table.get $extern (i32.const 9)) (ref.func $create))
        (call $define_property<fun.ref.fun> (ref.func $this) (table.get $extern (i32.const 10)) (ref.func $destroy))
        (call $define_property<fun.ref.fun> (ref.func $this) (table.get $extern (i32.const 12)) (ref.func $malloc))

        (call $self.Reflect.setPrototypeOf<fun.ref> (ref.func $this) (ref.null extern))
        (call $self.Reflect.deleteProperty<fun.ref> (ref.func $this) (table.get $extern (i32.const 13)))
        (call $self.Reflect.deleteProperty<fun.ref> (ref.func $this) (table.get $extern (i32.const 3)))
    )

    (func $define_property<ref.ref.i32>
        (param $ref externref)
        (param $key externref)
        (param $val i32)
        
        (call $self.Reflect.defineProperty<ref.ref.ref>
            (local.get $ref) 
            (local.get $key)
            (call $self.Object.fromEntries<ref>ref
                (call $self.Array.of<ref.ref>ref
                    (call $self.Array.of<ref.i32>ref (table.get $extern (i32.const 14)) (local.get $val))
                    (call $self.Array.of<ref.i32>ref (table.get $extern (i32.const 15)) (i32.const 1))
                )
            )
        )
    )

    (func $define_property<fun.ref.i32>
        (param $ref funcref)
        (param $key externref)
        (param $val i32)
        
        (call $self.Reflect.defineProperty<fun.ref.ref>
            (local.get $ref) 
            (local.get $key)
            (call $self.Object.fromEntries<ref>ref
                (call $self.Array.of<ref.ref>ref
                    (call $self.Array.of<ref.i32>ref (table.get $extern (i32.const 14)) (local.get $val))
                    (call $self.Array.of<ref.i32>ref (table.get $extern (i32.const 15)) (i32.const 1))
                )
            )
        )
    )

    (func $define_property<fun.ref.fun>
        (param $ref funcref)
        (param $key externref)
        (param $val funcref)
        
        (call $self.Reflect.defineProperty<fun.ref.ref>
            (local.get $ref) 
            (local.get $key)
            (call $self.Object.fromEntries<ref>ref
                (call $self.Array.of<ref.ref.ref>ref
                    (call $self.Array.of<ref.fun>ref (table.get $extern (i32.const 14)) (local.get $val))
                    (call $self.Array.of<ref.i32>ref (table.get $extern (i32.const 16)) (i32.const 1))
                    (call $self.Array.of<ref.i32>ref (table.get $extern (i32.const 15)) (i32.const 1))
                )
            )
        )
    )

    (func $define_property<fun.ref.ref>
        (param $ref funcref)
        (param $key externref)
        (param $val externref)
        
        (call $self.Reflect.defineProperty<fun.ref.ref>
            (local.get $ref) 
            (local.get $key)
            (call $self.Object.fromEntries<ref>ref
                (call $self.Array.of<ref.ref.ref>ref
                    (call $self.Array.of<ref.ref>ref (table.get $extern (i32.const 14)) (local.get $val))
                    (call $self.Array.of<ref.i32>ref (table.get $extern (i32.const 16)) (i32.const 1))
                    (call $self.Array.of<ref.i32>ref (table.get $extern (i32.const 15)) (i32.const 1))
                )
            )
        )
    )
    
	(; externref  ;)
	(func $malloc
        (param $byteLength i32)
        (result i32)

        (local $usedBytes i32)
        (local $offset i32)
        (local $rem_u i32)
        (local $stride i32)

        (local.set $stride (call $get_stride<>i32 ))
        (local.set $offset (call $get_heap_ptr<>i32 ))

        (local.set $usedBytes
            (i32.add
                (local.get $byteLength) 
                (global.get $LENGTH_MALLOC_HEADERS)
            )
        )

        (if (i32.le_u (local.get $usedBytes) (local.get $stride))
            (then (local.set $usedBytes (local.get $stride)))
            (else
                (if (local.tee $rem_u
                        (i32.rem_u
                            (local.get $usedBytes)
                            (local.get $stride)
                        )
                    )
                    (then
                        (local.set $usedBytes
                            (i32.add 
                                (local.get $usedBytes)
                                (i32.sub
                                    (local.get $stride)
                                    (local.get $rem_u)
                                )
                            )
                        )
                    )
                )
            )
        )

        (call $set_heap_ptr<i32> 
            (i32.add
                (local.get $offset) 
                (local.get $usedBytes)
            )
        )

        (local.set $offset
            (i32.add
                (local.get $offset) 
                (global.get $LENGTH_MALLOC_HEADERS)
            )
        )

        (call $set_bytelength<i32.i32> (local.get $offset) (local.get $byteLength))
        (call $set_used_bytes<i32.i32> (local.get $offset) (local.get $usedBytes))

        (local.get $offset)
    )

    (func $set_array_type<i32.i32>
        (param $ptr i32)
        (param $value i32)

        (call $self.Reflect.apply<refx3> 
            (global.get $self.DataView:setUint32)
            (global.get $dataView)
            (call $self.Array.of<i32.i32.i32>ref 
                (i32.add (local.get $ptr) (global.get $OFFSET_ARRAY_TYPE))
                (local.get $value)
                (i32.const 1)
            )
        )
    )

    (func $set_used_bytes<i32.i32>
        (param $ptr i32)
        (param $value i32)

        (call $self.Reflect.apply<refx3> 
            (global.get $self.DataView:setUint32)
            (global.get $dataView)
            (call $self.Array.of<i32.i32.i32>ref 
                (i32.add (local.get $ptr) (global.get $OFFSET_USED_BYTES))
                (local.get $value)
                (i32.const 1)
            )
        )
    )

    (func $set_bytelength<i32.i32>
        (param $ptr i32)
        (param $value i32)

        (call $self.Reflect.apply<refx3> 
            (global.get $self.DataView:setUint32)
            (global.get $dataView)
            (call $self.Array.of<i32.i32.i32>ref 
                (i32.add (local.get $ptr) (global.get $OFFSET_BYTELENGTH))
                (local.get $value)
                (i32.const 1)
            )
        )
    )

    (func $set_item_count<i32.i32>
        (param $ptr i32)
        (param $value i32)

        (call $self.Reflect.apply<refx3> 
            (global.get $self.DataView:setUint32)
            (global.get $dataView)
            (call $self.Array.of<i32.i32.i32>ref 
                (i32.add (local.get $ptr) (global.get $OFFSET_ITEM_COUNT))
                (local.get $value)
                (i32.const 1)
            )
        )
    )

    (func $get_array_type<i32>i32
        (param $ptr i32)
        (result i32)

        (call $self.Reflect.apply<refx3>i32 
            (global.get $self.DataView:getUint32)
            (global.get $dataView)
            (call $self.Array.of<i32.i32>ref 
                (i32.add (local.get $ptr) (global.get $OFFSET_ARRAY_TYPE))
                (i32.const 1)
            )
        )
    )

    (func $get_used_bytes<i32>i32
        (param $ptr i32)
        (result i32)

        (call $self.Reflect.apply<refx3>i32 
            (global.get $self.DataView:getUint32)
            (global.get $dataView)
            (call $self.Array.of<i32.i32>ref 
                (i32.add (local.get $ptr) (global.get $OFFSET_USED_BYTES))
                (i32.const 1)
            )
        )
    )

    (func $get_bytelength<i32>i32
        (param $ptr i32)
        (result i32)

        (call $self.Reflect.apply<refx3>i32 
            (global.get $self.DataView:getUint32)
            (global.get $dataView)
            (call $self.Array.of<i32.i32>ref 
                (i32.add (local.get $ptr) (global.get $OFFSET_BYTELENGTH))
                (i32.const 1)
            )
        )
    )

    (func $get_item_count<i32>i32
        (param $ptr i32)
        (result i32)

        (call $self.Reflect.apply<refx3>i32 
            (global.get $self.DataView:getUint32)
            (global.get $dataView)
            (call $self.Array.of<i32.i32>ref 
                (i32.add (local.get $ptr) (global.get $OFFSET_ITEM_COUNT))
                (i32.const 1)
            )
        )
    )

    (func $set_zero<i32>
        (param $value i32)
        
        (call $self.Reflect.apply<refx3> 
            (global.get $self.DataView:setUint32)
            (global.get $dataView)
            (call $self.Array.of<i32.i32.i32>ref 
                (global.get $OFFSET_ZERO)
                (local.get $value)
                (i32.const 1)
            )
        )
    )

    (func $set_heap_ptr<i32>
        (param $value i32)
        
        (call $self.Reflect.apply<refx3> 
            (global.get $self.DataView:setUint32)
            (global.get $dataView)
            (call $self.Array.of<i32.i32.i32>ref 
                (global.get $OFFSET_HEAP_PTR)
                (local.get $value)
                (i32.const 1)
            )
        )
    )

    (func $set_capacity<i32>
        (param $value i32)
        
        (call $self.Reflect.apply<refx3> 
            (global.get $self.DataView:setUint32)
            (global.get $dataView)
            (call $self.Array.of<i32.i32.i32>ref 
                (global.get $OFFSET_CAPACITY)
                (local.get $value)
                (i32.const 1)
            )
        )
    )

    (func $set_maxlength<i32>
        (param $value i32)
        
        (call $self.Reflect.apply<refx3> 
            (global.get $self.DataView:setUint32)
            (global.get $dataView)
            (call $self.Array.of<i32.i32.i32>ref 
                (global.get $OFFSET_MAXLENGTH)
                (local.get $value)
                (i32.const 1)
            )
        )
    )

    (func $set_ready_state<i32>
        (param $value i32)
        
        (call $self.Reflect.apply<refx3> 
            (global.get $self.DataView:setUint32)
            (global.get $dataView)
            (call $self.Array.of<i32.i32.i32>ref 
                (global.get $OFFSET_READY_STATE)
                (local.get $value)
                (i32.const 1)
            )
        )
    )

    (func $set_worker_count<i32>
        (param $value i32)
        
        (call $self.Reflect.apply<refx3> 
            (global.get $self.DataView:setUint32)
            (global.get $dataView)
            (call $self.Array.of<i32.i32.i32>ref 
                (global.get $OFFSET_WORKER_COUNT)
                (local.get $value)
                (i32.const 1)
            )
        )
    )

    (func $set_active_workers<i32>
        (param $value i32)
        
        (call $self.Reflect.apply<refx3> 
            (global.get $self.DataView:setUint32)
            (global.get $dataView)
            (call $self.Array.of<i32.i32.i32>ref 
                (global.get $OFFSET_ACTIVE_WORKERS)
                (local.get $value)
                (i32.const 1)
            )
        )
    )

    (func $set_locked_workers<i32>
        (param $value i32)
        
        (call $self.Reflect.apply<refx3> 
            (global.get $self.DataView:setUint32)
            (global.get $dataView)
            (call $self.Array.of<i32.i32.i32>ref 
                (global.get $OFFSET_LOCKED_WORKERS)
                (local.get $value)
                (i32.const 1)
            )
        )
    )

    (func $set_func_index<i32>
        (param $value i32)
        
        (call $self.Reflect.apply<refx3> 
            (global.get $self.DataView:setUint32)
            (global.get $dataView)
            (call $self.Array.of<i32.i32.i32>ref 
                (global.get $OFFSET_FUNC_INDEX)
                (local.get $value)
                (i32.const 1)
            )
        )
    )

    (func $set_stride<i32>
        (param $value i32)
        
        (call $self.Reflect.apply<refx3> 
            (global.get $self.DataView:setUint32)
            (global.get $dataView)
            (call $self.Array.of<i32.i32.i32>ref 
                (global.get $OFFSET_STRIDE)
                (local.get $value)
                (i32.const 1)
            )
        )
    )

    (func $set_worker_mutex<i32>
        (param $value i32)
        
        (call $self.Reflect.apply<refx3> 
            (global.get $self.DataView:setUint32)
            (global.get $dataView)
            (call $self.Array.of<i32.i32.i32>ref 
                (global.get $OFFSET_WORKER_MUTEX)
                (local.get $value)
                (i32.const 1)
            )
        )
    )

    (func $set_window_mutex<i32>
        (param $value i32)
        
        (call $self.Reflect.apply<refx3> 
            (global.get $self.DataView:setUint32)
            (global.get $dataView)
            (call $self.Array.of<i32.i32.i32>ref 
                (global.get $OFFSET_WINDOW_MUTEX)
                (local.get $value)
                (i32.const 1)
            )
        )
    )

    (func $set_buffer_len<i32>
        (param $value i32)
        
        (call $self.Reflect.apply<refx3> 
            (global.get $self.DataView:setUint32)
            (global.get $dataView)
            (call $self.Array.of<i32.i32.i32>ref 
                (global.get $OFFSET_BUFFER_LEN)
                (local.get $value)
                (i32.const 1)
            )
        )
    )

    (func $set_source_ptr<i32>
        (param $value i32)
        
        (call $self.Reflect.apply<refx3> 
            (global.get $self.DataView:setUint32)
            (global.get $dataView)
            (call $self.Array.of<i32.i32.i32>ref 
                (global.get $OFFSET_SOURCE_PTR)
                (local.get $value)
                (i32.const 1)
            )
        )
    )

    (func $set_values_ptr<i32>
        (param $value i32)
        
        (call $self.Reflect.apply<refx3> 
            (global.get $self.DataView:setUint32)
            (global.get $dataView)
            (call $self.Array.of<i32.i32.i32>ref 
                (global.get $OFFSET_VALUES_PTR)
                (local.get $value)
                (i32.const 1)
            )
        )
    )

    (func $set_target_ptr<i32>
        (param $value i32)
        
        (call $self.Reflect.apply<refx3> 
            (global.get $self.DataView:setUint32)
            (global.get $dataView)
            (call $self.Array.of<i32.i32.i32>ref 
                (global.get $OFFSET_TARGET_PTR)
                (local.get $value)
                (i32.const 1)
            )
        )
    )

    (func $get_zero<>i32
        (result i32)
        
        (call $self.Reflect.apply<refx3>i32 
            (global.get $self.DataView:getUint32)
            (global.get $dataView)
            (call $self.Array.of<i32.i32>ref 
                (global.get $OFFSET_ZERO)
                (i32.const 1)
            )
        )
    )

    (func $get_heap_ptr<>i32
        (result i32)
        
        (call $self.Reflect.apply<refx3>i32 
            (global.get $self.DataView:getUint32)
            (global.get $dataView)
            (call $self.Array.of<i32.i32>ref 
                (global.get $OFFSET_HEAP_PTR)
                (i32.const 1)
            )
        )
    )

    (func $get_capacity<>i32
        (result i32)
        
        (call $self.Reflect.apply<refx3>i32 
            (global.get $self.DataView:getUint32)
            (global.get $dataView)
            (call $self.Array.of<i32.i32>ref 
                (global.get $OFFSET_CAPACITY)
                (i32.const 1)
            )
        )
    )

    (func $get_maxlength<>i32
        (result i32)
        
        (call $self.Reflect.apply<refx3>i32 
            (global.get $self.DataView:getUint32)
            (global.get $dataView)
            (call $self.Array.of<i32.i32>ref 
                (global.get $OFFSET_MAXLENGTH)
                (i32.const 1)
            )
        )
    )

    (func $get_ready_state<>i32
        (result i32)
        
        (call $self.Reflect.apply<refx3>i32 
            (global.get $self.DataView:getUint32)
            (global.get $dataView)
            (call $self.Array.of<i32.i32>ref 
                (global.get $OFFSET_READY_STATE)
                (i32.const 1)
            )
        )
    )

    (func $get_worker_count<>i32
        (result i32)
        
        (call $self.Reflect.apply<refx3>i32 
            (global.get $self.DataView:getUint32)
            (global.get $dataView)
            (call $self.Array.of<i32.i32>ref 
                (global.get $OFFSET_WORKER_COUNT)
                (i32.const 1)
            )
        )
    )

    (func $get_active_workers<>i32
        (result i32)
        
        (call $self.Reflect.apply<refx3>i32 
            (global.get $self.DataView:getUint32)
            (global.get $dataView)
            (call $self.Array.of<i32.i32>ref 
                (global.get $OFFSET_ACTIVE_WORKERS)
                (i32.const 1)
            )
        )
    )

    (func $get_locked_workers<>i32
        (result i32)
        
        (call $self.Reflect.apply<refx3>i32 
            (global.get $self.DataView:getUint32)
            (global.get $dataView)
            (call $self.Array.of<i32.i32>ref 
                (global.get $OFFSET_LOCKED_WORKERS)
                (i32.const 1)
            )
        )
    )

    (func $get_func_index<>i32
        (result i32)
        
        (call $self.Reflect.apply<refx3>i32 
            (global.get $self.DataView:getUint32)
            (global.get $dataView)
            (call $self.Array.of<i32.i32>ref 
                (global.get $OFFSET_FUNC_INDEX)
                (i32.const 1)
            )
        )
    )

    (func $get_stride<>i32
        (result i32)
        
        (call $self.Reflect.apply<refx3>i32 
            (global.get $self.DataView:getUint32)
            (global.get $dataView)
            (call $self.Array.of<i32.i32>ref 
                (global.get $OFFSET_STRIDE)
                (i32.const 1)
            )
        )
    )

    (func $get_worker_mutex<>i32
        (result i32)
        
        (call $self.Reflect.apply<refx3>i32 
            (global.get $self.DataView:getUint32)
            (global.get $dataView)
            (call $self.Array.of<i32.i32>ref 
                (global.get $OFFSET_WORKER_MUTEX)
                (i32.const 1)
            )
        )
    )

    (func $get_window_mutex<>i32
        (result i32)
        
        (call $self.Reflect.apply<refx3>i32 
            (global.get $self.DataView:getUint32)
            (global.get $dataView)
            (call $self.Array.of<i32.i32>ref 
                (global.get $OFFSET_WINDOW_MUTEX)
                (i32.const 1)
            )
        )
    )

    (func $get_buffer_len<>i32
        (result i32)
        
        (call $self.Reflect.apply<refx3>i32 
            (global.get $self.DataView:getUint32)
            (global.get $dataView)
            (call $self.Array.of<i32.i32>ref 
                (global.get $OFFSET_BUFFER_LEN)
                (i32.const 1)
            )
        )
    )

    (func $get_source_ptr<>i32
        (result i32)
        
        (call $self.Reflect.apply<refx3>i32 
            (global.get $self.DataView:getUint32)
            (global.get $dataView)
            (call $self.Array.of<i32.i32>ref 
                (global.get $OFFSET_SOURCE_PTR)
                (i32.const 1)
            )
        )
    )

    (func $get_values_ptr<>i32
        (result i32)
        
        (call $self.Reflect.apply<refx3>i32 
            (global.get $self.DataView:getUint32)
            (global.get $dataView)
            (call $self.Array.of<i32.i32>ref 
                (global.get $OFFSET_VALUES_PTR)
                (i32.const 1)
            )
        )
    )

    (func $get_target_ptr<>i32
        (result i32)
        
        (call $self.Reflect.apply<refx3>i32 
            (global.get $self.DataView:getUint32)
            (global.get $dataView)
            (call $self.Array.of<i32.i32>ref 
                (global.get $OFFSET_TARGET_PTR)
                (i32.const 1)
            )
        )
    )

    (func $get_byteoffset<ref>i32
        (param $object externref)
        (result i32)
        
        (call $self.Reflect.get<ref.ref>i32
            (local.get $object) (table.get $extern (i32.const 17))
        )
    )

    (func $get_array_type<ref>i32
        (param $object externref)
        (result i32)
        
        (call $get_array_type<i32>i32
            (call $get_byteoffset<ref>i32
                (local.get $object)
            )
        )
    )

    (func $get_used_bytes<ref>i32
        (param $object externref)
        (result i32)
        
        (call $get_used_bytes<i32>i32
            (call $get_byteoffset<ref>i32
                (local.get $object)
            )
        )
    )

    (func $get_bytelength<ref>i32
        (param $object externref)
        (result i32)
        
        (call $get_bytelength<i32>i32
            (call $get_byteoffset<ref>i32
                (local.get $object)
            )
        )
    )

    (func $get_item_count<ref>i32
        (param $object externref)
        (result i32)
        
        (call $get_item_count<i32>i32
            (call $get_byteoffset<ref>i32
                (local.get $object)
            )
        )
    )
    
	(; externref  ;)
	(table $func 30 funcref)

    (type $math     
        (func 
            (param $source externref) 
            (param $values externref) 
            (param $target externref) 
            (result externref )
        )
    )
    
    (func $add      (export "add")     (type $math) (call $calc (global.get $OP_ADD)     (local.get 0) (local.get 1) (local.get 2)))
    (func $sub      (export "sub")     (type $math) (call $calc (global.get $OP_SUB)     (local.get 0) (local.get 1) (local.get 2)))
    (func $mul      (export "mul")     (type $math) (call $calc (global.get $OP_MUL)     (local.get 0) (local.get 1) (local.get 2)))
    (func $div      (export "div")     (type $math) (call $calc (global.get $OP_DIV)     (local.get 0) (local.get 1) (local.get 2)))
    (func $max      (export "max")     (type $math) (call $calc (global.get $OP_MAX)     (local.get 0) (local.get 1) (local.get 2)))
    (func $min      (export "min")     (type $math) (call $calc (global.get $OP_MIN)     (local.get 0) (local.get 1) (local.get 2)))
    (func $eq       (export "eq")      (type $math) (call $calc (global.get $OP_EQ)      (local.get 0) (local.get 1) (local.get 2)))
    (func $ne       (export "ne")      (type $math) (call $calc (global.get $OP_NE)      (local.get 0) (local.get 1) (local.get 2)))
    (func $lt       (export "lt")      (type $math) (call $calc (global.get $OP_LT)      (local.get 0) (local.get 1) (local.get 2)))
    (func $gt       (export "gt")      (type $math) (call $calc (global.get $OP_GT)      (local.get 0) (local.get 1) (local.get 2)))
    (func $le       (export "le")      (type $math) (call $calc (global.get $OP_LE)      (local.get 0) (local.get 1) (local.get 2)))
    (func $ge       (export "ge")      (type $math) (call $calc (global.get $OP_GE)      (local.get 0) (local.get 1) (local.get 2)))
    (func $floor    (export "floor")   (type $math) (call $calc (global.get $OP_FLOOR)   (local.get 0)     (ref.null extern) (local.get 1)))
    (func $trunc    (export "trunc")   (type $math) (call $calc (global.get $OP_TRUNC)   (local.get 0)     (ref.null extern) (local.get 1)))
    (func $ceil     (export "ceil")    (type $math) (call $calc (global.get $OP_CEIL)    (local.get 0)     (ref.null extern) (local.get 1)))
    (func $nearest  (export "nearest") (type $math) (call $calc (global.get $OP_NEAREST) (local.get 0)     (ref.null extern) (local.get 1)))
    (func $sqrt     (export "sqrt")    (type $math) (call $calc (global.get $OP_SQRT)    (local.get 0)     (ref.null extern) (local.get 1)))
    (func $abs      (export "abs")     (type $math) (call $calc (global.get $OP_ABS)     (local.get 0)     (ref.null extern) (local.get 1)))
    (func $neg      (export "neg")     (type $math) (call $calc (global.get $OP_NEG)     (local.get 0)     (ref.null extern) (local.get 1)))
    (func $and      (export "and")     (type $math) (call $calc (global.get $OP_AND)     (local.get 0) (local.get 1) (local.get 2)))
    (func $or       (export "or")      (type $math) (call $calc (global.get $OP_OR)      (local.get 0) (local.get 1) (local.get 2)))
    (func $xor      (export "xor")     (type $math) (call $calc (global.get $OP_XOR)     (local.get 0) (local.get 1) (local.get 2)))
    (func $not      (export "not")     (type $math) (call $calc (global.get $OP_NOT)     (local.get 0) (local.get 1) (local.get 2)))
    (func $shl      (export "shl")     (type $math) (call $calc (global.get $OP_SHL)     (local.get 0) (local.get 1) (local.get 2)))
    (func $shr      (export "shr")     (type $math) (call $calc (global.get $OP_SHR)     (local.get 0) (local.get 1) (local.get 2)))

    (global $target/userView (mut externref) ref.null extern)
    (global $target/mallocView (mut externref) ref.null extern)
    (global $target/needsUpdate (mut i32) (i32.const 0))

    (func $import
        (param  $userView externref)
        (param  $sourceView externref)
        (param  $isntTarget i32)
        (result i32)
        
        (local  $mallocView externref)
        (local  $isNotArray i32)
        (local  $hasSrcView i32)
        (local  $byteOffset i32)

        (local.set $isNotArray (i32.eqz (call $self.ArrayBuffer.isView<ref>i32 (local.get $userView))))
        (local.set $hasSrcView (i32.eqz (ref.is_null (local.get $sourceView))))

        (if (local.get $hasSrcView)
            (; target or values checking ;)
            (then
                (if (local.get $isntTarget)
                    (; values view check -- same buffer with zero length of source ;)
                    (then
                        (if (local.get $isNotArray)
                            (then 
                                (local.set $userView 
                                    (call $self.Reflect.apply<refx3>ref 
            (global.get $self.Uint8Array.__proto__.prototype.subarray)
                                        (local.get $sourceView) (call $self.Array.of<i32x2>ref (i32.const 0) (i32.const 0))
                                    )
                                )
                            )
                        )
                    )
                    (; target view check -- no clone needed make it source ;)
                    (else
                        (if (local.get $isNotArray)
                            (then 
                                (local.set $userView (local.get $sourceView))
                            )
                        )
                    )
                )
            )
            (; source is checking ;)
            (else (if (local.get $isNotArray) (then unreachable)))
        )

        (if (call $self.Object.is<ref.ref>i32
                (local.get $userView) (table.get $extern (i32.const 8)) (call $self.Reflect.get<refx2>ref) (global.get $buffer) 
            )
            (then
                (return (local.get $userView) (table.get $extern (i32.const 17)) (call $self.Reflect.get<refx2>i32) )
            )
        )

        (local.set $mallocView
            (call $new
                (local.get $userView) (table.get $extern (i32.const 18)) (call $self.Reflect.get<refx2>ref)                 (local.get $userView) (table.get $extern (i32.const 13)) (call $self.Reflect.get<refx2>i32)             )
        )

        (if (local.get $isntTarget)
            (then
                (call $self.Reflect.apply<refx3> 
            (global.get $self.Uint8Array.__proto__.prototype.set)
                    (local.get $mallocView) 
                    (call $self.Array.of<ref>ref
                        (local.get $userView)
                    )
                )
            )
            (else
                (global.set $target/userView (local.get $userView))
                (global.set $target/mallocView (local.get $mallocView))
                (global.set $target/needsUpdate (i32.const 1))
            )
        )

        (local.get $mallocView) (table.get $extern (i32.const 17)) (call $self.Reflect.get<refx2>i32)     )

    (func $is_mixed_space<i32.i32.i32>i32
        (param  $type_space          i32)
        (param  $source_ptr          i32)
        (param  $values_ptr          i32)
        (result i32)

        (if (i32.ne (local.get $type_space) (call $get_array_type<i32>i32 (local.get $source_ptr)))
            (then (return (i32.const 1)))
        )

        (return (i32.ne (local.get $type_space) (call $get_array_type<i32>i32 (local.get $values_ptr))))
    )

    (func $find_variant_code<i32.i32>i32
        (param  $write_length       i32)
        (param  $read_length        i32)
        (result i32)

        (if (i32.eqz (local.get $read_length))
            (then (return (global.get $VARIANT_0)))
        )

        (if (i32.eq (i32.const 1) (local.get $read_length))
            (then (return (global.get $VARIANT_1)))
        )

        (if (i32.eq (local.get $read_length) (local.get $write_length))
            (then (return (global.get $VARIANT_N)))
        )

        (if (i32.eq (local.get $read_length) (i32.div_u (local.get $write_length) (i32.const 2)))
            (then (return (global.get $VARIANT_H)))
        )

        (if (i32.eq (local.get $read_length) (i32.div_u (local.get $write_length) (i32.const 4)))
            (then (return (global.get $VARIANT_Q)))
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
            (call $get_array_type<i32>i32 (local.get $target_ptr))
        )

        (local.set $is_mixed_space  
            (call $is_mixed_space<i32.i32.i32>i32 
                (local.get $type_space) 
                (local.get $source_ptr)
                (local.get $values_ptr)
            )
        )

        (local.set $values_len
            (call $get_used_bytes<i32>i32 
                (local.get $values_ptr)
            )
        )

        (local.set $variant_code  
            (call $find_variant_code<i32.i32>i32 
                (local.get $buffer_len)
                (local.get $values_len)
            )
        )
        
        (local.set $func_index
            (i32.or
                (i32.shl (local.get $opcode) (global.get $SHIFT_OP))
                (i32.or
                    (i32.shl (local.get $type_space) (global.get $SHIFT_TYPE))
                    (local.get $variant_code)
                )
            )
        )

        (local.get $func_index)
    )

    (func $calc
        (param  $opcode               i32)
        (param  $source externref )
        (param  $values externref )
        (param  $target externref )
        (result externref )
        
        (local  $source_ptr           i32)
        (local  $values_ptr           i32)
        (local  $target_ptr           i32)
        (local  $promise externref )
        (local  $buffer_len           i32)
        (local  $func_index           i32)

        (local.set $source_ptr (call $import (local.get $source) (ref.null extern) (i32.const 1)))
        (local.set $values_ptr (call $import (local.get $values) (local.get $source) (i32.const 1)))
        (local.set $target_ptr (call $import (local.get $target) (local.get $source) (i32.const 0)))

        (local.set $buffer_len
            (call $get_used_bytes<i32>i32 
                (local.get $target_ptr)
            )
        )

        (local.set $func_index
            (call $find_func_index<i32.i32.i32.i32.i32>i32
                (local.get $opcode)
                (local.get $buffer_len)
                (local.get $source_ptr)
                (local.get $values_ptr)
                (local.get $target_ptr)
            )
        )
                
        (call $set_func_index<i32> (local.get $func_index))
        (call $set_buffer_len<i32> (local.get $buffer_len))
        (call $set_source_ptr<i32> (local.get $source_ptr))
        (call $set_values_ptr<i32> (local.get $values_ptr))
        (call $set_target_ptr<i32> (local.get $target_ptr))

        (if (i32.eq (global.get $READY_STATE_OPEN)
                (call $get_ready_state<>i32)
            ) 
            (then
                (call $set_active_workers<i32>
                    (call $notify_worker_mutex<>i32)
                )
            )
        )

        (call $self.Reflect.apply<refx3>ref 
            (global.get $self.Promise.prototype.then)
            (call $create_wait_promise<>ref)
            (call $self.Array.of<fun>ref (ref.func $ontaskcomplete<>))
        )
    )

    (func $ontaskcomplete<>
        (if (global.get $target/needsUpdate)
            (then
                (call $self.Reflect.apply<refx3> 
            (global.get $self.Uint8Array.__proto__.prototype.set)
                    (global.get $target/userView)
                    (call $self.Array.of<ref>ref (global.get $target/mallocView))
                )

                (global.set $target/userView (ref.null extern))
                (global.set $target/mallocView (ref.null extern))
                (global.set $target/needsUpdate (i32.const 0))
            )
        )
    )

    (func $notify_worker_mutex<>i32
        (result i32)

        (call $self.Atomics.notify<ref.i32.i32>i32
            (global.get $i32View) 
            (global.get $INDEX_WORKER_MUTEX)
            (call $get_worker_count<>i32)
        )
    )

    (func $create_wait_promise<>ref
        (result externref)

        (call $self.Reflect.get<ref.ref>ref
            (call $self.Atomics.waitAsync<ref.i32.i32>ref
                (global.get $i32View) 
                (global.get $INDEX_WINDOW_MUTEX) 
                (i32.const 0)
            )
            (table.get $extern (i32.const 14))
        )
    )

    (func $new
        (export "new")
        (param  $constructor externref )
        (param  $length              i32)
        (result externref )

        (local  $offset              i32)
        (local  $byteLength          i32)
        (local  $BYTES_PER_ELEMENT   i32)
        (local  $arguments externref )

        (if (i32.eqz
                (local.tee $BYTES_PER_ELEMENT 
                    (local.get $constructor) (table.get $extern (i32.const 19)) (call $self.Reflect.get<refx2>i32)                 )
            )
            (then (local.set $BYTES_PER_ELEMENT (i32.const 1)))
        )
        
        (local.set $byteLength 
            (i32.mul 
                (local.get $length) 
                (local.get $BYTES_PER_ELEMENT)
            )
        )

        (local.set $offset 
            (call $malloc
                (local.get $byteLength)
            )
        )

        (call $set_array_type<i32.i32>
            (local.get $offset) 
            (call $self.Reflect.get<ref.ref>i32
                (local.get $constructor) 
                (call $get_self_symbol<>ref)
            )
        )

        (call $set_item_count<i32.i32>
            (local.get $offset) 
            (local.get $length)
        )

        (local.set $arguments 
            (call $self.Reflect.construct<refx2>ref 
            (global.get $self.Array)  (call $self.Array.of<>ref))
        )

        (call $self.Reflect.apply<refx3> 
            (global.get $self.Array:push) (local.get $arguments) (call $self.Array.of<ref>ref (call $get_buffer<>ref)))
        (call $self.Reflect.apply<refx3> 
            (global.get $self.Array:push) (local.get $arguments) (call $self.Array.of<i32>ref (local.get $offset)))
        (call $self.Reflect.apply<refx3> 
            (global.get $self.Array:push) (local.get $arguments) (call $self.Array.of<i32>ref (local.get $length)))

        (call $self.Reflect.construct<ref.ref>ref
            (local.get $constructor)
            (local.get $arguments)
        )
    )

    (global $kSymbol.tag (mut externref) ref.null extern)
    (global $worker.code (mut externref) ref.null extern)

    (global $DEFAULT_MEMORY_INITIAL     i32 (i32.const 10))
    (global $DEFAULT_MEMORY_MAXIMUM  i32 (i32.const 65535))
    (global $DEFAULT_MEMORY_SHARED         i32 (i32.const 1))

    (global $sigint                         (mut i32) (i32.const 0))
    (global $module                      (mut externref) ref.null extern)
    (global $memory                      (mut externref) ref.null extern)
    (global $buffer                      (mut externref) ref.null extern)

    (global $i32View                     (mut externref) ref.null extern)
    (global $dataView                    (mut externref) ref.null extern)
    (global $kSymbol                     (mut externref) ref.null extern)

    (global $worker.URL                  (mut externref) ref.null extern)
    (global $worker.data                 (mut externref) ref.null extern)
    (global $worker.config               (mut externref) ref.null extern)
    (global $worker.threads (mut externref) (ref.null extern))

    (global $self.DataView (mut externref) ref.null extern)
    (global $self.Uint8Array (mut externref) ref.null extern)
    (global $self.Uint16Array (mut externref) ref.null extern)
    (global $self.Uint32Array (mut externref) ref.null extern)
    (global $self.Float32Array (mut externref) ref.null extern)
    
    (global $self.navigator.deviceMemory (mut i32) (i32.const 0))
    (global $self.navigator.hardwareConcurrency (mut i32) (i32.const 0))

    (func $this (export "this"))

    (func $create 
        (param $workerCount i32)

        (if (i32.eqz (local.get $workerCount))
            (then (local.set $workerCount (global.get $self.navigator.hardwareConcurrency)))
        )

        (call $define_self_symbols<>)
        (call $create_memory_links<>)
        
        (call $reset_memory_values<i32>
            (local.get $workerCount)
        )    
        
        (call $self.Reflect.apply<refx3> 
            (global.get $self.Promise.prototype.then)
            (call $create_wait_promise<>ref)
            (call $self.Array.of<fun>ref (ref.func $onlastworkeropen<>))
        )

        (call $create_worker_threads<>)
    )

    (func $destroy 
        (call $set_ready_state<i32>
            (global.get $READY_STATE_CLOSING)
        )

        (call $delete_self_symbols<>)
        (call $terminate_all_workers<>)

        (call $set_ready_state<i32>
            (global.get $READY_STATE_CLOSED)
        )

        (call $remove_extern_globals<>)
    )
    
    (func $remove_extern_globals<>
        (global.set $i32View        (ref.null extern))
        (global.set $dataView       (ref.null extern))
        (global.set $buffer         (ref.null extern))    
        (global.set $memory         (ref.null extern))
        (global.set $module         (ref.null extern))
        (global.set $worker.URL     (ref.null extern))
        (global.set $worker.data    (ref.null extern))
        (global.set $worker.config  (ref.null extern))
        (global.set $kSymbol        (ref.null extern))
    )

    (start $init) (func $init
(table.set $extern (i32.const 1) (call $wat4wasm/text (i32.const 0) (i32.const 4)))
		(table.set $extern (i32.const 2) (call $wat4wasm/text (i32.const 4) (i32.const 24)))
		(table.set $extern (i32.const 3) (call $wat4wasm/text (i32.const 28) (i32.const 16)))
		(table.set $extern (i32.const 4) (call $wat4wasm/text (i32.const 44) (i32.const 12)))
		(table.set $extern (i32.const 5) (call $wat4wasm/text (i32.const 56) (i32.const 28)))
		(table.set $extern (i32.const 6) (call $wat4wasm/text (i32.const 84) (i32.const 28)))
		(table.set $extern (i32.const 7) (call $wat4wasm/text (i32.const 112) (i32.const 24)))
		(table.set $extern (i32.const 8) (call $wat4wasm/text (i32.const 136) (i32.const 24)))
		(table.set $extern (i32.const 9) (call $wat4wasm/text (i32.const 160) (i32.const 24)))
		(table.set $extern (i32.const 10) (call $wat4wasm/text (i32.const 184) (i32.const 28)))
		(table.set $extern (i32.const 11) (call $wat4wasm/text (i32.const 212) (i32.const 28)))
		(table.set $extern (i32.const 12) (call $wat4wasm/text (i32.const 240) (i32.const 24)))
		(table.set $extern (i32.const 13) (call $wat4wasm/text (i32.const 264) (i32.const 24)))
		(table.set $extern (i32.const 14) (call $wat4wasm/text (i32.const 288) (i32.const 20)))
		(table.set $extern (i32.const 15) (call $wat4wasm/text (i32.const 308) (i32.const 48)))
		(table.set $extern (i32.const 16) (call $wat4wasm/text (i32.const 356) (i32.const 40)))
		(table.set $extern (i32.const 17) (call $wat4wasm/text (i32.const 396) (i32.const 40)))
		(table.set $extern (i32.const 18) (call $wat4wasm/text (i32.const 436) (i32.const 44)))
		(table.set $extern (i32.const 19) (call $wat4wasm/text (i32.const 480) (i32.const 68)))
		(table.set $extern (i32.const 20) (call $wat4wasm/text (i32.const 548) (i32.const 16)))
		(table.set $extern (i32.const 21) (call $wat4wasm/text (i32.const 564) (i32.const 20)))
		(table.set $extern (i32.const 22) (call $wat4wasm/text (i32.const 584) (i32.const 32)))
		(table.set $extern (i32.const 23) (call $wat4wasm/text (i32.const 616) (i32.const 40)))
		(table.set $extern (i32.const 24) (call $wat4wasm/text (i32.const 656) (i32.const 44)))
		(table.set $extern (i32.const 25) (call $wat4wasm/text (i32.const 700) (i32.const 44)))
		(table.set $extern (i32.const 26) (call $wat4wasm/text (i32.const 744) (i32.const 48)))
		(table.set $extern (i32.const 27) (call $wat4wasm/text (i32.const 792) (i32.const 36)))
		(table.set $extern (i32.const 28) (call $wat4wasm/text (i32.const 828) (i32.const 48)))
		(table.set $extern (i32.const 29) (call $wat4wasm/text (i32.const 876) (i32.const 76)))
		(table.set $extern (i32.const 30) (call $wat4wasm/text (i32.const 952) (i32.const 48)))
		(table.set $extern (i32.const 31) (call $wat4wasm/text (i32.const 1000) (i32.const 36)))
		(table.set $extern (i32.const 32) (call $wat4wasm/text (i32.const 1036) (i32.const 16)))
		(table.set $extern (i32.const 33) (call $wat4wasm/text (i32.const 1052) (i32.const 12)))
		(table.set $extern (i32.const 34) (call $wat4wasm/text (i32.const 1064) (i32.const 24)))
		(table.set $extern (i32.const 35) (call $wat4wasm/text (i32.const 1088) (i32.const 16)))
		(table.set $extern (i32.const 36) (call $wat4wasm/text (i32.const 1104) (i32.const 44)))
		(table.set $extern (i32.const 37) (call $wat4wasm/text (i32.const 1148) (i32.const 24)))
		(table.set $extern (i32.const 38) (call $wat4wasm/text (i32.const 1172) (i32.const 40)))
		(table.set $extern (i32.const 39) (call $wat4wasm/text (i32.const 1212) (i32.const 8)))
		(table.set $extern (i32.const 40) (call $wat4wasm/text (i32.const 1220) (i32.const 36)))
		(table.set $extern (i32.const 41) (call $wat4wasm/text (i32.const 1256) (i32.const 24)))
		(table.set $extern (i32.const 42) (call $wat4wasm/text (i32.const 1280) (i32.const 44)))
		(table.set $extern (i32.const 43) (call $wat4wasm/text (i32.const 1324) (i32.const 16)))
		(table.set $extern (i32.const 44) (call $wat4wasm/text (i32.const 1340) (i32.const 36)))
		(table.set $extern (i32.const 45) (call $wat4wasm/text (i32.const 1376) (i32.const 36)))
		(table.set $extern (i32.const 46) (call $wat4wasm/text (i32.const 1412) (i32.const 36)))
		(table.set $extern (i32.const 47) (call $wat4wasm/text (i32.const 1448) (i32.const 32)))
		(table.set $extern (i32.const 48) (call $wat4wasm/text (i32.const 1480) (i32.const 12)))
		(table.set $extern (i32.const 49) (call $wat4wasm/text (i32.const 1492) (i32.const 28)))
		(table.set $extern (i32.const 50) (call $wat4wasm/text (i32.const 1520) (i32.const 16)))
		(table.set $extern (i32.const 51) (call $wat4wasm/text (i32.const 1536) (i32.const 40)))
		(table.set $extern (i32.const 52) (call $wat4wasm/text (i32.const 1576) (i32.const 300)))

(global.set $kSymbol.tag (table.get $extern (i32.const 51)))(global.set $worker.code (table.get $extern (i32.const 52)))


        (global.set $worker.threads
            (call $wat4wasm/Reflect.construct<refx2>ref
                (call $wat4wasm/Reflect.get<refx2>ref
                    (call $wat4wasm/Reflect.get<refx2>ref 
                        (global.get $wat4wasm/self) 
                        (table.get $extern (i32.const 20)) 
                    ) (table.get $extern (i32.const 21)) 
                )
                (global.get $wat4wasm/self) 
            )
        )
        
        (global.set $self.DataView
            (call $wat4wasm/Reflect.get<refx2>ref
                (global.get $wat4wasm/self)
                (table.get $extern (i32.const 22)) 
            )
        )
        
        (global.set $self.Uint8Array
            (call $wat4wasm/Reflect.get<refx2>ref
                (global.get $wat4wasm/self)
                (table.get $extern (i32.const 23)) 
            )
        )
        
        (global.set $self.Uint16Array
            (call $wat4wasm/Reflect.get<refx2>ref
                (global.get $wat4wasm/self)
                (table.get $extern (i32.const 24)) 
            )
        )
        
        (global.set $self.Uint32Array
            (call $wat4wasm/Reflect.get<refx2>ref
                (global.get $wat4wasm/self)
                (table.get $extern (i32.const 25)) 
            )
        )
        
        (global.set $self.Float32Array
            (call $wat4wasm/Reflect.get<refx2>ref
                (global.get $wat4wasm/self)
                (table.get $extern (i32.const 26)) 
            )
        )
        
        (global.set $self.navigator.deviceMemory
            (call $wat4wasm/Reflect.get<refx2>i32
                (call $wat4wasm/Reflect.get<refx2>ref 
                        (global.get $wat4wasm/self) 
                        (table.get $extern (i32.const 27)) 
                    )
                (table.get $extern (i32.const 28)) 
            )
        )
        
        (global.set $self.navigator.hardwareConcurrency
            (call $wat4wasm/Reflect.get<refx2>i32
                (call $wat4wasm/Reflect.get<refx2>ref 
                        (global.get $wat4wasm/self) 
                        (table.get $extern (i32.const 27)) 
                    )
                (table.get $extern (i32.const 29)) 
            )
        )
        
        (global.set $self.MessageEvent.prototype.data/get
            (call $wat4wasm/Reflect.get<refx2>ref
                (call $wat4wasm/Reflect.getOwnPropertyDescriptor<refx2>ref
                    (call $wat4wasm/Reflect.get<refx2>ref 
                            (call $wat4wasm/Reflect.get<refx2>ref 
                                (global.get $wat4wasm/self) 
                                (table.get $extern (i32.const 30)) 
                            ) 
                            (table.get $extern (i32.const 31)) 
                        )
                    (table.get $extern (i32.const 32)) 
                )
                (table.get $extern (i32.const 33)) 
            )
        )
        
        (global.set $self.Worker
            (call $wat4wasm/Reflect.get<refx2>ref
                (global.get $wat4wasm/self)
                (table.get $extern (i32.const 34)) 
            )
        )
        
        (global.set $self.Blob
            (call $wat4wasm/Reflect.get<refx2>ref
                (global.get $wat4wasm/self)
                (table.get $extern (i32.const 35)) 
            )
        )
        
        (global.set $self.WebAssembly.Memory
            (call $wat4wasm/Reflect.get<refx2>ref
                (call $wat4wasm/Reflect.get<refx2>ref 
                        (global.get $wat4wasm/self) 
                        (table.get $extern (i32.const 36)) 
                    )
                (table.get $extern (i32.const 37)) 
            )
        )
        
        (global.set $self.Int32Array
            (call $wat4wasm/Reflect.get<refx2>ref
                (global.get $wat4wasm/self)
                (table.get $extern (i32.const 38)) 
            )
        )
        
        (global.set $self.Array
            (call $wat4wasm/Reflect.get<refx2>ref
                (global.get $wat4wasm/self)
                (table.get $extern (i32.const 21)) 
            )
        )
        
        (global.set $self.Array:at
            (call $wat4wasm/Reflect.get<refx2>ref
                (call $wat4wasm/Reflect.get<refx2>ref 
                            (call $wat4wasm/Reflect.get<refx2>ref 
                                (global.get $wat4wasm/self) 
                                (table.get $extern (i32.const 21)) 
                            ) 
                            (table.get $extern (i32.const 31)) 
                        )
                (table.get $extern (i32.const 39)) 
            )
        )
        
        (global.set $self.Worker:terminate
            (call $wat4wasm/Reflect.get<refx2>ref
                (call $wat4wasm/Reflect.get<refx2>ref 
                            (call $wat4wasm/Reflect.get<refx2>ref 
                                (global.get $wat4wasm/self) 
                                (table.get $extern (i32.const 34)) 
                            ) 
                            (table.get $extern (i32.const 31)) 
                        )
                (table.get $extern (i32.const 40)) 
            )
        )
        
        (global.set $self.Array:splice
            (call $wat4wasm/Reflect.get<refx2>ref
                (call $wat4wasm/Reflect.get<refx2>ref 
                            (call $wat4wasm/Reflect.get<refx2>ref 
                                (global.get $wat4wasm/self) 
                                (table.get $extern (i32.const 21)) 
                            ) 
                            (table.get $extern (i32.const 31)) 
                        )
                (table.get $extern (i32.const 41)) 
            )
        )
        
        (global.set $self.Worker:postMessage
            (call $wat4wasm/Reflect.get<refx2>ref
                (call $wat4wasm/Reflect.get<refx2>ref 
                            (call $wat4wasm/Reflect.get<refx2>ref 
                                (global.get $wat4wasm/self) 
                                (table.get $extern (i32.const 34)) 
                            ) 
                            (table.get $extern (i32.const 31)) 
                        )
                (table.get $extern (i32.const 42)) 
            )
        )
        
        (global.set $self.Array:push
            (call $wat4wasm/Reflect.get<refx2>ref
                (call $wat4wasm/Reflect.get<refx2>ref 
                            (call $wat4wasm/Reflect.get<refx2>ref 
                                (global.get $wat4wasm/self) 
                                (table.get $extern (i32.const 21)) 
                            ) 
                            (table.get $extern (i32.const 31)) 
                        )
                (table.get $extern (i32.const 43)) 
            )
        )
        
        (global.set $self.DataView:setUint32
            (call $wat4wasm/Reflect.get<refx2>ref
                (call $wat4wasm/Reflect.get<refx2>ref 
                            (call $wat4wasm/Reflect.get<refx2>ref 
                                (global.get $wat4wasm/self) 
                                (table.get $extern (i32.const 22)) 
                            ) 
                            (table.get $extern (i32.const 31)) 
                        )
                (table.get $extern (i32.const 44)) 
            )
        )
        
        (global.set $self.DataView:getUint32
            (call $wat4wasm/Reflect.get<refx2>ref
                (call $wat4wasm/Reflect.get<refx2>ref 
                            (call $wat4wasm/Reflect.get<refx2>ref 
                                (global.get $wat4wasm/self) 
                                (table.get $extern (i32.const 22)) 
                            ) 
                            (table.get $extern (i32.const 31)) 
                        )
                (table.get $extern (i32.const 45)) 
            )
        )
        
        (global.set $self.Uint8Array.__proto__.prototype
            (call $wat4wasm/Reflect.get<refx2>ref
                (call $wat4wasm/Reflect.get<refx2>ref 
                            (call $wat4wasm/Reflect.get<refx2>ref 
                                (global.get $wat4wasm/self) 
                                (table.get $extern (i32.const 23)) 
                            ) 
                            (table.get $extern (i32.const 46)) 
                        )
                (table.get $extern (i32.const 31)) 
            )
        )
        
        (global.set $self.Uint8Array.__proto__.prototype.subarray
            (call $wat4wasm/Reflect.get<refx2>ref
                (call $wat4wasm/Reflect.get<refx2>ref 
                                (call $wat4wasm/Reflect.get<refx2>ref 
                                        (call $wat4wasm/Reflect.get<refx2>ref 
                                            (global.get $wat4wasm/self) 
                                            (table.get $extern (i32.const 23)) 
                                        ) 
                                        (table.get $extern (i32.const 46)) 
                                    ) 
                                (table.get $extern (i32.const 31)) 
                            )
                (table.get $extern (i32.const 47)) 
            )
        )
        
        (global.set $self.Uint8Array.__proto__.prototype.set
            (call $wat4wasm/Reflect.get<refx2>ref
                (call $wat4wasm/Reflect.get<refx2>ref 
                                (call $wat4wasm/Reflect.get<refx2>ref 
                                        (call $wat4wasm/Reflect.get<refx2>ref 
                                            (global.get $wat4wasm/self) 
                                            (table.get $extern (i32.const 23)) 
                                        ) 
                                        (table.get $extern (i32.const 46)) 
                                    ) 
                                (table.get $extern (i32.const 31)) 
                            )
                (table.get $extern (i32.const 48)) 
            )
        )
        
        (global.set $self.Promise.prototype
            (call $wat4wasm/Reflect.get<refx2>ref
                (call $wat4wasm/Reflect.get<refx2>ref 
                        (global.get $wat4wasm/self) 
                        (table.get $extern (i32.const 49)) 
                    )
                (table.get $extern (i32.const 31)) 
            )
        )
        
        (global.set $self.Promise.prototype.then
            (call $wat4wasm/Reflect.get<refx2>ref
                (call $wat4wasm/Reflect.get<refx2>ref 
                            (call $wat4wasm/Reflect.get<refx2>ref 
                                (global.get $wat4wasm/self) 
                                (table.get $extern (i32.const 49)) 
                            ) 
                            (table.get $extern (i32.const 31)) 
                        )
                (table.get $extern (i32.const 50)) 
            )
        )
        
  (call $create (i32.const 0)))

	(global $self.MessageEvent.prototype.data/get (mut externref) ref.null extern)


	(global $self.Worker (mut externref) ref.null extern)
	(global $self.Blob (mut externref) ref.null extern)
	(global $self.WebAssembly.Memory (mut externref) ref.null extern)
	(global $self.Int32Array (mut externref) ref.null extern)
	(global $self.Array (mut externref) ref.null extern)

	(global $self.Array:at (mut externref) ref.null extern)
	(global $self.Worker:terminate (mut externref) ref.null extern)
	(global $self.Array:splice (mut externref) ref.null extern)
	(global $self.Worker:postMessage (mut externref) ref.null extern)
	(global $self.Array:push (mut externref) ref.null extern)
	(global $self.DataView:setUint32 (mut externref) ref.null extern)
	(global $self.DataView:getUint32 (mut externref) ref.null extern)
	(global $self.Uint8Array.__proto__.prototype (mut externref) ref.null extern)
	(global $self.Uint8Array.__proto__.prototype.subarray (mut externref) ref.null extern)
	(global $self.Uint8Array.__proto__.prototype.set (mut externref) ref.null extern)
	(global $self.Promise.prototype (mut externref) ref.null extern)
	(global $self.Promise.prototype.then (mut externref) ref.null extern)

	(elem $wat4wasm/refs funcref (ref.func $this) (ref.func $create) (ref.func $destroy) (ref.func $malloc) (ref.func $ontaskcomplete<>) (ref.func $onlastworkeropen<>))

    (table $extern 53 53 externref)

    (func $wat4wasm/text 
        (param $offset i32)
        (param $length i32)

        (result externref)
        
        (local $array externref)
        (local $ovalue i32)

        (if (i32.eqz (local.get $length))
            (then (return (ref.null extern)))
        )

        (local.set $array 
            (call $wat4wasm/Array<>ref)
        )

        (local.set $ovalue (i32.load (i32.const 0)))

        (loop $length--
            (local.set $length
                (i32.sub (local.get $length) (i32.const 4))
            )
                
            (memory.init $wat4wasm/text
                (i32.const 0)
                (i32.add 
                    (local.get $offset)
                    (local.get $length)
                )
                (i32.const 4)
            )        
                            
            (call $wat4wasm/Reflect.set<ref.i32x2>
                (local.get $array)
                (i32.div_u (local.get $length) (i32.const 4))
                (i32.trunc_f32_u	
                    (f32.load 
                        (i32.const 0)
                    )
                )
            )

            (br_if $length-- (local.get $length))
        )

        (i32.store (i32.const 0) (local.get $ovalue))

        (call $wat4wasm/Reflect.apply<refx3>ref
            (global.get $wat4wasm/String.fromCharCode)
            (ref.null extern)
            (local.get $array)
        )
    )

    (data $wat4wasm/text "\00\00\10\42\00\00\da\42\00\00\ca\42\00\00\da\42\00\00\de\42\00\00\e4\42\00\00\f2\42\00\00\dc\42\00\00\c2\42\00\00\da\42\00\00\ca\42\00\00\c6\42\00\00\e0\42\00\00\ea\42\00\00\d2\42\00\00\dc\42\00\00\d2\42\00\00\e8\42\00\00\d2\42\00\00\c2\42\00\00\d8\42\00\00\da\42\00\00\c2\42\00\00\f0\42\00\00\d2\42\00\00\da\42\00\00\ea\42\00\00\da\42\00\00\e6\42\00\00\d0\42\00\00\c2\42\00\00\e4\42\00\00\ca\42\00\00\c8\42\00\00\c4\42\00\00\ea\42\00\00\cc\42\00\00\cc\42\00\00\ca\42\00\00\e4\42\00\00\c6\42\00\00\e4\42\00\00\ca\42\00\00\c2\42\00\00\e8\42\00\00\ca\42\00\00\c8\42\00\00\ca\42\00\00\e6\42\00\00\e8\42\00\00\e4\42\00\00\de\42\00\00\f2\42\00\00\e8\42\00\00\d0\42\00\00\e4\42\00\00\ca\42\00\00\c2\42\00\00\c8\42\00\00\e6\42\00\00\da\42\00\00\c2\42\00\00\d8\42\00\00\d8\42\00\00\de\42\00\00\c6\42\00\00\d8\42\00\00\ca\42\00\00\dc\42\00\00\ce\42\00\00\e8\42\00\00\d0\42\00\00\ec\42\00\00\c2\42\00\00\d8\42\00\00\ea\42\00\00\ca\42\00\00\c6\42\00\00\de\42\00\00\dc\42\00\00\cc\42\00\00\d2\42\00\00\ce\42\00\00\ea\42\00\00\e4\42\00\00\c2\42\00\00\c4\42\00\00\d8\42\00\00\ca\42\00\00\ca\42\00\00\dc\42\00\00\ea\42\00\00\da\42\00\00\ca\42\00\00\e4\42\00\00\c2\42\00\00\c4\42\00\00\d8\42\00\00\ca\42\00\00\c4\42\00\00\f2\42\00\00\e8\42\00\00\ca\42\00\00\9e\42\00\00\cc\42\00\00\cc\42\00\00\e6\42\00\00\ca\42\00\00\e8\42\00\00\c6\42\00\00\de\42\00\00\dc\42\00\00\e6\42\00\00\e8\42\00\00\e4\42\00\00\ea\42\00\00\c6\42\00\00\e8\42\00\00\de\42\00\00\e4\42\00\00\84\42\00\00\b2\42\00\00\a8\42\00\00\8a\42\00\00\a6\42\00\00\be\42\00\00\a0\42\00\00\8a\42\00\00\a4\42\00\00\be\42\00\00\8a\42\00\00\98\42\00\00\8a\42\00\00\9a\42\00\00\8a\42\00\00\9c\42\00\00\a8\42\00\00\e6\42\00\00\ca\42\00\00\d8\42\00\00\cc\42\00\00\82\42\00\00\e4\42\00\00\e4\42\00\00\c2\42\00\00\f2\42\00\00\88\42\00\00\c2\42\00\00\e8\42\00\00\c2\42\00\00\ac\42\00\00\d2\42\00\00\ca\42\00\00\ee\42\00\00\aa\42\00\00\d2\42\00\00\dc\42\00\00\e8\42\00\00\60\42\00\00\82\42\00\00\e4\42\00\00\e4\42\00\00\c2\42\00\00\f2\42\00\00\aa\42\00\00\d2\42\00\00\dc\42\00\00\e8\42\00\00\44\42\00\00\58\42\00\00\82\42\00\00\e4\42\00\00\e4\42\00\00\c2\42\00\00\f2\42\00\00\aa\42\00\00\d2\42\00\00\dc\42\00\00\e8\42\00\00\4c\42\00\00\48\42\00\00\82\42\00\00\e4\42\00\00\e4\42\00\00\c2\42\00\00\f2\42\00\00\8c\42\00\00\d8\42\00\00\de\42\00\00\c2\42\00\00\e8\42\00\00\4c\42\00\00\48\42\00\00\82\42\00\00\e4\42\00\00\e4\42\00\00\c2\42\00\00\f2\42\00\00\dc\42\00\00\c2\42\00\00\ec\42\00\00\d2\42\00\00\ce\42\00\00\c2\42\00\00\e8\42\00\00\de\42\00\00\e4\42\00\00\c8\42\00\00\ca\42\00\00\ec\42\00\00\d2\42\00\00\c6\42\00\00\ca\42\00\00\9a\42\00\00\ca\42\00\00\da\42\00\00\de\42\00\00\e4\42\00\00\f2\42\00\00\d0\42\00\00\c2\42\00\00\e4\42\00\00\c8\42\00\00\ee\42\00\00\c2\42\00\00\e4\42\00\00\ca\42\00\00\86\42\00\00\de\42\00\00\dc\42\00\00\c6\42\00\00\ea\42\00\00\e4\42\00\00\e4\42\00\00\ca\42\00\00\dc\42\00\00\c6\42\00\00\f2\42\00\00\9a\42\00\00\ca\42\00\00\e6\42\00\00\e6\42\00\00\c2\42\00\00\ce\42\00\00\ca\42\00\00\8a\42\00\00\ec\42\00\00\ca\42\00\00\dc\42\00\00\e8\42\00\00\e0\42\00\00\e4\42\00\00\de\42\00\00\e8\42\00\00\de\42\00\00\e8\42\00\00\f2\42\00\00\e0\42\00\00\ca\42\00\00\c8\42\00\00\c2\42\00\00\e8\42\00\00\c2\42\00\00\ce\42\00\00\ca\42\00\00\e8\42\00\00\ae\42\00\00\de\42\00\00\e4\42\00\00\d6\42\00\00\ca\42\00\00\e4\42\00\00\84\42\00\00\d8\42\00\00\de\42\00\00\c4\42\00\00\ae\42\00\00\ca\42\00\00\c4\42\00\00\82\42\00\00\e6\42\00\00\e6\42\00\00\ca\42\00\00\da\42\00\00\c4\42\00\00\d8\42\00\00\f2\42\00\00\9a\42\00\00\ca\42\00\00\da\42\00\00\de\42\00\00\e4\42\00\00\f2\42\00\00\92\42\00\00\dc\42\00\00\e8\42\00\00\4c\42\00\00\48\42\00\00\82\42\00\00\e4\42\00\00\e4\42\00\00\c2\42\00\00\f2\42\00\00\c2\42\00\00\e8\42\00\00\e8\42\00\00\ca\42\00\00\e4\42\00\00\da\42\00\00\d2\42\00\00\dc\42\00\00\c2\42\00\00\e8\42\00\00\ca\42\00\00\e6\42\00\00\e0\42\00\00\d8\42\00\00\d2\42\00\00\c6\42\00\00\ca\42\00\00\e0\42\00\00\de\42\00\00\e6\42\00\00\e8\42\00\00\9a\42\00\00\ca\42\00\00\e6\42\00\00\e6\42\00\00\c2\42\00\00\ce\42\00\00\ca\42\00\00\e0\42\00\00\ea\42\00\00\e6\42\00\00\d0\42\00\00\e6\42\00\00\ca\42\00\00\e8\42\00\00\aa\42\00\00\d2\42\00\00\dc\42\00\00\e8\42\00\00\4c\42\00\00\48\42\00\00\ce\42\00\00\ca\42\00\00\e8\42\00\00\aa\42\00\00\d2\42\00\00\dc\42\00\00\e8\42\00\00\4c\42\00\00\48\42\00\00\be\42\00\00\be\42\00\00\e0\42\00\00\e4\42\00\00\de\42\00\00\e8\42\00\00\de\42\00\00\be\42\00\00\be\42\00\00\e6\42\00\00\ea\42\00\00\c4\42\00\00\c2\42\00\00\e4\42\00\00\e4\42\00\00\c2\42\00\00\f2\42\00\00\e6\42\00\00\ca\42\00\00\e8\42\00\00\a0\42\00\00\e4\42\00\00\de\42\00\00\da\42\00\00\d2\42\00\00\e6\42\00\00\ca\42\00\00\e8\42\00\00\d0\42\00\00\ca\42\00\00\dc\42\00\00\d6\42\00\00\82\42\00\00\e4\42\00\00\e4\42\00\00\c2\42\00\00\f2\42\00\00\a8\42\00\00\f2\42\00\00\e0\42\00\00\ca\42\00\00\de\42\00\00\dc\42\00\00\da\42\00\00\ca\42\00\00\e6\42\00\00\e6\42\00\00\c2\42\00\00\ce\42\00\00\ca\42\00\00\00\42\00\00\74\42\00\00\00\42\00\00\ca\42\00\00\00\42\00\00\74\42\00\00\78\42\00\00\00\42\00\00\9e\42\00\00\c4\42\00\00\d4\42\00\00\ca\42\00\00\c6\42\00\00\e8\42\00\00\38\42\00\00\c2\42\00\00\e6\42\00\00\e6\42\00\00\d2\42\00\00\ce\42\00\00\dc\42\00\00\20\42\00\00\e6\42\00\00\ca\42\00\00\d8\42\00\00\cc\42\00\00\30\42\00\00\ca\42\00\00\38\42\00\00\c8\42\00\00\c2\42\00\00\e8\42\00\00\c2\42\00\00\24\42\00\00\38\42\00\00\ae\42\00\00\ca\42\00\00\c4\42\00\00\82\42\00\00\e6\42\00\00\e6\42\00\00\ca\42\00\00\da\42\00\00\c4\42\00\00\d8\42\00\00\f2\42\00\00\38\42\00\00\d2\42\00\00\dc\42\00\00\e6\42\00\00\e8\42\00\00\c2\42\00\00\dc\42\00\00\e8\42\00\00\d2\42\00\00\c2\42\00\00\e8\42\00\00\ca\42\00\00\20\42\00\00\10\42\00\00\30\42\00\00\e6\42\00\00\ca\42\00\00\d8\42\00\00\cc\42\00\00\24\42")
)