/**
<<<<<<< HEAD
 * S3 Hash (Also called Triple S - Used by 1Coin)
=======
 * S3 Hash (Also called 3S - Used by 1Coin)
>>>>>>> 8c320ca... added xevan
 */

extern "C" {
#include "sph/sph_skein.h"
#include "sph/sph_shavite.h"
#include "sph/sph_simd.h"
}

#include "miner.h"
#include "cuda_helper.h"
<<<<<<< HEAD
#include "cuda_x11.h"

extern void x11_shavite512_setBlock_80(void *pdata);
extern void x11_shavite512_cpu_hash_80(int thr_id, uint32_t threads, uint32_t startNounce, uint32_t *d_hash, int order);
=======
>>>>>>> 8c320ca... added xevan

#include <stdint.h>

static uint32_t *d_hash[MAX_GPUS];

<<<<<<< HEAD
=======
extern void x11_shavite512_cpu_hash_80(uint32_t threads, uint32_t startNounce, uint32_t *d_hash);
extern void x11_shavite512_setBlock_80(void *pdata);

extern int  x11_simd512_cpu_init(int thr_id, uint32_t threads);
extern void x11_simd512_cpu_hash_64(int thr_id, uint32_t threads, uint32_t startNounce, uint32_t *d_hash, const uint32_t simdthreads);

extern void quark_skein512_cpu_init(int thr_id);
extern void quark_skein512_cpu_hash_64(uint32_t threads, uint32_t startNounce, uint32_t *d_nonceVector, uint32_t *d_hash);
//extern void quark_skein512_cpu_hash_64_final(int thr_id, uint32_t threads, uint32_t startNounce, uint32_t *d_nonceVector, uint32_t *d_hash, uint32_t *h_found, uint32_t target);
extern void quark_skein512_cpu_hash_64(uint32_t threads, uint32_t startNounce, uint32_t *d_nonceVector, uint32_t *d_hash);

>>>>>>> 8c320ca... added xevan
/* CPU HASH */
extern "C" void s3hash(void *output, const void *input)
{
	sph_shavite512_context ctx_shavite;
	sph_simd512_context ctx_simd;
	sph_skein512_context ctx_skein;

	unsigned char hash[64];

	sph_shavite512_init(&ctx_shavite);
	sph_shavite512(&ctx_shavite, input, 80);
	sph_shavite512_close(&ctx_shavite, (void*) hash);

	sph_simd512_init(&ctx_simd);
	sph_simd512(&ctx_simd, (const void*) hash, 64);
	sph_simd512_close(&ctx_simd, (void*) hash);

	sph_skein512_init(&ctx_skein);
	sph_skein512(&ctx_skein, (const void*) hash, 64);
	sph_skein512_close(&ctx_skein, (void*) hash);

	memcpy(output, hash, 32);
}

<<<<<<< HEAD
#ifdef _DEBUG
#define TRACE(algo) { \
	if (max_nonce == 1 && pdata[19] <= 1) { \
		uint32_t* debugbuf = NULL; \
		cudaMallocHost(&debugbuf, 32); \
		cudaMemcpy(debugbuf, d_hash[thr_id], 32, cudaMemcpyDeviceToHost); \
		printf("S3 %s %08x %08x %08x %08x...%08x\n", algo, swab32(debugbuf[0]), swab32(debugbuf[1]), \
			swab32(debugbuf[2]), swab32(debugbuf[3]), swab32(debugbuf[7])); \
		cudaFreeHost(debugbuf); \
	} \
}
#else
#define TRACE(algo) {}
#endif

static bool init[MAX_GPUS] = { 0 };

/* Main S3 entry point */
extern "C" int scanhash_s3(int thr_id, struct work* work, uint32_t max_nonce, unsigned long *hashes_done)
{
	uint32_t *pdata = work->data;
	uint32_t *ptarget = work->target;
	const uint32_t first_nonce = pdata[19];
	int intensity = 20; // 256*256*8*2;
=======
static bool init[MAX_GPUS] = { 0 };

/* Main S3 entry point */
extern "C" int scanhash_s3(int thr_id, uint32_t *pdata,
	const uint32_t *ptarget, uint32_t max_nonce,
	unsigned long *hashes_done)
{
	const uint32_t first_nonce = pdata[19];
	uint32_t intensity = 20; // 256*256*8*2;
>>>>>>> 8c320ca... added xevan
#ifdef WIN32
	// reduce by one the intensity on windows
	intensity--;
#endif
<<<<<<< HEAD
	uint32_t throughput =  cuda_default_throughput(thr_id, 1 << intensity);
	//if (init[thr_id]) throughput = min(throughput, max_nonce - first_nonce);

	if (opt_benchmark)
		ptarget[7] = 0xF;
=======
	uint32_t throughput = device_intensity(device_map[thr_id], __func__, 1 << intensity);
	throughput = min(throughput, (max_nonce - first_nonce));
	uint32_t simdthreads = (device_sm[device_map[thr_id]] > 500) ? 64 : 32;
	if (opt_benchmark)
		((uint32_t*)ptarget)[7] = 0x0000000fu;
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

		CUDA_SAFE_CALL(cudaMalloc(&d_hash[thr_id], (size_t) 64 * throughput));

		x11_shavite512_cpu_init(thr_id, throughput);
		x11_simd512_cpu_init(thr_id, throughput);
		quark_skein512_cpu_init(thr_id, throughput);
=======
		if (!opt_cpumining) cudaSetDeviceFlags(cudaDeviceScheduleBlockingSync);
		if (opt_n_gputhreads == 1)
		{
			cudaDeviceSetCacheConfig(cudaFuncCachePreferL1);
		}

		x11_simd512_cpu_init(thr_id, throughput);
		quark_skein512_cpu_init(thr_id);

		CUDA_CALL_OR_RET_X(cudaMalloc(&d_hash[thr_id], 16 * sizeof(uint32_t) * throughput), 0);
>>>>>>> 8c320ca... added xevan

		cuda_check_cpu_init(thr_id, throughput);

		init[thr_id] = true;
	}

	uint32_t endiandata[20];
	for (int k=0; k < 20; k++)
<<<<<<< HEAD
		be32enc(&endiandata[k], pdata[k]);
=======
		be32enc(&endiandata[k], ((uint32_t*)pdata)[k]);
>>>>>>> 8c320ca... added xevan

	x11_shavite512_setBlock_80((void*)endiandata);
	cuda_check_cpu_setTarget(ptarget);

	do {
<<<<<<< HEAD
		int order = 0;

		x11_shavite512_cpu_hash_80(thr_id, throughput, pdata[19], d_hash[thr_id], order++);
		TRACE("shavite:");
		x11_simd512_cpu_hash_64(thr_id, throughput, pdata[19], NULL, d_hash[thr_id], order++);
		TRACE("simd   :");
		quark_skein512_cpu_hash_64(thr_id, throughput, pdata[19], NULL, d_hash[thr_id], order++);
		TRACE("skein  :");

		*hashes_done = pdata[19] - first_nonce + throughput;

		work->nonces[0] = cuda_check_hash(thr_id, throughput, pdata[19], d_hash[thr_id]);
		if (work->nonces[0] != UINT32_MAX)
		{
			const uint32_t Htarg = ptarget[7];
			uint32_t _ALIGN(64) vhash[8];
			be32enc(&endiandata[19], work->nonces[0]);
			s3hash(vhash, endiandata);

			if (vhash[7] <= Htarg && fulltest(vhash, ptarget)) {
				work->valid_nonces = 1;
				work_set_target_ratio(work, vhash);
				work->nonces[1] = cuda_check_hash_suppl(thr_id, throughput, pdata[19], d_hash[thr_id], 1);
				if (work->nonces[1] != 0) {
					be32enc(&endiandata[19], work->nonces[1]);
					s3hash(vhash, endiandata);
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

		x11_shavite512_cpu_hash_80(throughput, pdata[19], d_hash[thr_id]);
		x11_simd512_cpu_hash_64(thr_id, throughput, pdata[19], d_hash[thr_id], simdthreads);
		quark_skein512_cpu_hash_64(throughput, pdata[19], NULL, d_hash[thr_id]);
		uint32_t foundNonce = cuda_check_hash(thr_id, throughput, pdata[19], d_hash[thr_id]);

		if (foundNonce != 0xffffffff)
		{
			const uint32_t Htarg = ptarget[7];
			uint32_t vhash64[8];
			be32enc(&endiandata[19], foundNonce);
			s3hash(vhash64, endiandata);

			if (vhash64[7] <= Htarg && fulltest(vhash64, ptarget))
			{
				int res = 1;
				// check if there was some other ones...
				*hashes_done = pdata[19] - first_nonce + throughput;
				/*
				if (h_found[thr_id][1] != 0xffffffff)
				{
					pdata[21] = h_found[thr_id][1];
					res++;
					if (opt_benchmark)
						applog(LOG_INFO, "GPU #%d Found second nounce %08x", thr_id, h_found[thr_id][1]);
				}
				*/
				pdata[19] = foundNonce;
				if (opt_benchmark)
					applog(LOG_INFO, "GPU #%d Found nounce %08x", thr_id, foundNonce);
				return res;
			}
			else
			{
				if (vhash64[7] != Htarg)
				{
					applog(LOG_INFO, "GPU #%d: result for %08x does not validate on CPU!", thr_id, foundNonce);
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
extern "C" void free_s3(int thr_id)
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
