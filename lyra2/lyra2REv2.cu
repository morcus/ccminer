extern "C" {
#include "sph/sph_blake.h"
#include "sph/sph_bmw.h"
#include "sph/sph_skein.h"
#include "sph/sph_keccak.h"
#include "sph/sph_cubehash.h"
#include "lyra2/Lyra2.h"
}

<<<<<<< HEAD
#include <miner.h>
#include <cuda_helper.h>

static uint64_t *d_hash[MAX_GPUS];
static uint64_t* d_matrix[MAX_GPUS];

extern void blake256_cpu_init(int thr_id, uint32_t threads);
extern void blake256_cpu_hash_80(const int thr_id, const uint32_t threads, const uint32_t startNonce, uint64_t *Hash, int order);
extern void blake256_cpu_setBlock_80(uint32_t *pdata);
extern void keccak256_cpu_hash_32(int thr_id, uint32_t threads, uint32_t startNonce, uint64_t *d_outputHash, int order);
extern void keccak256_cpu_init(int thr_id, uint32_t threads);
extern void keccak256_cpu_free(int thr_id);
extern void skein256_cpu_hash_32(int thr_id, uint32_t threads, uint32_t startNonce, uint64_t *d_outputHash, int order);
extern void skein256_cpu_init(int thr_id, uint32_t threads);
extern void cubehash256_cpu_hash_32(int thr_id, uint32_t threads, uint32_t startNounce, uint64_t *d_hash, int order);

extern void lyra2v2_cpu_hash_32(int thr_id, uint32_t threads, uint32_t startNonce, uint64_t *d_outputHash, int order);
extern void lyra2v2_cpu_init(int thr_id, uint32_t threads, uint64_t* d_matrix);

extern void bmw256_setTarget(const void *ptarget);
extern void bmw256_cpu_init(int thr_id, uint32_t threads);
extern void bmw256_cpu_free(int thr_id);
extern void bmw256_cpu_hash_32(int thr_id, uint32_t threads, uint32_t startNounce, uint64_t *g_hash, uint32_t *resultnonces);

void lyra2v2_hash(void *state, const void *input)
{
	uint32_t hashA[8], hashB[8];

=======
#include "miner.h"
#include "cuda_helper.h"


static _ALIGN(64) uint64_t *d_hash[MAX_GPUS];
static  uint64_t *d_hash2[MAX_GPUS];

extern void blakeKeccak256_cpu_hash_80(const int thr_id, const uint32_t threads, const uint32_t startNonce, uint64_t *Hash);
extern void blake256_cpu_hash_80(int thr_id, const uint32_t threads, const uint32_t startNonce, uint64_t *Hash);
extern void Keccak256_cpu_hash_32(int thr_id, const uint32_t threads, const uint32_t startNonce, uint64_t *Hash);
extern void blake256_cpu_setBlock_80(uint32_t *pdata);

extern void keccak256_cpu_hash_32(int thr_id, uint32_t threads, uint32_t startNonce, uint64_t *d_outputHash);
extern void keccak256_cpu_init(int thr_id, uint32_t threads);

extern void skein256_cpu_hash_32(int thr_id, uint32_t threads, uint32_t startNonce, uint64_t *d_outputHash);
extern void skein256_cpu_init(int thr_id, uint32_t threads);

extern void skeinCube256_cpu_hash_32(int thr_id, uint32_t threads, uint32_t startNonce, uint64_t *d_outputHash);


extern void lyra2v2_cpu_hash_32(int thr_id, uint32_t threads, uint32_t startNonce, uint64_t *d_outputHash, uint32_t tpb);
extern void lyra2v2_cpu_init(int thr_id, uint32_t threads, uint64_t* matrix);

extern void bmw256_cpu_init(int thr_id, uint32_t threads);
extern void bmw256_cpu_hash_32(int thr_id, uint32_t threads, uint32_t startNounce, uint64_t *g_hash, uint32_t *resultnonces, uint32_t target);

extern void cubehash256_cpu_hash_32(int thr_id, uint32_t threads, uint32_t startNounce, uint64_t *d_hash);

extern "C" void lyra2v2_hash(void *state, const void *input)
{
>>>>>>> 8c320ca... added xevan
	sph_blake256_context      ctx_blake;
	sph_keccak256_context     ctx_keccak;
	sph_skein256_context      ctx_skein;
	sph_bmw256_context        ctx_bmw;
	sph_cubehash256_context   ctx_cube;

<<<<<<< HEAD
	sph_blake256_set_rounds(14);
=======
	uint32_t hashA[8], hashB[8];
>>>>>>> 8c320ca... added xevan

	sph_blake256_init(&ctx_blake);
	sph_blake256(&ctx_blake, input, 80);
	sph_blake256_close(&ctx_blake, hashA);

	sph_keccak256_init(&ctx_keccak);
	sph_keccak256(&ctx_keccak, hashA, 32);
	sph_keccak256_close(&ctx_keccak, hashB);

	sph_cubehash256_init(&ctx_cube);
	sph_cubehash256(&ctx_cube, hashB, 32);
	sph_cubehash256_close(&ctx_cube, hashA);

<<<<<<< HEAD
=======

>>>>>>> 8c320ca... added xevan
	LYRA2(hashB, 32, hashA, 32, hashA, 32, 1, 4, 4);

	sph_skein256_init(&ctx_skein);
	sph_skein256(&ctx_skein, hashB, 32);
	sph_skein256_close(&ctx_skein, hashA);

	sph_cubehash256_init(&ctx_cube);
	sph_cubehash256(&ctx_cube, hashA, 32);
	sph_cubehash256_close(&ctx_cube, hashB);

<<<<<<< HEAD
=======

>>>>>>> 8c320ca... added xevan
	sph_bmw256_init(&ctx_bmw);
	sph_bmw256(&ctx_bmw, hashB, 32);
	sph_bmw256_close(&ctx_bmw, hashA);

	memcpy(state, hashA, 32);
}

static bool init[MAX_GPUS] = { 0 };

<<<<<<< HEAD
extern "C" int scanhash_lyra2v2(int thr_id, struct work* work, uint32_t max_nonce, unsigned long *hashes_done)
{
	uint32_t *pdata = work->data;
	uint32_t *ptarget = work->target;
	const uint32_t first_nonce = pdata[19];
	int dev_id = device_map[thr_id];
	int intensity = (device_sm[dev_id] < 500) ? 18 : is_windows() ? 19 : 20;
	if (strstr(device_name[dev_id], "GTX 10")) intensity = 20;
	uint32_t throughput = cuda_default_throughput(dev_id, 1UL << intensity);
	if (init[thr_id]) throughput = min(throughput, max_nonce - first_nonce);

	if (opt_benchmark)
		ptarget[7] = 0x000f;

	if (!init[thr_id])
	{
		size_t matrix_sz = 16 * sizeof(uint64_t) * 4 * 3;
		cudaSetDevice(dev_id);
		if (opt_cudaschedule == -1 && gpu_threads == 1) {
			cudaDeviceReset();
			// reduce cpu usage
			cudaSetDeviceFlags(cudaDeviceScheduleBlockingSync);
			CUDA_LOG_ERROR();
		}
		gpulog(LOG_INFO, thr_id, "Intensity set to %g, %u cuda threads", throughput2intensity(throughput), throughput);

		blake256_cpu_init(thr_id, throughput);
		keccak256_cpu_init(thr_id,throughput);
		skein256_cpu_init(thr_id, throughput);
		bmw256_cpu_init(thr_id, throughput);

		// SM 3 implentation requires a bit more memory
		if (device_sm[dev_id] < 500 || cuda_arch[dev_id] < 500)
			matrix_sz = 16 * sizeof(uint64_t) * 4 * 4;
			
		CUDA_SAFE_CALL(cudaMalloc(&d_matrix[thr_id], matrix_sz * throughput));
		lyra2v2_cpu_init(thr_id, throughput, d_matrix[thr_id]);

		CUDA_SAFE_CALL(cudaMalloc(&d_hash[thr_id], (size_t)32 * throughput));

		api_set_throughput(thr_id, throughput);
=======
extern "C" int scanhash_lyra2v2(int thr_id, uint32_t *pdata,
	const uint32_t *ptarget, uint32_t max_nonce,
	unsigned long *hashes_done)
{
	const uint32_t first_nonce = pdata[19];
	uint32_t intensity = 256 * 256 * 8;
	uint32_t tpb = 8;
//	bool mergeblakekeccak = false;
	cudaDeviceProp props;
	cudaGetDeviceProperties(&props, device_map[thr_id]);
	if (strstr(props.name, "970"))
	{
		tpb = 10;
		intensity = 256 * 256 * 20;
	}
	else if (strstr(props.name, "980 Ti"))
	{
		tpb = 10;
		intensity = 256 * 256 * 18;
	}
	else if (strstr(props.name, "980"))
	{
		tpb = 10;
		intensity = 256 * 256 * 18;
	}
	else if (strstr(props.name, "750 Ti"))
	{
		intensity = 256 * 256 * 10;
		tpb = 16;
//		mergeblakekeccak = true;
	}
	else if (strstr(props.name, "750"))
	{
		intensity = 256 * 256 * 5;
		tpb = 16;
//		mergeblakekeccak = true;
	}
	else if (strstr(props.name, "960"))
	{
		tpb = 9;
		intensity = 256 * 256 * 18;
	}
	else if (strstr(props.name, "950"))
	{
		intensity = 256 * 256 * 18;
		tpb = 13;
	}

	uint32_t throughput = device_intensity(device_map[thr_id], __func__, intensity);

	if (opt_benchmark)
		((uint32_t*)ptarget)[7] = 0x00ff;
	if (!init[thr_id])
	{
		cudaSetDevice(device_map[thr_id]);
		if (!opt_cpumining) cudaSetDeviceFlags(cudaDeviceScheduleBlockingSync);
		if (opt_n_gputhreads == 1)
		{
			cudaDeviceSetCacheConfig(cudaFuncCachePreferL1);
		}
		//keccak256_cpu_init(thr_id,throughput);
		skein256_cpu_init(thr_id, throughput);
		bmw256_cpu_init(thr_id, throughput);

		CUDA_SAFE_CALL(cudaMalloc(&d_hash2[thr_id], 16 * 4 * 3 * sizeof(uint64_t) * throughput));
		lyra2v2_cpu_init(thr_id, throughput, d_hash2[thr_id]);
		CUDA_SAFE_CALL(cudaMalloc(&d_hash[thr_id], 8 * sizeof(uint32_t) * throughput));
>>>>>>> 8c320ca... added xevan
		init[thr_id] = true;
	}

	uint32_t endiandata[20];
<<<<<<< HEAD
	for (int k=0; k < 20; k++)
		be32enc(&endiandata[k], pdata[k]);

	blake256_cpu_setBlock_80(pdata);
	bmw256_setTarget(ptarget);

	do {
		int order = 0;

		blake256_cpu_hash_80(thr_id, throughput, pdata[19], d_hash[thr_id], order++);
		keccak256_cpu_hash_32(thr_id, throughput, pdata[19], d_hash[thr_id], order++);
		cubehash256_cpu_hash_32(thr_id, throughput, pdata[19], d_hash[thr_id], order++);
		lyra2v2_cpu_hash_32(thr_id, throughput, pdata[19], d_hash[thr_id], order++);
		skein256_cpu_hash_32(thr_id, throughput, pdata[19], d_hash[thr_id], order++);
		cubehash256_cpu_hash_32(thr_id, throughput,pdata[19], d_hash[thr_id], order++);

		memset(work->nonces, 0, sizeof(work->nonces));
		bmw256_cpu_hash_32(thr_id, throughput, pdata[19], d_hash[thr_id], work->nonces);

		*hashes_done = pdata[19] - first_nonce + throughput;

		if (work->nonces[0] != 0)
		{
			const uint32_t Htarg = ptarget[7];
			uint32_t _ALIGN(64) vhash[8];
			be32enc(&endiandata[19], work->nonces[0]);
			lyra2v2_hash(vhash, endiandata);

			if (vhash[7] <= Htarg && fulltest(vhash, ptarget)) {
				work->valid_nonces = 1;
				work_set_target_ratio(work, vhash);
				if (work->nonces[1] != 0) {
					be32enc(&endiandata[19], work->nonces[1]);
					lyra2v2_hash(vhash, endiandata);
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

		if ((uint64_t)throughput + pdata[19] >= max_nonce) {
			pdata[19] = max_nonce;
			break;
		}
		pdata[19] += throughput;

	} while (!work_restart[thr_id].restart && !abort_flag);
=======
	for (int k = 0; k < 20; k++)
		be32enc(&endiandata[k], ((uint32_t*)pdata)[k]);

	blake256_cpu_setBlock_80(pdata);

	do {
		uint32_t foundNonce[2] = { 0, 0 };

//		if (mergeblakekeccak)
//		{
			blakeKeccak256_cpu_hash_80(thr_id, throughput, pdata[19], d_hash[thr_id]);

/*		}
		else
		{
			blake256_cpu_hash_80(thr_id, throughput, pdata[19], d_hash[thr_id]);
			keccak256_cpu_hash_32(thr_id, throughput, pdata[19], d_hash[thr_id]);
		}
*/
		cubehash256_cpu_hash_32(thr_id, throughput, pdata[19], d_hash[thr_id]);
		lyra2v2_cpu_hash_32(thr_id, throughput, pdata[19], d_hash[thr_id], tpb);
		skein256_cpu_hash_32(thr_id, throughput, pdata[19], d_hash[thr_id]);
		cubehash256_cpu_hash_32(thr_id, throughput, pdata[19], d_hash[thr_id]);
		bmw256_cpu_hash_32(thr_id, throughput, pdata[19], d_hash[thr_id], foundNonce, ptarget[7]);
		//		foundNonce[0] = 0xffffffff;
		if (foundNonce[0] != 0xffffffff)
		{
			const uint32_t Htarg = ptarget[7];
			uint32_t vhash64[8];
			be32enc(&endiandata[19], foundNonce[0]);
			lyra2v2_hash(vhash64, endiandata);
			if (vhash64[7] <= Htarg && fulltest(vhash64, ptarget))
			{
				int res = 1;
				// check if there was some other ones...
				*hashes_done = pdata[19] - first_nonce + throughput;
				if (foundNonce[1] != 0xffffffff)
				{
					pdata[21] = foundNonce[1];
					res++;
					if (opt_benchmark)  applog(LOG_INFO, "GPU #%d Found second nounce %08x", thr_id, foundNonce[1], vhash64[7], Htarg);
				}
				pdata[19] = foundNonce[0];
				if (opt_benchmark) applog(LOG_INFO, "GPU #%d Found nounce % 08x", thr_id, foundNonce[0], vhash64[7], Htarg);
				return res;
			}
			else
			{
				if (vhash64[7] > Htarg) // don't show message if it is equal but fails fulltest
					applog(LOG_WARNING, "GPU #%d: result does not validate on CPU!", thr_id);
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
extern "C" void free_lyra2v2(int thr_id)
{
	if (!init[thr_id])
		return;

	cudaThreadSynchronize();

	cudaFree(d_hash[thr_id]);
	cudaFree(d_matrix[thr_id]);

	bmw256_cpu_free(thr_id);
	keccak256_cpu_free(thr_id);

	init[thr_id] = false;

	cudaDeviceSynchronize();
}
=======
>>>>>>> 8c320ca... added xevan
