/*
 * qubit algorithm
 *
 */
extern "C" {
#include "sph/sph_luffa.h"
#include "sph/sph_cubehash.h"
#include "sph/sph_shavite.h"
#include "sph/sph_simd.h"
#include "sph/sph_echo.h"
}

#include "miner.h"

#include "cuda_helper.h"
<<<<<<< HEAD
#include "x11/cuda_x11.h"

static uint32_t *d_hash[MAX_GPUS];

extern void qubit_luffa512_cpu_init(int thr_id, uint32_t threads);
extern void qubit_luffa512_cpu_setBlock_80(void *pdata);
extern void qubit_luffa512_cpu_hash_80(int thr_id, uint32_t threads, uint32_t startNounce, uint32_t *d_hash, int order);

extern "C" void qubithash(void *state, const void *input)
{
	uint8_t _ALIGN(128) hash[64];

=======

static uint32_t *d_hash[MAX_GPUS];
static uint32_t *h_found[MAX_GPUS];

extern void qubit_luffa512_cpu_init(int thr_id, uint32_t threads);
extern void qubit_luffa512_cpu_setBlock_80(void *pdata);
extern void qubit_luffa512_cpu_hash_80(int thr_id, uint32_t threads, uint32_t startNounce, uint32_t *d_outputHash);



extern void x11_cubehash512_cpu_hash_64(int thr_id, uint32_t threads, uint32_t startNounce, uint32_t *d_hash);

extern void x11_shavite512_cpu_hash_64(uint32_t threads, uint32_t startNounce, uint32_t *d_hash,uint32_t shavitethreads);

extern int x11_simd512_cpu_init(int thr_id, uint32_t threads);
extern void x11_simd512_cpu_hash_64(int thr_id, uint32_t threads, uint32_t startNounce, uint32_t *d_hash,const uint32_t simdthreads);

extern void x11_echo512_cpu_init(int thr_id, uint32_t threads);
//extern void x11_echo512_cpu_hash_64(int thr_id, uint32_t threads, uint32_t startNounce, uint32_t *d_hash);
extern void x11_echo512_cpu_hash_64_final(int thr_id, uint32_t threads, uint32_t startNounce, uint32_t *d_hash, uint32_t target, uint32_t *h_found);

extern void quark_compactTest_cpu_init(int thr_id, uint32_t threads);
extern void quark_compactTest_cpu_hash_64(int thr_id, uint32_t threads, uint32_t startNounce, uint32_t *inpHashes,
											uint32_t *d_noncesTrue, uint32_t *nrmTrue, uint32_t *d_noncesFalse, uint32_t *nrmFalse);

extern "C" void qubithash(void *state, const void *input)
{
>>>>>>> 8c320ca... added xevan
	// luffa1-cubehash2-shavite3-simd4-echo5

	sph_luffa512_context ctx_luffa;
	sph_cubehash512_context ctx_cubehash;
	sph_shavite512_context ctx_shavite;
	sph_simd512_context ctx_simd;
	sph_echo512_context ctx_echo;

<<<<<<< HEAD
=======
	uint8_t hash[64];

>>>>>>> 8c320ca... added xevan
	sph_luffa512_init(&ctx_luffa);
	sph_luffa512 (&ctx_luffa, input, 80);
	sph_luffa512_close(&ctx_luffa, (void*) hash);

	sph_cubehash512_init(&ctx_cubehash);
	sph_cubehash512 (&ctx_cubehash, (const void*) hash, 64);
	sph_cubehash512_close(&ctx_cubehash, (void*) hash);

	sph_shavite512_init(&ctx_shavite);
	sph_shavite512 (&ctx_shavite, (const void*) hash, 64);
	sph_shavite512_close(&ctx_shavite, (void*) hash);

	sph_simd512_init(&ctx_simd);
	sph_simd512 (&ctx_simd, (const void*) hash, 64);
	sph_simd512_close(&ctx_simd, (void*) hash);

	sph_echo512_init(&ctx_echo);
	sph_echo512 (&ctx_echo, (const void*) hash, 64);
	sph_echo512_close(&ctx_echo, (void*) hash);

	memcpy(state, hash, 32);
}

static bool init[MAX_GPUS] = { 0 };

<<<<<<< HEAD
extern "C" int scanhash_qubit(int thr_id, struct work* work, uint32_t max_nonce, unsigned long *hashes_done)
{
	uint32_t _ALIGN(64) endiandata[20];
	uint32_t *pdata = work->data;
	uint32_t *ptarget = work->target;
	const uint32_t first_nonce = pdata[19];
	uint32_t throughput =  cuda_default_throughput(thr_id, 1U << 19); // 256*256*8
	if (init[thr_id]) throughput = min(throughput, max_nonce - first_nonce);

	if (opt_benchmark)
		ptarget[7] = 0x007f;

	if (!init[thr_id])
	{
		cudaSetDevice(device_map[thr_id]);
		if (opt_cudaschedule == -1 && gpu_threads == 1) {
			cudaDeviceReset();
			// reduce cpu usage
			cudaSetDeviceFlags(cudaDeviceScheduleBlockingSync);
			CUDA_LOG_ERROR();
		}
		gpulog(LOG_INFO, thr_id, "Intensity set to %g, %u cuda threads", throughput2intensity(throughput), throughput);

		qubit_luffa512_cpu_init(thr_id, throughput);
		x11_cubehash512_cpu_init(thr_id, throughput);
		x11_shavite512_cpu_init(thr_id, throughput);
		x11_simd512_cpu_init(thr_id, throughput);
		x11_echo512_cpu_init(thr_id, throughput);

		CUDA_CALL_OR_RET_X(cudaMalloc(&d_hash[thr_id], (size_t) 64 * throughput), 0);
=======
extern "C" int scanhash_qubit(int thr_id, uint32_t *pdata,
	const uint32_t *ptarget, uint32_t max_nonce,
	unsigned long *hashes_done)
{
	uint32_t endiandata[20];
	const uint32_t first_nonce = pdata[19];

	uint32_t intensity = 256 * 256 * 10;
	uint32_t simdthreads = (device_sm[device_map[thr_id]] > 500) ? 64 : 32;
	uint32_t shavitethreads = (device_sm[device_map[thr_id]] == 500) ? 256 : 320;
	static uint32_t throughput;

	if (opt_benchmark)
		((uint32_t*)ptarget)[7] = 0x4f;

	if (!init[thr_id])
	{

		cudaDeviceProp props;
		cudaGetDeviceProperties(&props, device_map[thr_id]);
		if (strstr(props.name, "970"))
		{
			intensity = 256 * 256 * 24;
		}
		else if (strstr(props.name, "980"))
		{
			intensity = 256 * 256 * 24;
		}
		else if (strstr(props.name, "750 Ti"))
		{
			intensity = 256 * 256 * 12;
		}
		else if (strstr(props.name, "750"))
		{
			intensity = 256 * 256 * 10;
		}
		else if (strstr(props.name, "960"))
		{
			intensity = 256 * 256 * 23;
		}
		else if (strstr(props.name, "950"))
		{
			intensity = 256 * 256 * 23;
		}
		throughput = device_intensity(device_map[thr_id], __func__, intensity);

		throughput = min(throughput, (max_nonce - first_nonce));

		cudaSetDevice(device_map[thr_id]);
		if (!opt_cpumining) cudaSetDeviceFlags(cudaDeviceScheduleBlockingSync);
		if (opt_n_gputhreads == 1)
		{
			cudaDeviceSetCacheConfig(cudaFuncCachePreferL1);
		}

		qubit_luffa512_cpu_init(thr_id, throughput);
		x11_simd512_cpu_init(thr_id, throughput);
		x11_echo512_cpu_init(thr_id, throughput);

		CUDA_CALL_OR_RET_X(cudaMalloc(&d_hash[thr_id], 16 * sizeof(uint32_t) * throughput), 0);
		CUDA_CALL_OR_RET_X(cudaMallocHost(&(h_found[thr_id]), 4 * sizeof(uint32_t)), 0);
>>>>>>> 8c320ca... added xevan

		cuda_check_cpu_init(thr_id, throughput);

		init[thr_id] = true;
	}

	for (int k=0; k < 20; k++)
<<<<<<< HEAD
		be32enc(&endiandata[k], pdata[k]);
=======
		be32enc(&endiandata[k], ((uint32_t*)pdata)[k]);
>>>>>>> 8c320ca... added xevan

	qubit_luffa512_cpu_setBlock_80((void*)endiandata);
	cuda_check_cpu_setTarget(ptarget);

	do {
<<<<<<< HEAD
		int order = 0;

		// Hash with CUDA
		qubit_luffa512_cpu_hash_80(thr_id, throughput, pdata[19], d_hash[thr_id], order++);
		x11_cubehash512_cpu_hash_64(thr_id, throughput, pdata[19], NULL, d_hash[thr_id], order++);
		x11_shavite512_cpu_hash_64(thr_id, throughput, pdata[19], NULL, d_hash[thr_id], order++);
		x11_simd512_cpu_hash_64(thr_id, throughput, pdata[19], NULL, d_hash[thr_id], order++);
		x11_echo512_cpu_hash_64(thr_id, throughput, pdata[19], NULL, d_hash[thr_id], order++);

		*hashes_done = pdata[19] - first_nonce + throughput;

		work->nonces[0] = cuda_check_hash(thr_id, throughput, pdata[19], d_hash[thr_id]);
		if (work->nonces[0] != UINT32_MAX)
		{
			const uint32_t Htarg = ptarget[7];
			uint32_t _ALIGN(64) vhash[8];
			be32enc(&endiandata[19], work->nonces[0]);
			qubithash(vhash, endiandata);

			if (vhash[7] <= Htarg && fulltest(vhash, ptarget)) {
				work->valid_nonces = 1;
				work_set_target_ratio(work, vhash);
				work->nonces[1] = cuda_check_hash_suppl(thr_id, throughput, pdata[19], d_hash[thr_id], 1);
				if (work->nonces[1] != 0) {
					be32enc(&endiandata[19], work->nonces[1]);
					qubithash(vhash, endiandata);
					bn_set_target_ratio(work, vhash, 1);
					work->valid_nonces++;
					pdata[19] = max(work->nonces[0], work->nonces[1]) + 1;
				} else {
					pdata[19] = work->nonces[0] + 1; // cursor
				}
				return work->valid_nonces;
			}
			else if (vhash[7] > Htarg) {
				gpu_increment_reject(thr_id);
				if (!opt_quiet)
				gpulog(LOG_WARNING, thr_id, "result for %08x does not validate on CPU!", work->nonces[0]);
				pdata[19] = work->nonces[0] + 1;
				continue;
			}
		}

		if ((uint64_t) throughput + pdata[19] >= max_nonce) {
			pdata[19] = max_nonce;
			break;
		}
		pdata[19] += throughput;

	} while (!work_restart[thr_id].restart);
=======

		// Hash with CUDA
		qubit_luffa512_cpu_hash_80(thr_id, throughput, pdata[19], d_hash[thr_id]);
		x11_cubehash512_cpu_hash_64(thr_id, throughput, pdata[19], d_hash[thr_id]);
		x11_shavite512_cpu_hash_64(throughput, pdata[19], d_hash[thr_id],shavitethreads);
		x11_simd512_cpu_hash_64(thr_id,throughput, pdata[19], d_hash[thr_id],simdthreads);
		x11_echo512_cpu_hash_64_final(thr_id, throughput, pdata[19], d_hash[thr_id], ptarget[7], h_found[thr_id]);
		if (h_found[thr_id][0] != 0xffffffff)
		{
			const uint32_t Htarg = ptarget[7];
			uint32_t vhash64[8];
			be32enc(&endiandata[19], h_found[thr_id][0]);
			qubithash(vhash64, endiandata);

			if (vhash64[7] <= Htarg && fulltest(vhash64, ptarget))
			{
				int res = 1;
				// check if there was some other ones...
				*hashes_done = pdata[19] - first_nonce + throughput;
				if (h_found[thr_id][1] != 0xffffffff)
				{
					pdata[21] = h_found[thr_id][1];
					res++;
					if (opt_benchmark)
						applog(LOG_INFO, "GPU #%d Found second nounce %08x", thr_id, h_found[thr_id][1], vhash64[7], Htarg);
				}
				pdata[19] = h_found[thr_id][0];
				if (opt_benchmark)
					applog(LOG_INFO, "GPU #%d Found nounce %08x", thr_id, h_found[thr_id][0], vhash64[7], Htarg);
				return res;
			}
			else
			{
				if (vhash64[7] != Htarg)
				{
					applog(LOG_INFO, "GPU #%d: result for %08x does not validate on CPU!", thr_id, h_found[thr_id][0]);
				}
			}
		}

		pdata[19] += throughput;
	} while (!scan_abort_flag && !work_restart[thr_id].restart && ((uint64_t)max_nonce > ((uint64_t)(pdata[19]) + (uint64_t)throughput)));
>>>>>>> 8c320ca... added xevan

	*hashes_done = pdata[19] - first_nonce;
	return 0;
}
<<<<<<< HEAD

// cleanup
extern "C" void free_qubit(int thr_id)
{
	if (!init[thr_id])
		return;

	cudaThreadSynchronize();

	cudaFree(d_hash[thr_id]);

	x11_simd512_cpu_free(thr_id);

	cuda_check_cpu_free(thr_id);
	init[thr_id] = false;

	cudaDeviceSynchronize();
}
=======
>>>>>>> 8c320ca... added xevan
