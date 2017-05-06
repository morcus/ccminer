/*
 * whirlpool routine (djm)
<<<<<<< HEAD
 * whirlpoolx routine (provos alexis, tpruvot)
 */
extern "C" {
#include "sph/sph_whirlpool.h"
}

#include "miner.h"
#include "cuda_helper.h"

static uint32_t *d_hash[MAX_GPUS] = { 0 };

extern void whirlpoolx_cpu_init(int thr_id, uint32_t threads);
extern void whirlpoolx_cpu_free(int thr_id);
extern void whirlpoolx_setBlock_80(void *pdata, const void *ptarget);
extern uint32_t whirlpoolx_cpu_hash(int thr_id, uint32_t threads, uint32_t startNounce);
=======
 * whirlpoolx routine (provos alexis)
 */
extern "C"
{
#include "sph/sph_whirlpool.h"
#include "miner.h"
}

#include "cuda_helper.h"

extern void whirlpoolx_cpu_init(int thr_id, uint32_t threads);
extern void whirlpoolx_setBlock_80(void *pdata, const void *ptarget);
extern void cpu_whirlpoolx(int thr_id, uint32_t threads, uint32_t startNounce, uint32_t *foundNonce);
>>>>>>> 8c320ca... added xevan
extern void whirlpoolx_precompute(int thr_id);

// CPU Hash function
extern "C" void whirlxHash(void *state, const void *input)
{
<<<<<<< HEAD
=======

>>>>>>> 8c320ca... added xevan
	sph_whirlpool_context ctx_whirlpool;

	unsigned char hash[64];
	unsigned char hash_xored[32];

<<<<<<< HEAD
=======
	memset(hash, 0, sizeof(hash));

>>>>>>> 8c320ca... added xevan
	sph_whirlpool_init(&ctx_whirlpool);
	sph_whirlpool(&ctx_whirlpool, input, 80);
	sph_whirlpool_close(&ctx_whirlpool, hash);

<<<<<<< HEAD
	// compress the 48 first bytes of the hash to 32
	for (int i = 0; i < 32; i++) {
		hash_xored[i] = hash[i] ^ hash[i + 16];
=======
    
	for (uint32_t i = 0; i < 32; i++){
	        hash_xored[i] = hash[i] ^ hash[i + 16];
>>>>>>> 8c320ca... added xevan
	}
	memcpy(state, hash_xored, 32);
}

static bool init[MAX_GPUS] = { 0 };

<<<<<<< HEAD
extern "C" int scanhash_whirlx(int thr_id,  struct work* work, uint32_t max_nonce, unsigned long *hashes_done)
{
	uint32_t *pdata = work->data;
	uint32_t *ptarget = work->target;
	const uint32_t first_nonce = pdata[19];
	uint32_t endiandata[20];
	int intensity = is_windows() ? 20 : 22;
	uint32_t throughput = cuda_default_throughput(thr_id, 1U << intensity);
	if (init[thr_id]) throughput = min(throughput, max_nonce - first_nonce);

	if (opt_benchmark)
		ptarget[7] = 0x000f;

	if (!init[thr_id]) {
		cudaSetDevice(device_map[thr_id]);
		if (opt_cudaschedule == -1 && gpu_threads == 1) {
			cudaDeviceReset();
			// reduce cpu usage
			cudaSetDeviceFlags(cudaDeviceScheduleBlockingSync);
			CUDA_LOG_ERROR();
		}
		gpulog(LOG_INFO, thr_id, "Intensity set to %g, %u cuda threads", throughput2intensity(throughput), throughput);

		CUDA_CALL_OR_RET_X(cudaMalloc(&d_hash[thr_id], (size_t) 64 * throughput), -1);

		whirlpoolx_cpu_init(thr_id, throughput);

		init[thr_id] = true;
	}

	for (int k=0; k < 20; k++) {
		be32enc(&endiandata[k], pdata[k]);
	}

	whirlpoolx_setBlock_80((void*)endiandata, ptarget);
	whirlpoolx_precompute(thr_id);

	do {
		uint32_t foundNonce = whirlpoolx_cpu_hash(thr_id, throughput, pdata[19]);

		*(hashes_done) = pdata[19] - first_nonce + throughput;

		if (foundNonce != UINT32_MAX && bench_algo < 0)
		{
			const uint32_t Htarg = ptarget[7];
			uint32_t vhash64[8];
			be32enc(&endiandata[19], foundNonce);
			whirlxHash(vhash64, endiandata);

			if (vhash64[7] <= Htarg && fulltest(vhash64, ptarget)) {
				work_set_target_ratio(work, vhash64);
				pdata[19] = foundNonce;
				return 1;
			} else {
				gpulog(LOG_WARNING, thr_id, "result for %08x does not validate on CPU!", foundNonce);
			}
		}

		if ((uint64_t)throughput + pdata[19] >= max_nonce) {
			pdata[19] = max_nonce;
			break;
		}

		pdata[19] += throughput;

	} while (!work_restart[thr_id].restart);

	*(hashes_done) = pdata[19] - first_nonce;

	return 0;
}

// cleanup
extern "C" void free_whirlx(int thr_id)
{
	if (!init[thr_id])
		return;

	cudaThreadSynchronize();

	cudaFree(d_hash[thr_id]);

	whirlpoolx_cpu_free(thr_id);
	init[thr_id] = false;

	cudaDeviceSynchronize();
}
=======
int scanhash_whirlpoolx(int thr_id, uint32_t *pdata, uint32_t *ptarget, uint32_t max_nonce, uint32_t *hashes_done)
{
	uint32_t foundNonce[MAX_GPUS][4];
	const uint32_t first_nonce = pdata[19];
	uint32_t endiandata[20];
	uint32_t throughput = device_intensity(device_map[thr_id], __func__, (1 << 25));
	throughput = min(throughput, max_nonce - first_nonce);
	if (opt_benchmark)
		ptarget[7] = 0x5;

	if (!init[thr_id])
	{
		CUDA_SAFE_CALL(cudaSetDevice(device_map[thr_id]));
		if (!opt_cpumining) cudaSetDeviceFlags(cudaDeviceScheduleBlockingSync);
		if (opt_n_gputhreads == 1)
		{
			cudaDeviceSetCacheConfig(cudaFuncCachePreferL1);
		}
		whirlpoolx_cpu_init(thr_id, throughput);
		init[thr_id] = true;
	}

	for (int k=0; k < 20; k++)
	{
		be32enc(&endiandata[k], pdata[k]);
	}

	whirlpoolx_setBlock_80((void*)endiandata, &ptarget[6]);
	whirlpoolx_precompute(thr_id);
	do {
		cpu_whirlpoolx(thr_id, throughput, pdata[19], foundNonce[thr_id]);
//		CUDA_SAFE_CALL(cudaGetLastError());
		if (foundNonce[thr_id][0] != UINT32_MAX)
		{
			const uint32_t Htarg = ptarget[7];
			uint32_t vhash64[8];
			/* check now with the CPU to confirm */
			be32enc(&endiandata[19], foundNonce[thr_id][0]);
			whirlxHash(vhash64, endiandata);
			if (vhash64[7] <= Htarg && fulltest(vhash64, ptarget))
			{
				int res = 1;
				*hashes_done = pdata[19] - first_nonce + throughput;
			/*		if (foundNonce[thr_id][1] != UINT32_MAX)
				{
					be32enc(&endiandata[19], foundNonce[thr_id][1]);
					whirlxHash(vhash64, endiandata);
					if (vhash64[7] <= Htarg && fulltest(vhash64, ptarget))
					{
						pdata[21] = foundNonce[thr_id][1];
						res++;
						if (opt_benchmark) applog(LOG_INFO, "GPU #%d: found nonce %08x", thr_id, foundNonce[thr_id][1]);
					}
					else
					{
						if (vhash64[7] != Htarg)
							applog(LOG_WARNING, "GPU #%d: result for %08x does not validate on CPU!", thr_id, foundNonce[thr_id][1]);
					}
				}
				*/

				if (opt_benchmark)
					applog(LOG_INFO, "GPU #%d: found nonce %08x", thr_id, foundNonce[thr_id][0], vhash64[7]);
				pdata[19] = foundNonce[thr_id][0];
				return res;
			}
			else
			{
				if(vhash64[7] != Htarg)
					applog(LOG_WARNING, "GPU #%d: result for %08x does not validate on CPU!", thr_id, foundNonce[thr_id][0]);
			}
		}
		pdata[19] += throughput;
	} while (!scan_abort_flag && !work_restart[thr_id].restart && ((uint64_t)max_nonce > ((uint64_t)(pdata[19]) + (uint64_t)throughput)));
	*hashes_done = pdata[19] - first_nonce;
	return 0;
}
>>>>>>> 8c320ca... added xevan
