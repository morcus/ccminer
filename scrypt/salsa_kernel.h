#ifndef SALSA_KERNEL_H
#define SALSA_KERNEL_H

#include <stdio.h>
#include <stdbool.h>
<<<<<<< HEAD
#include <stdlib.h>
#ifndef __APPLE__
#include <malloc.h>
#endif
=======
#include <malloc.h>
>>>>>>> 8c320ca... added xevan
#include <string.h>
#include <cuda_runtime.h>

#include "miner.h"

<<<<<<< HEAD
// from ccminer.cpp
extern short device_map[MAX_GPUS];
extern int device_batchsize[MAX_GPUS]; // cudaminer -b
extern int device_interactive[MAX_GPUS]; // cudaminer -i
extern int device_texturecache[MAX_GPUS]; // cudaminer -C
extern int device_singlememory[MAX_GPUS]; // cudaminer -m
extern int device_lookup_gap[MAX_GPUS]; // -L
extern int device_backoff[MAX_GPUS]; // WIN32/LINUX var
extern char *device_config[MAX_GPUS]; // -l
extern char *device_name[MAX_GPUS];

extern bool opt_autotune;
extern int opt_nfactor;
extern char *jane_params;
=======
#define MAX_DEVICES MAX_GPUS

#define A_SCRYPT 0
#define A_SCRYPT_JANE 1

// from ccminer.cpp
extern int device_map[MAX_GPUS];
extern int device_interactive[MAX_GPUS];
extern int device_batchsize[MAX_GPUS];
extern int device_backoff[MAX_GPUS];
extern int device_lookup_gap[MAX_GPUS];
extern int device_texturecache[MAX_GPUS];
extern int device_singlememory[MAX_GPUS];
extern char *device_config[MAX_GPUS];
extern char *device_name[MAX_GPUS];
extern bool autotune;

extern int opt_nfactor;
extern char *jane_params;
extern bool abort_flag;
extern bool autotune;
>>>>>>> 8c320ca... added xevan
extern int parallel;

extern void get_currentalgo(char* buf, int sz);

<<<<<<< HEAD
typedef unsigned int uint32_t; // define this as 32 bit type derived from int

// scrypt variants
#define A_SCRYPT 0
#define A_SCRYPT_JANE 1
static char algo[64] = { 0 };
static int scrypt_algo = -1;
static __inline int get_scrypt_type() {
	if (scrypt_algo != -1) return scrypt_algo;
	get_currentalgo(algo, 64);
	if (!strncasecmp(algo,"scrypt-jane",11)) scrypt_algo = A_SCRYPT_JANE;
	else if (!strncasecmp(algo,"scrypt",6)) scrypt_algo = A_SCRYPT;
	return scrypt_algo;
}
static __inline bool IS_SCRYPT() { get_scrypt_type(); return (scrypt_algo == A_SCRYPT); }
static __inline bool IS_SCRYPT_JANE() { get_scrypt_type(); return (scrypt_algo == A_SCRYPT_JANE); }

// CUDA externals
extern int cuda_throughput(int thr_id);
=======
typedef uint32_t uint32_t; // define this as 32 bit type derived from int

static char algo[64] = { 0 };
// scrypt variants
#define A_SCRYPT 0
#define A_SCRYPT_JANE 1

static int scrypt_algo = -1;
static __inline int get_scrypt_type() 
{
	if (scrypt_algo != -1) return scrypt_algo;
	get_currentalgo(algo, 64);
	if (!strcasecmp(algo, "scrypt-jane")) scrypt_algo = A_SCRYPT_JANE;
	else if (!strcasecmp(algo, "scrypt")) scrypt_algo = A_SCRYPT;
	return scrypt_algo;	
}
static __inline bool IS_SCRYPT() { get_scrypt_type(); return (scrypt_algo == A_SCRYPT); }
static __inline bool IS_SCRYPT_JANE() { get_scrypt_type(); return (scrypt_algo == A_SCRYPT_JANE); }
// CUDA externals
extern int cuda_num_devices();
extern void cuda_shutdown(int thr_id);
extern int cuda_throughput(int thr_id);

>>>>>>> 8c320ca... added xevan
extern uint32_t *cuda_transferbuffer(int thr_id, int stream);
extern uint32_t *cuda_hashbuffer(int thr_id, int stream);

extern void cuda_scrypt_HtoD(int thr_id, uint32_t *X, int stream);
extern void cuda_scrypt_serialize(int thr_id, int stream);
<<<<<<< HEAD
extern void cuda_scrypt_core(int thr_id, int stream, unsigned int N);
=======
extern void cuda_scrypt_core(int thr_id, int stream, uint32_t N);
>>>>>>> 8c320ca... added xevan
extern void cuda_scrypt_done(int thr_id, int stream);
extern void cuda_scrypt_DtoH(int thr_id, uint32_t *X, int stream, bool postSHA);
extern bool cuda_scrypt_sync(int thr_id, int stream);
extern void cuda_scrypt_flush(int thr_id, int stream);

<<<<<<< HEAD
=======
extern bool cuda_prepare_keccak256(int thr_id, const uint32_t host_pdata[20], const uint32_t ptarget[8]);
extern void cuda_do_keccak256(int thr_id, int stream, uint32_t *hash, uint32_t nonce, int throughput, bool do_d2h);

extern bool cuda_prepare_blake256(int thr_id, const uint32_t host_pdata[20], const uint32_t ptarget[8]);
extern void cuda_do_blake256(int thr_id, int stream, uint32_t *hash, uint32_t nonce, int throughput, bool do_d2h);

extern void computeGold(uint32_t *idata, uint32_t *reference, uchar *scratchpad);

extern bool default_prepare_keccak256(int thr_id, const uint32_t host_pdata[20], const uint32_t ptarget[8]);
extern bool default_prepare_blake256(int thr_id, const uint32_t host_pdata[20], const uint32_t ptarget[8]);

#ifdef __NVCC__
extern void default_do_keccak256(dim3 grid, dim3 threads, int thr_id, int stream, uint32_t *hash, uint32_t nonce, int throughput, bool do_d2h);
extern void default_do_blake256(dim3 grid, dim3 threads, int thr_id, int stream, uint32_t *hash, uint32_t nonce, int throughput, bool do_d2h);
#endif

>>>>>>> 8c320ca... added xevan
// If we're in C++ mode, we're either compiling .cu files or scrypt.cpp

#ifdef __NVCC__

/**
 * An pure virtual interface for a CUDA kernel implementation.
 * TODO: encapsulate the kernel launch parameters in some kind of wrapper.
 */
class KernelInterface
{
public:
	virtual void set_scratchbuf_constants(int MAXWARPS, uint32_t** h_V) = 0;
<<<<<<< HEAD
	virtual bool run_kernel(dim3 grid, dim3 threads, int WARPS_PER_BLOCK, int thr_id, cudaStream_t stream, uint32_t* d_idata, uint32_t* d_odata, unsigned int N, unsigned int LOOKUP_GAP, bool interactive, bool benchmark, int texture_cache) = 0;
=======
	virtual bool run_kernel(dim3 grid, dim3 threads, int WARPS_PER_BLOCK, int thr_id, cudaStream_t stream, uint32_t* d_idata, uint32_t* d_odata, uint32_t N, uint32_t LOOKUP_GAP, bool interactive, bool benchmark, int texture_cache) = 0;
>>>>>>> 8c320ca... added xevan
	virtual bool bindtexture_1D(uint32_t *d_V, size_t size) { return true; }
	virtual bool bindtexture_2D(uint32_t *d_V, int width, int height, size_t pitch) { return true; }
	virtual bool unbindtexture_1D() { return true; }
	virtual bool unbindtexture_2D() { return true; }

	virtual char get_identifier() = 0;
	virtual int get_major_version() { return 1; }
	virtual int get_minor_version() { return 0; }
	virtual int max_warps_per_block() = 0;
	virtual int get_texel_width() = 0;
	virtual bool no_textures() { return false; };
	virtual bool single_memory() { return false; };
	virtual int threads_per_wu() { return 1; }
	virtual bool support_lookup_gap() { return false; }
	virtual cudaSharedMemConfig shared_mem_config() { return cudaSharedMemBankSizeDefault; }
	virtual cudaFuncCache cache_config() { return cudaFuncCachePreferNone; }
<<<<<<< HEAD
=======

	virtual bool prepare_keccak256(int thr_id, const uint32_t host_pdata[20], const uint32_t ptarget[8]) {
		return default_prepare_keccak256(thr_id, host_pdata, ptarget);
	}
	virtual void do_keccak256(dim3 grid, dim3 threads, int thr_id, int stream, uint32_t *hash, uint32_t nonce, int throughput, bool do_d2h = false) {
		default_do_keccak256(grid, threads, thr_id, stream, hash, nonce, throughput, do_d2h);
	}

	virtual bool prepare_blake256(int thr_id, const uint32_t host_pdata[20], const uint32_t ptarget[8]) {
		return default_prepare_blake256(thr_id, host_pdata, ptarget);
	}
	virtual void do_blake256(dim3 grid, dim3 threads, int thr_id, int stream, uint32_t *hash, uint32_t nonce, int throughput, bool do_d2h = false) {
		default_do_blake256(grid, threads, thr_id, stream, hash, nonce, throughput, do_d2h);
	}
>>>>>>> 8c320ca... added xevan
};

// Not performing error checking is actually bad, but...
#define checkCudaErrors(x) x
#define getLastCudaError(x)

#endif // #ifdef __NVCC__

// Define work unit size
#define TOTAL_WARP_LIMIT 4096
#define WU_PER_WARP (32 / THREADS_PER_WU)
#define WU_PER_BLOCK (WU_PER_WARP*WARPS_PER_BLOCK)
#define WU_PER_LAUNCH (GRID_BLOCKS*WU_PER_BLOCK)

// make scratchpad size dependent on N and LOOKUP_GAP
#define SCRATCH   (((N+LOOKUP_GAP-1)/LOOKUP_GAP)*32)

#endif // #ifndef SALSA_KERNEL_H
