extern "C"
{
#include "sph/sph_blake.h"
#include "sph/sph_bmw.h"
#include "sph/sph_groestl.h"
#include "sph/sph_skein.h"
#include "sph/sph_jh.h"
#include "sph/sph_keccak.h"

#include "sph/sph_luffa.h"
#include "sph/sph_cubehash.h"
#include "sph/sph_shavite.h"
#include "sph/sph_simd.h"
#include "sph/sph_echo.h"
}

#include "miner.h"
<<<<<<< HEAD
#include "cuda_helper.h"
#include "cuda_x11.h"

void tribus_echo512_final(int thr_id, uint32_t threads, uint32_t *d_hash, uint32_t *d_resNonce, const uint64_t target);
=======
//#include <cuda.h>
//#include <cuda_runtime.h>
#include "cuda_helper.h"
>>>>>>> 8c320ca... added xevan

#include <stdio.h>
#include <memory.h>

<<<<<<< HEAD
static uint32_t *d_hash[MAX_GPUS];
static uint32_t *d_resNonce[MAX_GPUS];

// Flax/Chaincoin C11 CPU Hash
extern "C" void c11hash(void *output, const void *input)
{
	unsigned char hash[128] = { 0 };

	sph_blake512_context ctx_blake;
	sph_bmw512_context ctx_bmw;
	sph_groestl512_context ctx_groestl;
	sph_jh512_context ctx_jh;
	sph_keccak512_context ctx_keccak;
	sph_skein512_context ctx_skein;
	sph_luffa512_context ctx_luffa;
	sph_cubehash512_context ctx_cubehash;
	sph_shavite512_context ctx_shavite;
	sph_simd512_context ctx_simd;
	sph_echo512_context ctx_echo;

	sph_blake512_init(&ctx_blake);
	sph_blake512 (&ctx_blake, input, 80);
	sph_blake512_close(&ctx_blake, (void*) hash);

	sph_bmw512_init(&ctx_bmw);
	sph_bmw512 (&ctx_bmw, (const void*) hash, 64);
	sph_bmw512_close(&ctx_bmw, (void*) hash);

	sph_groestl512_init(&ctx_groestl);
	sph_groestl512 (&ctx_groestl, (const void*) hash, 64);
	sph_groestl512_close(&ctx_groestl, (void*) hash);

	sph_jh512_init(&ctx_jh);
	sph_jh512 (&ctx_jh, (const void*) hash, 64);
	sph_jh512_close(&ctx_jh, (void*) hash);

	sph_keccak512_init(&ctx_keccak);
	sph_keccak512 (&ctx_keccak, (const void*) hash, 64);
	sph_keccak512_close(&ctx_keccak, (void*) hash);

	sph_skein512_init(&ctx_skein);
	sph_skein512 (&ctx_skein, (const void*) hash, 64);
	sph_skein512_close(&ctx_skein, (void*) hash);

	sph_luffa512_init(&ctx_luffa);
	sph_luffa512 (&ctx_luffa, (const void*) hash, 64);
	sph_luffa512_close (&ctx_luffa, (void*) hash);

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

	memcpy(output, hash, 32);
}

#ifdef _DEBUG
#define TRACE(algo) { \
	if (max_nonce == 1 && pdata[19] <= 1) { \
		uint32_t* debugbuf = NULL; \
		cudaMallocHost(&debugbuf, 8*sizeof(uint32_t)); \
		cudaMemcpy(debugbuf, d_hash[thr_id], 8*sizeof(uint32_t), cudaMemcpyDeviceToHost); \
		printf("X11 %s %08x %08x %08x %08x...\n", algo, swab32(debugbuf[0]), swab32(debugbuf[1]), \
			swab32(debugbuf[2]), swab32(debugbuf[3])); \
		cudaFreeHost(debugbuf); \
	} \
}
#else
#define TRACE(algo) {}
#endif

static bool init[MAX_GPUS] = { 0 };
static bool use_compat_kernels[MAX_GPUS] = { 0 };

extern "C" int scanhash_c11(int thr_id, struct work* work, uint32_t max_nonce, unsigned long *hashes_done)
{
	uint32_t *pdata = work->data;
	uint32_t *ptarget = work->target;
	const uint32_t first_nonce = pdata[19];
	int intensity = (device_sm[device_map[thr_id]] >= 500 && !is_windows()) ? 20 : 19;
	uint32_t throughput = cuda_default_throughput(thr_id, 1U << intensity); // 19=256*256*8;
	//if (init[thr_id]) throughput = min(throughput, max_nonce - first_nonce);

	if (opt_benchmark)
		((uint32_t*)ptarget)[7] = 0x5;

	if (!init[thr_id])
	{
		int dev_id = device_map[thr_id];
		cudaSetDevice(dev_id);
		if (opt_cudaschedule == -1 && gpu_threads == 1) {
			cudaDeviceReset();
			// reduce cpu usage
			cudaSetDeviceFlags(cudaDeviceScheduleBlockingSync);
			CUDA_LOG_ERROR();
		}
		gpulog(LOG_INFO, thr_id, "Intensity set to %g, %u cuda threads", throughput2intensity(throughput), throughput);

		cuda_get_arch(thr_id);
		use_compat_kernels[thr_id] = (cuda_arch[dev_id] < 500);

		quark_blake512_cpu_init(thr_id, throughput);
		quark_bmw512_cpu_init(thr_id, throughput);
		quark_groestl512_cpu_init(thr_id, throughput);
		quark_skein512_cpu_init(thr_id, throughput);
		quark_keccak512_cpu_init(thr_id, throughput);
		quark_jh512_cpu_init(thr_id, throughput);
		x11_luffaCubehash512_cpu_init(thr_id, throughput);
		x11_shavite512_cpu_init(thr_id, throughput);
		if (use_compat_kernels[thr_id])
			x11_echo512_cpu_init(thr_id, throughput);
		if (x11_simd512_cpu_init(thr_id, throughput) != 0) {
			return 0;
		}
		CUDA_CALL_OR_RET_X(cudaMalloc(&d_hash[thr_id], 64 * throughput), 0);
		CUDA_SAFE_CALL(cudaMalloc(&d_resNonce[thr_id], 2 * sizeof(uint32_t)));

		cuda_check_cpu_init(thr_id, throughput);

		init[thr_id] = true;
	}

	uint32_t endiandata[20];
	for (int k=0; k < 20; k++)
		be32enc(&endiandata[k], pdata[k]);

	quark_blake512_cpu_setBlock_80(thr_id, endiandata);
	if (use_compat_kernels[thr_id])
		cuda_check_cpu_setTarget(ptarget);
	else
		cudaMemset(d_resNonce[thr_id], 0xFF, 2 * sizeof(uint32_t));

	do {
		int order = 0;

		// Hash with CUDA
		quark_blake512_cpu_hash_80(thr_id, throughput, pdata[19], d_hash[thr_id]); order++;
		TRACE("blake  :");
		quark_bmw512_cpu_hash_64(thr_id, throughput, pdata[19], NULL, d_hash[thr_id], order++);
		TRACE("bmw    :");
		quark_groestl512_cpu_hash_64(thr_id, throughput, pdata[19], NULL, d_hash[thr_id], order++);
		TRACE("groestl:");
		quark_jh512_cpu_hash_64(thr_id, throughput, pdata[19], NULL, d_hash[thr_id], order++);
		TRACE("jh512  :");
		quark_keccak512_cpu_hash_64(thr_id, throughput, pdata[19], NULL, d_hash[thr_id], order++);
		TRACE("keccak :");
		quark_skein512_cpu_hash_64(thr_id, throughput, pdata[19], NULL, d_hash[thr_id], order++);
		TRACE("skein  :");
		x11_luffaCubehash512_cpu_hash_64(thr_id, throughput, d_hash[thr_id], order++);
		TRACE("luffa+c:");
		x11_shavite512_cpu_hash_64(thr_id, throughput, pdata[19], NULL, d_hash[thr_id], order++);
		TRACE("shavite:");
		x11_simd512_cpu_hash_64(thr_id, throughput, pdata[19], NULL, d_hash[thr_id], order++);
		TRACE("simd   :");

		if (use_compat_kernels[thr_id]) {
			x11_echo512_cpu_hash_64(thr_id, throughput, pdata[19], NULL, d_hash[thr_id], order++);
			work->nonces[0] = cuda_check_hash(thr_id, throughput, pdata[19], d_hash[thr_id]);
			work->nonces[1] = UINT32_MAX;
		} else {
			tribus_echo512_final(thr_id, throughput, d_hash[thr_id], d_resNonce[thr_id], AS_U64(&ptarget[6]));
			cudaMemcpy(&work->nonces[0], d_resNonce[thr_id], 2 * sizeof(uint32_t), cudaMemcpyDeviceToHost);
		}

		*hashes_done = pdata[19] - first_nonce + throughput;

		if (work->nonces[0] != UINT32_MAX)
		{
			uint32_t _ALIGN(64) vhash[8];
			const uint32_t Htarg = ptarget[7];
			const uint32_t startNounce = pdata[19];
			if (!use_compat_kernels[thr_id]) work->nonces[0] += startNounce;
			be32enc(&endiandata[19], work->nonces[0]);
			c11hash(vhash, endiandata);

			if (vhash[7] <= Htarg && fulltest(vhash, ptarget)) {
				work->valid_nonces = 1;
				work_set_target_ratio(work, vhash);
				if (work->nonces[1] != UINT32_MAX) {
					work->nonces[1] += startNounce;
					be32enc(&endiandata[19], work->nonces[1]);
					c11hash(vhash, endiandata);
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
				cudaMemset(d_resNonce[thr_id], 0xFF, 2 * sizeof(uint32_t));
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

static uint32_t *d_hash[MAX_GPUS];
static uint32_t foundnonces[MAX_GPUS][2];


extern void quark_blake512_cpu_init(int thr_id);
extern void quark_blake512_cpu_setBlock_80(uint64_t *pdata);
extern void quark_blake512_cpu_setBlock_80_multi(uint32_t thr_id, uint64_t *pdata);
extern void quark_blake512_cpu_hash_80(uint32_t threads, uint32_t startNounce, uint32_t *d_hash);

extern void quark_bmw512_cpu_hash_64(uint32_t threads, uint32_t startNounce, uint32_t *d_nonceVector, uint32_t *d_hash);

extern void quark_groestl512_cpu_hash_64(uint32_t threads, uint32_t startNounce, uint32_t *d_nonceVector, uint32_t *d_hash);

extern void quark_skein512_cpu_hash_64(uint32_t threads, uint32_t startNounce, uint32_t *d_nonceVector, uint32_t *d_hash);

extern void quark_keccak512_cpu_init(int thr_id, uint32_t threads);
extern void quark_keccak512_cpu_hash_64(int thr_id, uint32_t threads, uint32_t startNounce, uint32_t *d_nonceVector, uint32_t *d_hash);

extern void cuda_jh512Keccak512_cpu_hash_64(uint32_t threads, uint32_t startNounce, uint32_t *d_hash);

extern void x11_luffaCubehash512_cpu_init(int thr_id, uint32_t threads);
extern void x11_luffaCubehash512_cpu_hash_64(uint32_t threads, uint32_t startNounce, uint32_t *d_hash, uint32_t luffacubehashthreads);

extern void x11_shavite512_cpu_init(int thr_id, uint32_t threads);
extern void x11_shavite512_cpu_hash_64(uint32_t threads, uint32_t startNounce, uint32_t *d_hash, uint32_t shavitethreads);

extern int  x11_simd512_cpu_init(int thr_id, uint32_t threads);
extern void x11_simd512_cpu_hash_64(int thr_id, uint32_t threads, uint32_t startNounce, uint32_t *d_hash, const uint32_t simdthreads);

extern void x11_echo512_cpu_init(int thr_id, uint32_t threads);
extern void x11_echo512_cpu_hash_64(int thr_id, uint32_t threads, uint32_t startNounce, uint32_t *d_hash);
extern void x11_echo512_cpu_hash_64_final(int thr_id, uint32_t threads, uint32_t startNounce, uint32_t *d_hash, uint32_t target, uint32_t *h_found);
extern void x11_echo512_cpu_init(int thr_id, uint32_t threads);

extern void quark_compactTest_cpu_init(int thr_id, uint32_t threads);
extern void quark_compactTest_cpu_hash_64(int thr_id, uint32_t threads, uint32_t startNounce, uint32_t *inpHashes,
	uint32_t *d_noncesTrue, uint32_t *nrmTrue, uint32_t *d_noncesFalse, uint32_t *nrmFalse);

extern "C" void c11hash(void *output, const void *input)
{
			// blake1-bmw2-grs3-skein4-jh5-keccak6-luffa7-cubehash8-shavite9-simd10-echo11
		sph_blake512_context ctx_blake;
		sph_bmw512_context ctx_bmw;
		sph_groestl512_context ctx_groestl;
		sph_jh512_context ctx_jh;
		sph_keccak512_context ctx_keccak;
		sph_skein512_context ctx_skein;
		sph_luffa512_context ctx_luffa;
		sph_cubehash512_context ctx_cubehash;
		sph_shavite512_context ctx_shavite;
		sph_simd512_context ctx_simd;
		sph_echo512_context ctx_echo;
		
		unsigned char hash[128];
		memset(hash, 0, sizeof hash);
		
		sph_blake512_init(&ctx_blake);
		sph_blake512(&ctx_blake, input, 80);
		sph_blake512_close(&ctx_blake, (void*)hash);
		
		sph_bmw512_init(&ctx_bmw);
		sph_bmw512(&ctx_bmw, (const void*)hash, 64);
		sph_bmw512_close(&ctx_bmw, (void*)hash);
		
		sph_groestl512_init(&ctx_groestl);
		sph_groestl512(&ctx_groestl, (const void*)hash, 64);
		sph_groestl512_close(&ctx_groestl, (void*)hash);
		
		sph_jh512_init(&ctx_jh);
		sph_jh512(&ctx_jh, (const void*)hash, 64);
		sph_jh512_close(&ctx_jh, (void*)hash);
		
		sph_keccak512_init(&ctx_keccak);
		sph_keccak512(&ctx_keccak, (const void*)hash, 64);
		sph_keccak512_close(&ctx_keccak, (void*)hash);
		
		sph_skein512_init(&ctx_skein);
		sph_skein512(&ctx_skein, (const void*)hash, 64);
		sph_skein512_close(&ctx_skein, (void*)hash);
		
		sph_luffa512_init(&ctx_luffa);
		sph_luffa512(&ctx_luffa, (const void*)hash, 64);
		sph_luffa512_close(&ctx_luffa, (void*)hash);
		
		sph_cubehash512_init(&ctx_cubehash);
		sph_cubehash512(&ctx_cubehash, (const void*)hash, 64);
		sph_cubehash512_close(&ctx_cubehash, (void*)hash);
		
		sph_shavite512_init(&ctx_shavite);
		sph_shavite512(&ctx_shavite, (const void*)hash, 64);
		sph_shavite512_close(&ctx_shavite, (void*)hash);
		
		sph_simd512_init(&ctx_simd);
		sph_simd512(&ctx_simd, (const void*)hash, 64);
		sph_simd512_close(&ctx_simd, (void*)hash);
		
		sph_echo512_init(&ctx_echo);
		sph_echo512(&ctx_echo, (const void*)hash, 64);
		sph_echo512_close(&ctx_echo, (void*)hash);
		
		memcpy(output, hash, 32);
}
static bool init[MAX_GPUS] = { 0 };
static uint32_t endiandata[MAX_GPUS][20];

extern "C" int scanhash_c11(int thr_id, uint32_t *pdata,
	const uint32_t *ptarget, uint32_t max_nonce,
	unsigned long *hashes_done)
{
	const uint32_t first_nonce = pdata[19];

	int intensity = (device_sm[device_map[thr_id]] > 500) ? 256 * 256 * 21 : 256 * 256 * 10;
	uint32_t simdthreads = (device_sm[device_map[thr_id]] > 500) ? 64 : 32;
	uint32_t shavitethreads = (device_sm[device_map[thr_id]] == 500) ? 256 : 320;
	uint32_t luffacubehashthreads = (device_sm[device_map[thr_id]] == 500) ? 512 : 256;

	uint32_t throughput = device_intensity(device_map[thr_id], __func__, intensity);

	if (opt_benchmark)
		((uint32_t*)ptarget)[7] = 0x4f;

	if (!init[thr_id])
	{
		cudaSetDevice(device_map[thr_id]);
		if (!opt_cpumining) cudaSetDeviceFlags(cudaDeviceScheduleBlockingSync);
		if (opt_n_gputhreads == 1)
		{
			cudaDeviceSetCacheConfig(cudaFuncCachePreferL1);
		}

		x11_echo512_cpu_init(thr_id, throughput);
		if (x11_simd512_cpu_init(thr_id, throughput) != 0) {
			return 0;
		}
		CUDA_CALL_OR_RET_X(cudaMalloc(&d_hash[thr_id], 64 * throughput), 0); // why 64 ?
		quark_blake512_cpu_init(thr_id);
		init[thr_id] = true;
	}
	for (int k = 0; k < 20; k++)
		be32enc(&endiandata[thr_id][k], ((uint32_t*)pdata)[k]);


	if (opt_n_gputhreads > 1)
	{
		quark_blake512_cpu_setBlock_80_multi(thr_id, (uint64_t *)endiandata[thr_id]);
	}
	else
	{
		quark_blake512_cpu_setBlock_80((uint64_t *)endiandata[thr_id]);
	}

	do {

		quark_blake512_cpu_hash_80(throughput, pdata[19], d_hash[thr_id]);
		quark_bmw512_cpu_hash_64(throughput, pdata[19], NULL, d_hash[thr_id]);
		quark_groestl512_cpu_hash_64(throughput, pdata[19], NULL, d_hash[thr_id]);
		cuda_jh512Keccak512_cpu_hash_64(throughput, pdata[19], d_hash[thr_id]);
		quark_skein512_cpu_hash_64(throughput, pdata[19], NULL, d_hash[thr_id]);
		x11_luffaCubehash512_cpu_hash_64(throughput, pdata[19], d_hash[thr_id], luffacubehashthreads);
		x11_shavite512_cpu_hash_64(throughput, pdata[19], d_hash[thr_id], shavitethreads);
		x11_simd512_cpu_hash_64(thr_id, throughput, pdata[19], d_hash[thr_id], simdthreads);
		x11_echo512_cpu_hash_64_final(thr_id, throughput, pdata[19], d_hash[thr_id], ptarget[7], foundnonces[thr_id]);
		if (foundnonces[thr_id][0] != 0xffffffff)
		{
			const uint32_t Htarg = ptarget[7];
			uint32_t vhash64[8];
			be32enc(&endiandata[thr_id][19], foundnonces[thr_id][0]);
			c11hash(vhash64, endiandata[thr_id]);

			if (vhash64[7] <= Htarg && fulltest(vhash64, ptarget))
			{
				int res = 1;
				*hashes_done = pdata[19] - first_nonce + throughput;
				if (foundnonces[thr_id][1] != 0xffffffff)
				{
					pdata[21] = foundnonces[thr_id][1];
					res++;
					if (opt_benchmark)
						applog(LOG_INFO, "GPU #%d Found second nounce %08x", thr_id, foundnonces[thr_id][1], vhash64[7], Htarg);
				}
				pdata[19] = foundnonces[thr_id][0];
				if (opt_benchmark)
					applog(LOG_INFO, "GPU #%d Found nounce %08x", thr_id, foundnonces[thr_id][0], vhash64[7], Htarg);
				return res;
			}
			else
			{
				if (vhash64[7] != Htarg)
				{
					applog(LOG_INFO, "GPU #%d: result for %08x does not validate on CPU!", thr_id, foundnonces[thr_id][0]);
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
extern "C" void free_c11(int thr_id)
{
	if (!init[thr_id])
		return;

	cudaThreadSynchronize();

	cudaFree(d_hash[thr_id]);
	cudaFree(d_resNonce[thr_id]);

	quark_blake512_cpu_free(thr_id);
	quark_groestl512_cpu_free(thr_id);
	x11_simd512_cpu_free(thr_id);

	cuda_check_cpu_free(thr_id);
	init[thr_id] = false;

	cudaDeviceSynchronize();
}
=======
>>>>>>> 8c320ca... added xevan
