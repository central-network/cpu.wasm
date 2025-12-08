
async function init() {
    console.log("Initializing Multi-Chain Architecture Test...");

    const memory = new WebAssembly.Memory({
        initial: 10,
        maximum: 10,
        shared: true
    });

    const f32 = new Float32Array(memory.buffer);
    const i32 = new Int32Array(memory.buffer);
    const u8 = new Uint8Array(memory.buffer);

    const WORKER_MEMORY_BASE = 5120;
    const WORKER_HEADER_SIZE = 64;
    const GLOBAL_HEADER_SIZE = 64;

    // Chain Block locations
    const CHAIN_1_PTR = 10000;
    const CHAIN_2_PTR = 15000;

    // Result locations
    const RESULT_1 = 20000;
    const RESULT_2 = 20004;

    try {
        const [workerBytes, taskBytes, managerBytes] = await Promise.all([
            fetch('chain_worker.wasm').then(r => r.arrayBuffer()),
            fetch('chain_task.wasm').then(r => r.arrayBuffer()),
            fetch('chain_manager.wasm').then(r => r.arrayBuffer())
        ]);

        const workerModule = await WebAssembly.compile(workerBytes);
        const taskModule = await WebAssembly.compile(taskBytes);
        const managerModule = await WebAssembly.compile(managerBytes);

        const managerInstance = await WebAssembly.instantiate(managerModule, {
            env: { memory: memory }
        });

        // Initialize and REGISTER Chain 1
        console.log("Initializing Chain 1...");
        managerInstance.exports.init_chain(CHAIN_1_PTR);
        const idx1 = managerInstance.exports.register_chain(CHAIN_1_PTR);
        console.log(`Chain 1 registered at index ${idx1}`);

        // Initialize and REGISTER Chain 2
        console.log("Initializing Chain 2...");
        managerInstance.exports.init_chain(CHAIN_2_PTR);
        const idx2 = managerInstance.exports.register_chain(CHAIN_2_PTR);
        console.log(`Chain 2 registered at index ${idx2}`);

        // Verify chain count
        const chainCount = managerInstance.exports.get_chain_count();
        console.log(`Total registered chains: ${chainCount}`);

        // Setup Task 0 in Chain 1: 10 + 20 = 30
        const t1_ptr = CHAIN_1_PTR + 128;
        i32[(t1_ptr + 0) >> 2] = -1;
        i32[(t1_ptr + 32) >> 2] = 1;
        i32[(t1_ptr + 64) >> 2] = 16000;
        i32[(16000 + 0) >> 2] = 1; // ADD
        f32[(16000 + 4) >> 2] = 10.0;
        f32[(16000 + 8) >> 2] = 20.0;
        i32[(16000 + 12) >> 2] = RESULT_1;

        // Setup Task 0 in Chain 2: 5 * 6 = 30
        const t2_ptr = CHAIN_2_PTR + 128;
        i32[(t2_ptr + 0) >> 2] = -1;
        i32[(t2_ptr + 32) >> 2] = 1;
        i32[(t2_ptr + 64) >> 2] = 17000;
        i32[(17000 + 0) >> 2] = 3; // MUL
        f32[(17000 + 4) >> 2] = 5.0;
        f32[(17000 + 8) >> 2] = 6.0;
        i32[(17000 + 12) >> 2] = RESULT_2;

        // Activate both tasks
        console.log("Activating Task 0 in both chains...");
        managerInstance.exports.activate_task(CHAIN_1_PTR, 0);
        managerInstance.exports.activate_task(CHAIN_2_PTR, 0);

        // Spawn Workers (they will auto-discover chains!)
        const workerCount = 2;
        const workers = [];

        const workerCode = `
onmessage = async (e) => {
    const { memory, workerModule, taskModule, id } = e.data;
    try {
        const env = { 
            memory, 
            worker_index: id, 
            performance_now: performance.now.bind(performance) 
        };
        const taskInstance = await WebAssembly.instantiate(taskModule, { env });
        const workerInstance = await WebAssembly.instantiate(workerModule, {
            env,
            task: { execute_task: taskInstance.exports.execute_task }
        });
        if (workerInstance.exports.start) {
            workerInstance.exports.start();  // NO parameters at all!
        }
    } catch (err) {
        console.error(\`Worker \${id} Error:\`, err);
    }
};
        `;

        const blob = new Blob([workerCode], { type: 'application/javascript' });
        const workerUrl = URL.createObjectURL(blob);

        for (let i = 0; i < workerCount; i++) {
            const worker = new Worker(workerUrl);
            workers.push(worker);
            worker.postMessage({
                memory: memory,
                workerModule: workerModule,
                taskModule: taskModule,
                id: i
                // NO chainPtr needed - workers discover via registry!
            });
        }

        let interval = setInterval(() => {
            const r1 = f32[RESULT_1 >> 2];
            const r2 = f32[RESULT_2 >> 2];
            console.log(`Chain1 Result: ${r1} (Exp 30), Chain2 Result: ${r2} (Exp 30)`);

            if (r1 === 30 && r2 === 30) {
                console.log("✅ MULTI-CHAIN SUCCESS! Both chains processed!");
            }
        }, 500);

        setTimeout(() => {
            console.log("Sending CLOSE command...");
            for (let i = 0; i < workerCount; i++) {
                const base = WORKER_MEMORY_BASE + GLOBAL_HEADER_SIZE + (i * WORKER_HEADER_SIZE);
                Atomics.store(i32, (base + 4) >> 2, 2);
            }
        }, 4000);

        setTimeout(() => {
            clearInterval(interval);
            console.log("Test Finished.");
        }, 5000);

    } catch (e) {
        console.error("Test Failed:", e);
    }
}

init();
