/**
 * Fresh algorithm
 */
extern "C" {
#include "sph/sph_shavite.h"
#include "sph/sph_simd.h"
#include "sph/sph_echo.h"
}
#include "miner.h"
#include "cuda_helper.h"

// to test gpu hash on a null buffer
#define NULLTEST 0

static uint32_t *d_hash[MAX_GPUS];
<<<<<<< HEAD

extern void x11_shavite512_cpu_init(int thr_id, uint32_t threads);
extern void x11_shavite512_setBlock_80(void *pdata);
extern void x11_shavite512_cpu_hash_80(int thr_id, uint32_t threads, uint32_t startNounce, uint32_t *d_hash, int order);
extern void x11_shavite512_cpu_hash_64(int thr_id, uint32_t threads, uint32_t startNounce, uint32_t *d_nonceVector, uint32_t *d_hash, int order);

extern int  x11_simd512_cpu_init(int thr_id, uint32_t threads);
extern void x11_simd512_cpu_hash_64(int thr_id, uint32_t threads, uint32_t startNounce, uint32_t *d_nonceVector, uint32_t *d_hash, int order);
extern void x11_simd512_cpu_free(int thr_id);

extern void x11_echo512_cpu_init(int thr_id, uint32_t threads);
extern void x11_echo512_cpu_hash_64(int thr_id, uint32_t threads, uint32_t startNounce, uint32_t *d_nonceVector, uint32_t *d_hash, int order);

=======
static uint32_t *h_found[MAX_GPUS];

extern void x11_shavite512_setBlock_80(void *pdata);
extern void x11_shavite512_cpu_hash_80(uint32_t threads, uint32_t startNounce, uint32_t *d_hash);
extern void x11_shavite512_cpu_hash_64(uint32_t threads, uint32_t startNounce, uint32_t *d_hash, uint32_t shavitethreads);

extern int  x11_simd512_cpu_init(int thr_id, uint32_t threads);
extern void x11_simd512_cpu_hash_64(int thr_id, uint32_t threads, uint32_t startNounce, uint32_t *d_hash, const uint32_t simdthreads);

extern void x11_echo512_cpu_init(int thr_id, uint32_t threads);
//extern void x11_echo512_cpu_hash_64(int thr_id, uint32_t threads, uint32_t startNounce, uint32_t *d_nonceVector, uint32_t *d_hash);
extern void x11_echo512_cpu_hash_64_final(int thr_id, uint32_t threads, uint32_t startNounce, uint32_t *d_hash, uint32_t target, uint32_t *h_found);

extern void quark_compactTest_cpu_init(int thr_id, uint32_t threads);
extern void quark_compactTest_cpu_hash_64(int thr_id, uint32_t threads, uint32_t startNounce, uint32_t *inpHashes,
											uint32_t *d_noncesTrue, uint32_t *nrmTrue, uint32_t *d_noncesFalse, uint32_t *nrmFalse);
>>>>>>> 8c320ca... added xevan

// CPU Hash
extern "C" void fresh_hash(void *state, const void *input)
{
	// shavite-simd-shavite-simd-echo

	sph_shavite512_context ctx_shavite;
	sph_simd512_context ctx_simd;
	sph_echo512_context ctx_echo;

	unsigned char hash[128]; // uint32_t hashA[16], hashB[16];
	#define hashA hash
	#define hashB hash+64

	memset(hash, 0, sizeof hash);

	sph_shavite512_init(&ctx_shavite);
	sph_shavite512(&ctx_shavite, input, 80);
	sph_shavite512_close(&ctx_shavite, hashA);

	sph_simd512_init(&ctx_simd);
	sph_simd512(&ctx_simd, hashA, 64);
	sph_simd512_close(&ctx_simd, hashB);

	sph_shavite512_init(&ctx_shavite);
	sph_shavite512(&ctx_shavite, hashB, 64);
	sph_shavite512_close(&ctx_shavite, hashA);

	sph_simd512_init(&ctx_simd);
	sph_simd512(&ctx_simd, hashA, 64);
	sph_simd512_close(&ctx_simd, hashB);

	sph_echo512_init(&ctx_echo);
	sph_echo512(&ctx_echo, hashB, 64);
	sph_echo512_close(&ctx_echo, hashA);

	memcpy(state, hash, 32);
}

static bool init[MAX_GPUS] = { 0 };

<<<<<<< HEAD
extern "C" int scanhash_fresh(int thr_id, struct work* work, uint32_t max_nonce, unsigned long *hashes_done)
{
	uint32_t *pdata = work->data;
	uint32_t *ptarget = work->target;
	const uint32_t first_nonce = pdata[19];
	uint32_t endiandata[20];

	uint32_t throughput =  cuda_default_throughput(thr_id, 1 << 19);
	if (init[thr_id]) throughput = min(throughput, max_nonce - first_nonce);

	if (opt_benchmark)
		ptarget[7] = 0x00ff;
=======
extern "C" int scanhash_fresh(int thr_id, uint32_t *pdata,
	const uint32_t *ptarget, uint32_t max_nonce,
	unsigned long *hashes_done)
{
	const uint32_t first_nonce = pdata[19];
	uint32_t endiandata[20];

	uint32_t throughput = device_intensity(device_map[thr_id], __func__, 1 << 19);
	throughput = min(throughput, (max_nonce - first_nonce));
	uint32_t simdthreads = (device_sm[device_map[thr_id]] > 500) ? 64 : 32;
	uint32_t shavitethreads = (device_sm[device_map[thr_id]] == 500) ? 256 : 320;

	if (opt_benchmark)
		((uint32_t*)ptarget)[7] = 0xf;
>>>>>>> 8c320ca... added xevan

	if (!init[thr_id])
	{
		cudaSetDevice(device_map[thr_id]);
<<<<<<< HEAD
		if (opt_cudaschedule == -1 && gpu_threads == 1) {
			cudaDeviceReset();
			// reduce cpu usage
			cudaSetDeviceFlags(cudaDeviceScheduleBlockingSync);
			CUDA_LOG_ERROR();
		}
		gpulog(LOG_INFO, thr_id, "Intensity set to %g, %u cuda threads", throughput2intensity(throughput), throughput);

		CUDA_CALL_OR_RET_X(cudaMalloc(&d_hash[thr_id], (size_t)64 * throughput + 4), -1);

		x11_shavite512_cpu_init(thr_id, throughput);
		x11_simd512_cpu_init(thr_id, throughput);
		x11_echo512_cpu_init(thr_id, throughput);

=======
		if (!opt_cpumining) cudaSetDeviceFlags(cudaDeviceScheduleBlockingSync);
		if (opt_n_gputhreads == 1)
		{
			cudaDeviceSetCacheConfig(cudaFuncCachePreferL1);
		}

		x11_simd512_cpu_init(thr_id, throughput);
		x11_echo512_cpu_init(thr_id, throughput);

		CUDA_CALL_OR_RET_X(cudaMalloc(&d_hash[thr_id], 16 * sizeof(uint32_t) * throughput + 4), 0);
		CUDA_CALL_OR_RET_X(cudaMallocHost(&(h_found[thr_id]), 4 * sizeof(uint32_t)), 0);

>>>>>>> 8c320ca... added xevan
		cuda_check_cpu_init(thr_id, throughput);

		init[thr_id] = true;
	}

	for (int k=0; k < 20; k++)
<<<<<<< HEAD
		be32enc(&endiandata[k], pdata[k]);
	
	x11_shavite512_setBlock_80((void*)endiandata);
	cuda_check_cpu_setTarget(ptarget);
	do {
		int order = 0;

		// GPU Hash
		x11_shavite512_cpu_hash_80(thr_id, throughput, pdata[19], d_hash[thr_id], order++);
		x11_simd512_cpu_hash_64(thr_id, throughput, pdata[19], NULL, d_hash[thr_id], order++);
		x11_shavite512_cpu_hash_64(thr_id, throughput, pdata[19], NULL, d_hash[thr_id], order++);
		x11_simd512_cpu_hash_64(thr_id, throughput, pdata[19], NULL, d_hash[thr_id], order++);
		x11_echo512_cpu_hash_64(thr_id, throughput, pdata[19], NULL, d_hash[thr_id], order++);

#if NULLTEST
		uint32_t buf[8]; memset(buf, 0, sizeof buf);
		CUDA_SAFE_CALL(cudaMemcpy(buf, d_hash[thr_id], sizeof buf, cudaMemcpyDeviceToHost));
		CUDA_SAFE_CALL(cudaThreadSynchronize());
		print_hash((unsigned char*)buf); printf("\n");
#endif
		*hashes_done = pdata[19] - first_nonce + throughput;

		work->nonces[0] = cuda_check_hash(thr_id, throughput, pdata[19], d_hash[thr_id]);
		if (work->nonces[0] != UINT32_MAX)
		{
			const uint32_t Htarg = ptarget[7];
			uint32_t _ALIGN(64) vhash[8];
			be32enc(&endiandata[19], work->nonces[0]);
			fresh_hash(vhash, endiandata);

			if (vhash[7] <= Htarg && fulltest(vhash, ptarget)) {
				work->valid_nonces = 1;
				work->nonces[1] = cuda_check_hash_suppl(thr_id, throughput, pdata[19], d_hash[thr_id], 1);
				work_set_target_ratio(work, vhash);
				if (work->nonces[1] != 0) {
					be32enc(&endiandata[19], work->nonces[1]);
					fresh_hash(vhash, endiandata);
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
			}
		}

		if ((uint64_t) throughput + pdata[19] >= max_nonce) {
			pdata[19] = max_nonce;
			break;
		}
		pdata[19] += throughput;

	} while (!work_restart[thr_id].restart);

	*hashes_done = pdata[19] - first_nonce + 1;
	return 0;
}

// cleanup
extern "C" void free_fresh(int thr_id)
{
	if (!init[thr_id])
		return;

	cudaSetDevice(device_map[thr_id]);

	cudaFree(d_hash[thr_id]);
	x11_simd512_cpu_free(thr_id);

	cuda_check_cpu_free(thr_id);
	init[thr_id] = false;

	cudaDeviceSynchronize();
}
=======
		be32enc(&endiandata[k], ((uint32_t*)pdata)[k]);
	
	x11_shavite512_setBlock_80((void*)endiandata);

	do {
		uint32_t Htarg = ptarget[7];

	//	uint32_t foundNonce;

		// GPU Hash

		x11_shavite512_cpu_hash_80(throughput, pdata[19], d_hash[thr_id]);
		x11_simd512_cpu_hash_64(thr_id, throughput, pdata[19], d_hash[thr_id], simdthreads);
		x11_shavite512_cpu_hash_64(throughput, pdata[19], d_hash[thr_id], shavitethreads);
		x11_simd512_cpu_hash_64(thr_id, throughput, pdata[19], d_hash[thr_id], simdthreads);
		x11_echo512_cpu_hash_64_final(thr_id, throughput, pdata[19], d_hash[thr_id], ptarget[7], h_found[thr_id]);

	//	cudaDeviceSynchronize();
		if (h_found[thr_id][0] != 0xffffffff)
		{
			uint32_t vhash64[8];
			be32enc(&endiandata[19], h_found[thr_id][0]);
			fresh_hash(vhash64, endiandata);

			if (vhash64[7] <= Htarg && fulltest(vhash64, ptarget))
			{
				int res = 1;
				*hashes_done = pdata[19] - first_nonce + throughput;
				if (opt_benchmark)
					applog(LOG_INFO, "GPU #%d Found nounce %08x", thr_id, h_found[thr_id][0], vhash64[7], Htarg);

				if (h_found[thr_id][1] != 0xffffffff)
				{
					pdata[21] =h_found[thr_id][1];
					res++;
				}
				pdata[19] = h_found[thr_id][0];
				return res;
			}
			else
			{
				if(vhash64[7] != Htarg) applog(LOG_INFO, "GPU #%d: result for %08x does not validate on CPU!", thr_id, h_found[thr_id][0]);
			}
		}
		pdata[19] += throughput;
	} while (!scan_abort_flag && !work_restart[thr_id].restart && ((uint64_t)max_nonce > ((uint64_t)(pdata[19]) + (uint64_t)throughput)));

	*hashes_done = pdata[19] - first_nonce;
	return 0;
}
>>>>>>> 8c320ca... added xevan
