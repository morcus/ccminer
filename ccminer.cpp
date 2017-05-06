/*
 * Copyright 2010 Jeff Garzik
 * Copyright 2012-2014 pooler
<<<<<<< HEAD
 * Copyright 2014-2017 tpruvot
=======
>>>>>>> 8c320ca... added xevan
 *
 * This program is free software; you can redistribute it and/or modify it
 * under the terms of the GNU General Public License as published by the Free
 * Software Foundation; either version 2 of the License, or (at your option)
 * any later version.  See COPYING for more details.
 */

<<<<<<< HEAD
#include <ccminer-config.h>
=======
#include "cpuminer-config.h"
#include "cuda_runtime_api.h"
>>>>>>> 8c320ca... added xevan

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>
#include <inttypes.h>
#include <unistd.h>
#include <math.h>
#include <sys/time.h>
#include <time.h>
#include <signal.h>
<<<<<<< HEAD

#include <curl/curl.h>
#include <openssl/sha.h>

=======
#include <curl/curl.h>
#include <jansson.h>
#include <openssl/sha.h>
>>>>>>> 8c320ca... added xevan
#ifdef WIN32
#include <windows.h>
#include <stdint.h>
#else
#include <errno.h>
#include <sys/resource.h>
#if HAVE_SYS_SYSCTL_H
#include <sys/types.h>
#if HAVE_SYS_PARAM_H
#include <sys/param.h>
#endif
#include <sys/sysctl.h>
#endif
#endif

<<<<<<< HEAD
#include "miner.h"
#include "algos.h"
#include "sia/sia-rpc.h"
#include "crypto/xmr-rpc.h"
#include "equi/equihash.h"

#include <cuda_runtime.h>
=======
//#include "nvml.h"
#include "cuda_runtime.h"
//#include "gpu_utils.h"
#include "miner.h"
>>>>>>> 8c320ca... added xevan

#ifdef WIN32
#include <Mmsystem.h>
#pragma comment(lib, "winmm.lib")
#include "compat/winansi.h"
BOOL WINAPI ConsoleHandler(DWORD);
#endif

#define PROGRAM_NAME		"ccminer"
<<<<<<< HEAD
#define LP_SCANTIME		60
#define HEAVYCOIN_BLKHDR_SZ		84
#define MNR_BLKHDR_SZ 80

=======
#define LP_SCANTIME		30
#define HEAVYCOIN_BLKHDR_SZ		84
#define MNR_BLKHDR_SZ 80

// from cuda.cpp
int cuda_num_devices();
void cuda_devicenames();
void cuda_devicenames();
void cuda_devicereset();
void cuda_print_devices();
int cuda_finddevice(char *name);

>>>>>>> 8c320ca... added xevan
#include "nvml.h"
#ifdef USE_WRAPNVML
nvml_handle *hnvml = NULL;
#endif

enum workio_commands {
	WC_GET_WORK,
	WC_SUBMIT_WORK,
	WC_ABORT,
};

struct workio_cmd {
	enum workio_commands	cmd;
	struct thr_info		*thr;
	union {
		struct work	*work;
	} u;
<<<<<<< HEAD
	int pooln;
};

bool opt_debug = false;
bool opt_debug_diff = false;
bool opt_debug_threads = false;
bool opt_protocol = false;
bool opt_benchmark = false;
bool opt_showdiff = true;
bool opt_hwmonitor = true;

// todo: limit use of these flags,
// prefer the pools[] attributes
=======
};

enum sha_algos {
	ALGO_BASTION,
	ALGO_BITC,
	ALGO_BITCOIN,
	ALGO_BLAKE,
	ALGO_BLAKECOIN,
	ALGO_C11,
	ALGO_DEEP,
	ALGO_DMD_GR,
	ALGO_DOOM,
	ALGO_FRESH,
	ALGO_FUGUE256,		/* Fugue256 */
	ALGO_GROESTL,
	ALGO_HEAVY,		/* Heavycoin hash */
	ALGO_KECCAK,
	ALGO_JACKPOT,
	ALGO_LUFFA_DOOM,
	ALGO_LYRA2,
	ALGO_LYRA2v2,
	ALGO_MJOLLNIR,		/* Hefty hash */
	ALGO_MYR_GR,
	ALGO_NIST5,
	ALGO_PENTABLAKE,
	ALGO_QUARK,
	ALGO_QUBIT,
	ALGO_SCRYPT,
	ALGO_SCRYPT_JANE, 
	ALGO_SKEIN,
	ALGO_S3,
	ALGO_SPREADX11,
	ALGO_WHC,
	ALGO_WHCX,
	ALGO_X11,
	ALGO_X13,
	ALGO_X14,
	ALGO_X15,
	ALGO_X17,
	ALGO_XEVAN, //
	ALGO_VANILLA,
	ALGO_NEO,
	ALGO_COUNT

};

static const char *algo_names[] = {
	"bastion",
	"credit",
	"bitcoin",
	"blake",
	"blakecoin",
	"c11", 
	"deep",
	"dmd-gr",
	"doom", /* is luffa */
	"fresh",
	"fugue256",
	"groestl",
	"heavy",
	"keccak",
	"jackpot",
	"luffa",
	"lyra2",
	"lyra2v2",
	"mjollnir",
	"myr-gr",
	"nist5",
	"penta",
	"quark",
	"qubit",
	"scrypt",
	"scrypt-jane",
	"skein",
	"s3",
	"spread",
	"whirl",
	"whirlpoolx",
	"x11",
	"x13",
	"x14",
	"x15",
	"x17",
	"xevan",
	"vanilla",
	"neoscrypt",
	""
};

bool opt_broken_neo_wallet = false; // HACK: Drop this flag once neoscrypt wallets are fixed to send 80byte data
bool opt_debug = false;
bool opt_protocol = false;
bool opt_benchmark = false;
>>>>>>> 8c320ca... added xevan
bool want_longpoll = true;
bool have_longpoll = false;
bool want_stratum = true;
bool have_stratum = false;
<<<<<<< HEAD
bool allow_gbt = true;
bool allow_mininginfo = true;
bool check_dups = true; //false;
bool check_stratum_jobs = false;

bool submit_old = false;
bool use_syslog = false;
bool use_colors = true;
int use_pok = 0;
static bool opt_background = false;
bool opt_quiet = false;
int opt_maxlograte = 3;
static int opt_retries = -1;
static int opt_fail_pause = 30;
int opt_time_limit = -1;
int opt_shares_limit = -1;
time_t firstwork_time = 0;
int opt_timeout = 300; // curl
int opt_scantime = 10;
static json_t *opt_config;
static const bool opt_time = true;
volatile enum sha_algos opt_algo = ALGO_AUTO;
int opt_n_threads = 0;
int gpu_threads = 1;
int64_t opt_affinity = -1L;
int opt_priority = 0;
static double opt_difficulty = 1.;
bool opt_extranonce = true;
bool opt_trust_pool = false;
uint16_t opt_vote = 9999;
int num_cpus;
int active_gpus;
bool need_nvsettings = false;
bool need_memclockrst = false;
char * device_name[MAX_GPUS];
short device_map[MAX_GPUS] = { 0 };
long  device_sm[MAX_GPUS] = { 0 };
short device_mpcount[MAX_GPUS] = { 0 };
uint32_t gpus_intensity[MAX_GPUS] = { 0 };
uint32_t device_gpu_clocks[MAX_GPUS] = { 0 };
uint32_t device_mem_clocks[MAX_GPUS] = { 0 };
int32_t device_mem_offsets[MAX_GPUS] = { 0 };
uint32_t device_plimit[MAX_GPUS] = { 0 };
uint8_t device_tlimit[MAX_GPUS] = { 0 };
int8_t device_pstate[MAX_GPUS] = { -1, -1 };
int32_t device_led[MAX_GPUS] = { -1, -1 };
int opt_led_mode = 0;
int opt_cudaschedule = -1;
static bool opt_keep_clocks = false;

// un-linked to cmdline scrypt options (useless)
int device_batchsize[MAX_GPUS] = { 0 };
int device_texturecache[MAX_GPUS] = { 0 };
int device_singlememory[MAX_GPUS] = { 0 };
// implemented scrypt options
int parallel = 2; // All should be made on GPU
char *device_config[MAX_GPUS] = { 0 };
int device_backoff[MAX_GPUS] = { 0 }; // scrypt
int device_bfactor[MAX_GPUS] = { 0 }; // cryptonight
int device_lookup_gap[MAX_GPUS] = { 0 };
int device_interactive[MAX_GPUS] = { 0 };
int opt_nfactor = 0;
bool opt_autotune = true;
char *jane_params = NULL;

// pools (failover/getwork infos)
struct pool_infos pools[MAX_POOLS] = { 0 };
int num_pools = 1;
volatile int cur_pooln = 0;
bool opt_pool_failover = true;
volatile bool pool_on_hold = false;
volatile bool pool_is_switching = false;
volatile int pool_switch_count = 0;
bool conditional_pool_rotate = false;

extern char* opt_scratchpad_url;

// current connection
char *rpc_user = NULL;
char *rpc_pass;
char *rpc_url;
char *short_url = NULL;

struct stratum_ctx stratum = { 0 };
pthread_mutex_t stratum_sock_lock;
pthread_mutex_t stratum_work_lock;

char *opt_cert;
char *opt_proxy;
long opt_proxy_type;
struct thr_info *thr_info = NULL;
static int work_thr_id;
struct thr_api *thr_api;
int longpoll_thr_id = -1;
int stratum_thr_id = -1;
int api_thr_id = -1;
int monitor_thr_id = -1;
bool stratum_need_reset = false;
volatile bool abort_flag = false;
struct work_restart *work_restart = NULL;
static int app_exit_code = EXIT_CODE_OK;

pthread_mutex_t applog_lock;
pthread_mutex_t stats_lock;
double thr_hashrates[MAX_GPUS] = { 0 };
uint64_t global_hashrate = 0;
double   stratum_diff = 0.0;
double   net_diff = 0;
uint64_t net_hashrate = 0;
uint64_t net_blocks = 0;
// conditional mining
uint8_t conditional_state[MAX_GPUS] = { 0 };
double opt_max_temp = 0.0;
double opt_max_diff = -1.;
double opt_max_rate = -1.;
double opt_resume_temp = 0.;
double opt_resume_diff = 0.;
double opt_resume_rate = -1.;

int opt_statsavg = 30;

#define API_MCAST_CODE "FTW"
#define API_MCAST_ADDR "224.0.0.75"

// strdup on char* to allow a common free() if used
static char* opt_syslog_pfx = strdup(PROGRAM_NAME);
char *opt_api_bind = strdup("127.0.0.1"); /* 0.0.0.0 for all ips */
int opt_api_port = 4068; /* 0 to disable */
char *opt_api_allow = NULL;
char *opt_api_groups = NULL;
bool opt_api_mcast = false;
char *opt_api_mcast_addr = strdup(API_MCAST_ADDR);
char *opt_api_mcast_code = strdup(API_MCAST_CODE);
char *opt_api_mcast_des = strdup("");
int opt_api_mcast_port = 4068;

bool opt_stratum_stats = false;
=======
bool allow_gbt = false;
bool check_dups = false;
static bool submit_old = false;
bool use_syslog = false;
bool use_colors = true;
static bool opt_background = false;
bool opt_quiet = false;
static int opt_retries = -1;
static int opt_fail_pause = 5;
static int opt_time_limit = 0;
int opt_timeout = 270;
static int opt_scantime = 5;
static json_t *opt_config;
static const bool opt_time = true;
static enum sha_algos opt_algo = ALGO_X11;
int opt_n_threads = 0;
int opt_n_gputhreads = 1;
int opt_affinity = -1;
int opt_priority = 0;
static double opt_difficulty = 1; // CH
static bool opt_extranonce = true;
bool opt_cpumining = false;

bool opt_trust_pool = false;
uint16_t opt_vote = 9999;
int num_cpus = 0;
int active_gpus = 0;
char * device_name[MAX_GPUS];
int device_map[MAX_GPUS] = { 0, 1, 2, 3, 4, 5, 6, 7,8,9,10,11,12,13,14,15,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31 };
long  device_sm[MAX_GPUS] = { 0 };
int device_memspeed[MAX_GPUS] = { 0 };
int device_gpuspeed[MAX_GPUS] = { 0 };
uint32_t gpus_intensity[MAX_GPUS] = { 0 };
int device_interactive[MAX_GPUS] = { 0 };
int device_batchsize[MAX_GPUS] = { 0 };
int device_backoff[MAX_GPUS] = { 0 };
int device_lookup_gap[MAX_GPUS] = { 0 };
int device_texturecache[MAX_GPUS] = { 0 };
int device_singlememory[MAX_GPUS] = { 0 };


char *device_config[MAX_GPUS] = { 0 };
int opt_nfactor = 0;
int parallel = 2;
bool autotune = true;
bool opt_autotune = true;

bool abort_flag = false;
bool scan_abort_flag = false;
bool network_fail_flag = false;
char *jane_params = NULL;

char *rpc_user = NULL;
static char *rpc_url = NULL;
static char *rpc_userpass = NULL;
static char *rpc_pass = NULL;
static char *short_url = NULL;
char *opt_cert = NULL;
char *opt_proxy = NULL;
long opt_proxy_type = -1;
struct thr_info *thr_info = NULL;
static int work_thr_id = -1;
struct thr_api *thr_api = NULL;
int longpoll_thr_id = -1;
int stratum_thr_id = -1;
int api_thr_id = -1;
bool stratum_need_reset = false;
struct work_restart *work_restart = NULL;
struct stratum_ctx stratum = { 0 };

static pthread_mutex_t stats_lock = PTHREAD_MUTEX_INITIALIZER;
uint32_t accepted_count = 0L;
uint32_t rejected_count = 0L;
static double thr_hashrates[MAX_GPUS] = { 0 };
uint64_t global_hashrate = 0;
double   global_diff = 0.0;
uint32_t opt_statsavg = 30;
static char* opt_syslog_pfx = NULL;
char *opt_api_allow = NULL;
int opt_api_listen = 0; /* 0 to disable */

#ifdef HAVE_GETOPT_LONG
#include <getopt.h>
#else
struct option {
	const char *name;
	int has_arg;
	int *flag;
	int val;
};
#endif
>>>>>>> 8c320ca... added xevan

static char const usage[] = "\
Usage: " PROGRAM_NAME " [OPTIONS]\n\
Options:\n\
  -a, --algo=ALGO       specify the hash algorithm to use\n\
<<<<<<< HEAD
			bastion     Hefty bastion\n\
			bitcore     Timetravel-10\n\
			blake       Blake 256 (SFR)\n\
			blake2s     Blake2-S 256 (NEVA)\n\
			blakecoin   Fast Blake 256 (8 rounds)\n\
			bmw         BMW 256\n\
			cryptolight AEON cryptonight (MEM/2)\n\
			cryptonight XMR cryptonight\n\
			c11/flax    X11 variant\n\
			decred      Decred Blake256\n\
			deep        Deepcoin\n\
			equihash    Zcash Equihash\n\
=======
			bastion		bastioncoin\n\
			bitcoin     Bitcoin\n\
			blake       Blake 256 (SFR/NEOS)\n\
			blakecoin   Fast Blake 256 (8 rounds)\n\
			c11/flax    X11 variant\n\
            credit      Credit\n\
			deep        Deepcoin\n\
>>>>>>> 8c320ca... added xevan
			dmd-gr      Diamond-Groestl\n\
			fresh       Freshcoin (shavite 80)\n\
			fugue256    Fuguecoin\n\
			groestl     Groestlcoin\n\
			heavy       Heavycoin\n\
<<<<<<< HEAD
			hmq1725     Doubloons / Espers\n\
			jha         JHA v8 (JackpotCoin)\n\
			keccak      Keccak-256 (Maxcoin)\n\
			lbry        LBRY Credits (Sha/Ripemd)\n\
			luffa       Joincoin\n\
			lyra2       CryptoCoin\n\
			lyra2v2     VertCoin\n\
			lyra2z      ZeroCoin (3rd impl)\n\
			mjollnir    Mjollnircoin\n\
			myr-gr      Myriad-Groestl\n\
			neoscrypt   FeatherCoin, Phoenix, UFO...\n\
			nist5       NIST5 (TalkCoin)\n\
			penta       Pentablake hash (5x Blake 512)\n\
			quark       Quark\n\
			qubit       Qubit\n\
			sha256d     SHA256d (bitcoin)\n\
			sha256t     SHA256 x3\n\
			sia         SIA (Blake2B)\n\
			sib         Sibcoin (X11+Streebog)\n\
			scrypt      Scrypt\n\
			scrypt-jane Scrypt-jane Chacha\n\
			skein       Skein SHA2 (Skeincoin)\n\
			skein2      Double Skein (Woodcoin)\n\
			skunk       Skein Cube Fugue Streebog\n\
			s3          S3 (1Coin)\n\
			timetravel  Machinecoin permuted x8\n\
			tribus      Denerius\n\
			vanilla     Blake256-8 (VNL)\n\
			veltor      Thorsriddle streebog\n\
			whirlcoin   Old Whirlcoin (Whirlpool algo)\n\
			whirlpool   Whirlpool algo\n\
			x11evo      Permuted x11 (Revolver)\n\
=======
			jackpot     Jackpot\n\
			keccak      Keccak-256 (Maxcoin)\n\
			luffa       Doomcoin\n\
			lyra2       Lyrabar\n\
			lyra2v2     VertCoin\n\
			mjollnir    Mjollnircoin\n\
			myr-gr      Myriad-Groestl\n\
            neoscrypt   neoscrypt (FeatherCoin)\n\
			nist5       NIST5 (TalkCoin)\n\
			penta       Pentablake hash (5x Blake 512)\n\
			quark       Quark\n\
			qubit       qubit\n\
			scrypt      Scrypt\n\
			scrypt-jane Scrypt-jane Chacha\n\
			skein       Skein\n\
			s3          S3 (1Coin)\n\
			spread      Spread\n\
>>>>>>> 8c320ca... added xevan
			x11         X11 (DarkCoin)\n\
			x13         X13 (MaruCoin)\n\
			x14         X14\n\
			x15         X15\n\
<<<<<<< HEAD
			x17         X17\n\
			wildkeccak  Boolberry\n\
			zr5         ZR5 (ZiftrCoin)\n\
  -d, --devices         Comma separated list of CUDA devices to use.\n\
                        Device IDs start counting from 0! Alternatively takes\n\
                        string names of your cards like gtx780ti or gt640#2\n\
                        (matching 2nd gt640 in the PC)\n\
  -i  --intensity=N[,N] GPU intensity 8.0-25.0 (default: auto) \n\
                        Decimals are allowed for fine tuning \n\
      --cuda-schedule   Set device threads scheduling mode (default: auto)\n\
  -f, --diff-factor     Divide difficulty by this factor (default 1.0) \n\
  -m, --diff-multiplier Multiply difficulty by this value (default 1.0) \n\
      --vote=VOTE       vote (for decred and HeavyCoin)\n\
      --trust-pool      trust the max block reward vote (maxvote) sent by the pool\n\
=======
			x17         X17 (peoplecurrency)\n\
			xevan       XEVAN (bitsend)\n\
			Vanilla (Blake256 8-rounds - double sha256)\n\
			yescrypt    yescrypt\n\
			whirl       Whirlcoin (old whirlpool)\n\
			whirlpoolx  Vanillacoin \n\
  -d, --devices         Comma separated list of CUDA devices to use. \n\
                        Device IDs start counting from 0! Alternatively takes\n\
                        string names of your cards like gtx780ti or gt640#2\n\
                        (matching 2nd gt640 in the PC)\n\
  -i  --intensity=N     GPU intensity 8-31 (default: auto) \n\
                        Decimals are allowed for fine tuning \n\
  -f, --diff            Divide difficulty by this factor (std is 1) \n\
  -v, --vote=VOTE       block reward vote (for HeavyCoin)\n\
  -m, --trust-pool      trust the max block reward vote (maxvote) sent by the pool\n\
>>>>>>> 8c320ca... added xevan
  -o, --url=URL         URL of mining server\n\
  -O, --userpass=U:P    username:password pair for mining server\n\
  -u, --user=USERNAME   username for mining server\n\
  -p, --pass=PASSWORD   password for mining server\n\
      --cert=FILE       certificate for mining server using SSL\n\
  -x, --proxy=[PROTOCOL://]HOST[:PORT]  connect through a proxy\n\
  -t, --threads=N       number of miner threads (default: number of nVidia GPUs)\n\
<<<<<<< HEAD
  -r, --retries=N       number of times to retry if a network call fails\n\
                          (default: retry indefinitely)\n\
  -R, --retry-pause=N   time to pause between retries, in seconds (default: 30)\n\
      --shares-limit    maximum shares [s] to mine before exiting the program.\n\
      --time-limit      maximum time [s] to mine before exiting the program.\n\
  -T, --timeout=N       network timeout, in seconds (default: 300)\n\
  -s, --scantime=N      upper bound on time spent scanning current work when\n\
                          long polling is unavailable, in seconds (default: 10)\n\
  -n, --ndevs           list cuda devices\n\
  -N, --statsavg        number of samples used to compute hashrate (default: 30)\n\
      --no-gbt          disable getblocktemplate support (height check in solo)\n\
      --no-longpoll     disable X-Long-Polling support\n\
      --no-stratum      disable X-Stratum support\n\
      --no-extranonce   disable extranonce subscribe on stratum\n\
=======
  -g, --gputhreads=N    number of threads per gpu (default: 1)\n\
  -r, --retries=N       number of times to retry if a network call fails\n\
                          (default: retry indefinitely)\n\
  -R, --retry-pause=N   time to pause between retries, in seconds (default: 30)\n\
      --time-limit      maximum time [s] to mine before exiting the program.\n\
  -T, --timeout=N       network timeout, in seconds (default: 270)\n\
  -s, --scantime=N      upper bound on time spent scanning current work when\n\
                          long polling is unavailable, in seconds (default: 5)\n\
  -n, --ndevs           list cuda devices\n\
  -N, --statsavg        number of samples used to display hashrate (default: 30)\n\
      --no-gbt          disable getblocktemplate support (height check in solo)\n\
      --no-longpoll     disable X-Long-Polling support\n\
      --no-stratum      disable X-Stratum support\n\
>>>>>>> 8c320ca... added xevan
  -q, --quiet           disable per-thread hashmeter output\n\
      --no-color        disable colored output\n\
  -D, --debug           enable debug output\n\
  -P, --protocol-dump   verbose dump of protocol-level activities\n\
      --cpu-affinity    set process affinity to cpu core(s), mask 0x3 for cores 0 and 1\n\
<<<<<<< HEAD
      --cpu-priority    set process priority (default: 3) 0 idle, 2 normal to 5 highest\n\
  -b, --api-bind=port   IP:port for the miner API (default: 127.0.0.1:4068), 0 disabled\n\
      --api-remote      Allow remote control, like pool switching, imply --api-allow=0/0\n\
      --api-allow=...   IP/mask of the allowed api client(s), 0/0 for all\n\
      --max-temp=N      Only mine if gpu temp is less than specified value\n\
      --max-rate=N[KMG] Only mine if net hashrate is less than specified value\n\
      --max-diff=N      Only mine if net difficulty is less than specified value\n\
                        Can be tuned with --resume-diff=N to set a resume value\n\
      --max-log-rate    Interval to reduce per gpu hashrate logs (default: 3)\n"
#if defined(__linux) /* via nvml */
"\
      --mem-clock=3505  Set the gpu memory max clock (346.72+ driver)\n\
      --gpu-clock=1150  Set the gpu engine max clock (346.72+ driver)\n\
      --pstate=0[,2]    Set the gpu power state (352.21+ driver)\n\
      --plimit=100W     Set the gpu power limit (352.21+ driver)\n"
#else /* via nvapi.dll */
"\
      --mem-clock=3505  Set the gpu memory boost clock\n\
      --mem-clock=+500  Set the gpu memory offset\n\
      --gpu-clock=1150  Set the gpu engine boost clock\n\
      --plimit=100      Set the gpu power limit in percentage\n\
      --tlimit=80       Set the gpu thermal limit in degrees\n\
      --led=100         Set the logo led level (0=disable, 0xFF00FF for RVB)\n"
#endif
#ifdef HAVE_SYSLOG_H
"\
  -S, --syslog          use system log for output messages\n\
      --syslog-prefix=... allow to change syslog tool name\n"
#endif
"\
      --hide-diff       hide submitted block and net difficulty (old mode)\n\
  -B, --background      run the miner in the background\n\
      --benchmark       run in offline benchmark mode\n\
      --cputest         debug hashes from cpu algorithms\n\
  -c, --config=FILE     load a JSON-format configuration file\n\
  -V, --version         display version information and exit\n\
  -h, --help            display this help text and exit\n\
";

static char const short_options[] =
#ifdef HAVE_SYSLOG_H
	"S"
#endif
	"a:Bc:k:i:Dhp:Px:f:m:nqr:R:s:t:T:o:u:O:Vd:N:b:l:L:";

struct option options[] = {
	{ "algo", 1, NULL, 'a' },
	{ "api-bind", 1, NULL, 'b' },
	{ "api-remote", 0, NULL, 1030 },
	{ "api-allow", 1, NULL, 1031 },
	{ "api-groups", 1, NULL, 1032 },
	{ "api-mcast", 0, NULL, 1033 },
	{ "api-mcast-addr", 1, NULL, 1034 },
	{ "api-mcast-code", 1, NULL, 1035 },
	{ "api-mcast-port", 1, NULL, 1036 },
	{ "api-mcast-des", 1, NULL, 1037 },
	{ "background", 0, NULL, 'B' },
=======
      --cpu-priority    set process priority (default: 0 idle, 2 normal to 5 highest)\n\
  -b, --api-bind        IP/Port for the miner API (default: 127.0.0.1:4068)\n\
  -S, --syslog          use system log for output messages\n\
  --syslog - prefix = ... allow to change syslog tool name\n\
   -B, --background      run the miner in the background\n\
		--benchmark       run in offline benchmark mode\n\
      --cputest         debug hashes from cpu algorithms\n\
  -c, --config=FILE     load a JSON-format configuration file\n\
  -C, --cpu-mining		Enable the cpu to aid the gpu. (warning: uses more power)\n\
  -V, --version         display version information and exit\n\
  -h, --help            display this help text and exit\n\
  -X,  --XIntensity     intensity GPU intensity(default: auto) \n\
      --broken-neo-wallet	Use 84byte data for broken neoscrypt wallets.\n\
";

char const short_options[] = "SX:a:c:i:Dhp:Px:qr:R:s:t:T:o:u:O:Vd:f:mv:N:n:b:g:l:L:e:M:C";

struct option const options[] = {
	{ "algo", 1, NULL, 'a' },
	{ "api-bind", 1, NULL, 'b' },
>>>>>>> 8c320ca... added xevan
	{ "benchmark", 0, NULL, 1005 },
	{ "cert", 1, NULL, 1001 },
	{ "config", 1, NULL, 'c' },
	{ "cputest", 0, NULL, 1006 },
	{ "cpu-affinity", 1, NULL, 1020 },
	{ "cpu-priority", 1, NULL, 1021 },
<<<<<<< HEAD
	{ "cuda-schedule", 1, NULL, 1025 },
=======
>>>>>>> 8c320ca... added xevan
	{ "debug", 0, NULL, 'D' },
	{ "help", 0, NULL, 'h' },
	{ "intensity", 1, NULL, 'i' },
	{ "ndevs", 0, NULL, 'n' },
	{ "no-color", 0, NULL, 1002 },
<<<<<<< HEAD
	{ "no-extranonce", 0, NULL, 1012 },
=======
>>>>>>> 8c320ca... added xevan
	{ "no-gbt", 0, NULL, 1011 },
	{ "no-longpoll", 0, NULL, 1003 },
	{ "no-stratum", 0, NULL, 1007 },
	{ "no-autotune", 0, NULL, 1004 },  // scrypt
<<<<<<< HEAD
	{ "interactive", 1, NULL, 1050 },  // scrypt
	{ "lookup-gap", 1, NULL, 'L' },    // scrypt
	{ "texture-cache", 1, NULL, 1051 },// scrypt
	{ "launch-config", 1, NULL, 'l' }, // scrypt bbr xmr
	{ "scratchpad", 1, NULL, 'k' },    // bbr
	{ "bfactor", 1, NULL, 1055 },      // xmr
	{ "max-temp", 1, NULL, 1060 },
	{ "max-diff", 1, NULL, 1061 },
	{ "max-rate", 1, NULL, 1062 },
	{ "resume-diff", 1, NULL, 1063 },
	{ "resume-rate", 1, NULL, 1064 },
	{ "resume-temp", 1, NULL, 1065 },
	{ "pass", 1, NULL, 'p' },
	{ "pool-name", 1, NULL, 1100 },     // pool
	{ "pool-algo", 1, NULL, 1101 },     // pool
	{ "pool-scantime", 1, NULL, 1102 }, // pool
	{ "pool-shares-limit", 1, NULL, 1109 },
	{ "pool-time-limit", 1, NULL, 1108 },
	{ "pool-max-diff", 1, NULL, 1161 }, // pool
	{ "pool-max-rate", 1, NULL, 1162 }, // pool
	{ "pool-disabled", 1, NULL, 1199 }, // pool
=======
	{ "launch-config", 0, NULL, 'l' }, // scrypt
	{ "lookup-gap", 0, NULL, 'L' },    // scrypt
	{ "pass", 1, NULL, 'p' },
>>>>>>> 8c320ca... added xevan
	{ "protocol-dump", 0, NULL, 'P' },
	{ "proxy", 1, NULL, 'x' },
	{ "quiet", 0, NULL, 'q' },
	{ "retries", 1, NULL, 'r' },
	{ "retry-pause", 1, NULL, 'R' },
<<<<<<< HEAD
	{ "scantime", 1, NULL, 's' },
	{ "show-diff", 0, NULL, 1013 },
	{ "hide-diff", 0, NULL, 1014 },
	{ "statsavg", 1, NULL, 'N' },
	{ "gpu-clock", 1, NULL, 1070 },
	{ "mem-clock", 1, NULL, 1071 },
	{ "pstate", 1, NULL, 1072 },
	{ "plimit", 1, NULL, 1073 },
	{ "keep-clocks", 0, NULL, 1074 },
	{ "tlimit", 1, NULL, 1075 },
	{ "led", 1, NULL, 1080 },
	{ "max-log-rate", 1, NULL, 1019 },
#ifdef HAVE_SYSLOG_H
	{ "syslog", 0, NULL, 'S' },
	{ "syslog-prefix", 1, NULL, 1018 },
#endif
	{ "shares-limit", 1, NULL, 1009 },
	{ "time-limit", 1, NULL, 1008 },
	{ "threads", 1, NULL, 't' },
	{ "vote", 1, NULL, 1022 },
	{ "trust-pool", 0, NULL, 1023 },
=======
	{ "syslog", 0, NULL, 'S' },
	{ "syslog-prefix", 1, NULL, 1008 },
	{ "scantime", 1, NULL, 's' },
	{ "statsavg", 1, NULL, 'N' },
	{ "time-limit", 1, NULL, 1008 },
	{ "threads", 1, NULL, 't' },
	{ "gputhreads", 1, NULL, 'g' },
	{ "gpu-engine", 1, NULL, 1070 },
	{ "gpu-memclock", 1, NULL, 1071 },
	{ "Disable extranounce support", 1, NULL, 'e' },
	{ "vote", 1, NULL, 'v' },
	{ "trust-pool", 0, NULL, 'm' },
>>>>>>> 8c320ca... added xevan
	{ "timeout", 1, NULL, 'T' },
	{ "url", 1, NULL, 'o' },
	{ "user", 1, NULL, 'u' },
	{ "userpass", 1, NULL, 'O' },
	{ "version", 0, NULL, 'V' },
	{ "devices", 1, NULL, 'd' },
<<<<<<< HEAD
	{ "diff-multiplier", 1, NULL, 'm' },
	{ "diff-factor", 1, NULL, 'f' },
	{ "diff", 1, NULL, 'f' }, // compat
=======
	{ "diff", 1, NULL, 'f' },
	{ "X", 1, NULL, 'X'},
	{ "cpu-mining", 0, NULL, 'C'},
	{ "broken-neo-wallet", 0, NULL, 1030},
>>>>>>> 8c320ca... added xevan
	{ 0, 0, 0, 0 }
};

static char const scrypt_usage[] = "\n\
<<<<<<< HEAD
Scrypt specific options:\n\
  -l, --launch-config   gives the launch configuration for each kernel\n\
                        in a comma separated list, one per device.\n\
  -L, --lookup-gap      Divides the per-hash memory requirement by this factor\n\
                        by storing only every N'th value in the scratchpad.\n\
                        Default is 1.\n\
      --interactive     comma separated list of flags (0/1) specifying\n\
                        which of the CUDA device you need to run at inter-\n\
                        active frame rates (because it drives a display).\n\
      --texture-cache   comma separated list of flags (0/1/2) specifying\n\
                        which of the CUDA devices shall use the texture\n\
                        cache for mining. Kepler devices may profit.\n\
      --no-autotune     disable auto-tuning of kernel launch parameters\n\
";

static char const xmr_usage[] = "\n\
CryptoNight specific options:\n\
  -l, --launch-config   gives the launch configuration for each kernel\n\
                        in a comma separated list, one per device.\n\
      --bfactor=[0-12]  Run Cryptonight core kernel in smaller pieces,\n\
                        From 0 (ui freeze) to 12 (smooth), win default is 11\n\
                        This is a per-device setting like the launch config.\n\
";

static char const bbr_usage[] = "\n\
Boolberry specific options:\n\
  -l, --launch-config   gives the launch configuration for each kernel\n\
                        in a comma separated list, one per device.\n\
  -k, --scratchpad url  Url used to download the scratchpad cache.\n\
";

struct work _ALIGN(64) g_work;
volatile time_t g_work_time;
pthread_mutex_t g_work_lock;

// get const array size (defined in ccminer.cpp)
int options_count()
{
	int n = 0;
	while (options[n].name != NULL)
		n++;
	return n;
}
=======
									Scrypt specific options:\n\
									  -l, --launch-config   gives the launch configuration for each kernel\n\
									                        in a comma separated list, one per device.\n\
									  -L, --lookup-gap      Divides the per-hash memory requirement by this factor\n\
									                        by storing only every N'th value in the scratchpad.\n\
									                        Default is 1.\n\
									      --no-autotune     disable auto-tuning of kernel launch parameters\n\
									";

static struct work _ALIGN(64) g_work;
static time_t g_work_time;
static pthread_mutex_t g_work_lock = PTHREAD_MUTEX_INITIALIZER;

>>>>>>> 8c320ca... added xevan

#ifdef __linux /* Linux specific policy and affinity management */
#include <sched.h>
static inline void drop_policy(void) {
	struct sched_param param;
	param.sched_priority = 0;
#ifdef SCHED_IDLE
	if (unlikely(sched_setscheduler(0, SCHED_IDLE, &param) == -1))
#endif
#ifdef SCHED_BATCH
		sched_setscheduler(0, SCHED_BATCH, &param);
#endif
}
<<<<<<< HEAD

static void affine_to_cpu_mask(int id, unsigned long mask) {
=======
static void affine_to_cpu_mask(int id, uint8_t mask) {
>>>>>>> 8c320ca... added xevan
	cpu_set_t set;
	CPU_ZERO(&set);
	for (uint8_t i = 0; i < num_cpus; i++) {
		// cpu mask
<<<<<<< HEAD
		if (mask & (1UL<<i)) { CPU_SET(i, &set); }
=======
		if (mask & (1<<i)) { CPU_SET(i, &set); }
>>>>>>> 8c320ca... added xevan
	}
	if (id == -1) {
		// process affinity
		sched_setaffinity(0, sizeof(&set), &set);
	} else {
		// thread only
		pthread_setaffinity_np(thr_info[id].pth, sizeof(&set), &set);
	}
}
#elif defined(__FreeBSD__) /* FreeBSD specific policy and affinity management */
#include <sys/cpuset.h>
static inline void drop_policy(void) { }
<<<<<<< HEAD
static void affine_to_cpu_mask(int id, unsigned long mask) {
	cpuset_t set;
	CPU_ZERO(&set);
	for (uint8_t i = 0; i < num_cpus; i++) {
		if (mask & (1UL<<i)) CPU_SET(i, &set);
	}
	cpuset_setaffinity(CPU_LEVEL_WHICH, CPU_WHICH_TID, -1, sizeof(cpuset_t), &set);
}
#elif defined(WIN32) /* Windows */
static inline void drop_policy(void) { }
static void affine_to_cpu_mask(int id, unsigned long mask) {
=======
static void affine_to_cpu_mask(int id, uint8_t mask) {
	cpuset_t set;
	CPU_ZERO(&set);
	for (uint8_t i = 0; i < num_cpus; i++) {
		if (mask & (1<<i)) CPU_SET(i, &set);
	}
	cpuset_setaffinity(CPU_LEVEL_WHICH, CPU_WHICH_TID, -1, sizeof(cpuset_t), &set);
}
#else /* Windows */
static inline void drop_policy(void) { }
static void affine_to_cpu_mask(int id, uint8_t mask) {
>>>>>>> 8c320ca... added xevan
	if (id == -1)
		SetProcessAffinityMask(GetCurrentProcess(), mask);
	else
		SetThreadAffinityMask(GetCurrentThread(), mask);
}
<<<<<<< HEAD
#else /* Martians */
static inline void drop_policy(void) { }
static void affine_to_cpu_mask(int id, uint8_t mask) { }
=======
>>>>>>> 8c320ca... added xevan
#endif

static bool get_blocktemplate(CURL *curl, struct work *work);

void get_currentalgo(char* buf, int sz)
{
	snprintf(buf, sz, "%s", algo_names[opt_algo]);
}

<<<<<<< HEAD
void format_hashrate(double hashrate, char *output)
{
	if (opt_algo == ALGO_EQUIHASH)
		format_hashrate_unit(hashrate, output, "Sol/s");
	else
		format_hashrate_unit(hashrate, output, "H/s");
}

/**
 * Exit app
 */
void proper_exit(int reason)
{
	restart_threads();
	if (abort_flag) /* already called */
		return;

	abort_flag = true;
	usleep(200 * 1000);
	cuda_shutdown();

	if (reason == EXIT_CODE_OK && app_exit_code != EXIT_CODE_OK) {
		reason = app_exit_code;
	}

	pthread_mutex_lock(&stats_lock);
	if (check_dups)
		hashlog_purge_all();
	stats_purge_all();
	pthread_mutex_unlock(&stats_lock);

#ifdef WIN32
	timeEndPeriod(1); // else never executed
#endif
#ifdef USE_WRAPNVML
	if (hnvml) {
		for (int n=0; n < opt_n_threads && !opt_keep_clocks; n++) {
			nvml_reset_clocks(hnvml, device_map[n]);
		}
		nvml_destroy(hnvml);
	}
	if (need_memclockrst) {
#	ifdef WIN32
		for (int n = 0; n < opt_n_threads && !opt_keep_clocks; n++) {
			nvapi_toggle_clocks(n, false);
		}
#	endif
	}
#endif
	free(opt_syslog_pfx);
	free(opt_api_bind);
	if (opt_api_allow) free(opt_api_allow);
	if (opt_api_groups) free(opt_api_groups);
	free(opt_api_mcast_addr);
	free(opt_api_mcast_code);
	free(opt_api_mcast_des);
	//free(work_restart);
	//free(thr_info);
	exit(reason);
}

bool jobj_binary(const json_t *obj, const char *key, void *buf, size_t buflen)
=======
/**
 * Exit app
 */

#define CCEXIT_SIG -1
void proper_exit(int reason)
{
	struct thr_info* thr = NULL;

	abort_flag = true;

        if (thr_info && work_thr_id != -1)
          thr = &thr_info[work_thr_id];
        if (thr && thr->q)
          tq_freeze(thr->q);

	if (reason != CCEXIT_SIG) {
#ifdef USE_WRAPNVML
		if (hnvml)
			nvml_destroy(hnvml);
#endif

		free(opt_syslog_pfx);
		opt_syslog_pfx = NULL;
		free(opt_api_allow);
		opt_api_allow = NULL;
		hashlog_purge_all();
		stats_purge_all();
		cuda_devicereset();
	}
}

static bool jobj_binary(const json_t *obj, const char *key,
			void *buf, size_t buflen)
>>>>>>> 8c320ca... added xevan
{
	const char *hexstr;
	json_t *tmp;

	tmp = json_object_get(obj, key);
	if (unlikely(!tmp)) {
		applog(LOG_ERR, "JSON key '%s' not found", key);
		return false;
	}
	hexstr = json_string_value(tmp);
	if (unlikely(!hexstr)) {
		applog(LOG_ERR, "JSON key '%s' is not a string", key);
		return false;
	}
	if (!hex2bin((uchar*)buf, hexstr, buflen))
		return false;

	return true;
}

<<<<<<< HEAD
/* compute nbits to get the network diff */
static void calc_network_diff(struct work *work)
{
	// sample for diff 43.281 : 1c05ea29
	// todo: endian reversed on longpoll could be zr5 specific...
	uint32_t nbits = have_longpoll ? work->data[18] : swab32(work->data[18]);
	if (opt_algo == ALGO_LBRY) nbits = swab32(work->data[26]);
	if (opt_algo == ALGO_DECRED) nbits = work->data[29];
	if (opt_algo == ALGO_SIA) nbits = work->data[11]; // unsure if correct
	if (opt_algo == ALGO_EQUIHASH) {
		net_diff = equi_network_diff(work);
		return;
	}

	uint32_t bits = (nbits & 0xffffff);
	int16_t shift = (swab32(nbits) & 0xff); // 0x1c = 28

	uint64_t diffone = 0x0000FFFF00000000ull;
	double d = (double)0x0000ffff / (double)bits;

	for (int m=shift; m < 29; m++) d *= 256.0;
	for (int m=29; m < shift; m++) d /= 256.0;
	if (opt_algo == ALGO_DECRED && shift == 28) d *= 256.0;
	if (opt_debug_diff)
		applog(LOG_DEBUG, "net diff: %f -> shift %u, bits %08x", d, shift, bits);

	net_diff = d;
}

/* decode data from getwork (wallets and longpoll pools) */
static bool work_decode(const json_t *val, struct work *work)
{
	int data_size, target_size = sizeof(work->target);
	int adata_sz, atarget_sz = ARRAY_SIZE(work->target);
	int i;

	switch (opt_algo) {
	case ALGO_DECRED:
		data_size = 192;
		adata_sz = 180/4;
		break;
	case ALGO_NEOSCRYPT:
	case ALGO_ZR5:
		data_size = 80;
		adata_sz = data_size / 4;
		break;
	case ALGO_CRYPTOLIGHT:
	case ALGO_CRYPTONIGHT:
	case ALGO_WILDKECCAK:
		return rpc2_job_decode(val, work);
	default:
		data_size = 128;
		adata_sz = data_size / 4;
	}

	if (!jobj_binary(val, "data", work->data, data_size)) {
		json_t *obj = json_object_get(val, "data");
		int len = obj ? (int) strlen(json_string_value(obj)) : 0;
		if (!len || len > sizeof(work->data)*2) {
			applog(LOG_ERR, "JSON invalid data (len %d <> %d)", len/2, data_size);
			return false;
		} else {
			data_size = len / 2;
			if (!jobj_binary(val, "data", work->data, data_size)) {
				applog(LOG_ERR, "JSON invalid data (len %d)", data_size);
				return false;
			}
		}
	}

	if (!jobj_binary(val, "target", work->target, target_size)) {
		applog(LOG_ERR, "JSON invalid target");
		return false;
	}

=======

static bool work_decode(const json_t *val, struct work *work)
{
	int data_size, midstate_size;
	switch (opt_algo) {
	case ALGO_NEO:
		data_size = opt_broken_neo_wallet ? 84 : 80;
		break;
	case ALGO_BITC:
		data_size = 168;
		midstate_size = sizeof(work->midstate);
		break;
	default:
		data_size = 128; // original sizeof(work->data); however data is now 64*4bit
	}
	int adata_sz = data_size >> 2;
	int target_size = sizeof(work->target);
	int atarget_sz = target_size >> 2;
	int i;
	//	printf("data size %d",data_size);
	if (unlikely(!jobj_binary(val, "data", work->data, data_size))) {
		applog(LOG_ERR, "JSON inval data");
		return false;
	}
	if (unlikely(!jobj_binary(val, "target", work->target, target_size))) {
		applog(LOG_ERR, "JSON inval target");
		return false;
	}

	if (opt_algo == ALGO_BITC) {
		if (unlikely(!jobj_binary(val, "midstate", work->midstate, midstate_size))) {
			applog(LOG_ERR, "JSON inval midstate");
			return false;
		}

		for (i = 0; i < midstate_size>>2; i++)
			work->midstate[i] = le32dec(work->midstate + i);
	}


>>>>>>> 8c320ca... added xevan
	if (opt_algo == ALGO_HEAVY) {
		if (unlikely(!jobj_binary(val, "maxvote", &work->maxvote, sizeof(work->maxvote)))) {
			work->maxvote = 2048;
		}
<<<<<<< HEAD
	} else work->maxvote = 0;

	for (i = 0; i < adata_sz; i++)
		work->data[i] = le32dec(work->data + i);
	for (i = 0; i < atarget_sz; i++)
		work->target[i] = le32dec(work->target + i);

	if ((opt_showdiff || opt_max_diff > 0.) && !allow_mininginfo)
		calc_network_diff(work);

	work->targetdiff = target_to_diff(work->target);

	// for api stats, on longpoll pools
	stratum_diff = work->targetdiff;

	work->tx_count = use_pok = 0;
	if (opt_algo == ALGO_ZR5 && work->data[0] & POK_BOOL_MASK) {
		use_pok = 1;
		json_t *txs = json_object_get(val, "txs");
		if (txs && json_is_array(txs)) {
			size_t idx, totlen = 0;
			json_t *p;

			json_array_foreach(txs, idx, p) {
				const int tx = work->tx_count % POK_MAX_TXS;
				const char* hexstr = json_string_value(p);
				size_t txlen = strlen(hexstr)/2;
				work->tx_count++;
				if (work->tx_count > POK_MAX_TXS || txlen >= POK_MAX_TX_SZ) {
					// when tx is too big, just reset use_pok for the block
					use_pok = 0;
					if (opt_debug) applog(LOG_WARNING,
						"pok: large block ignored, tx len: %u", txlen);
					work->tx_count = 0;
					break;
				}
				hex2bin((uchar*)work->txs[tx].data, hexstr, min(txlen, POK_MAX_TX_SZ));
				work->txs[tx].len = (uint32_t) (txlen);
				totlen += txlen;
			}
			if (opt_debug)
				applog(LOG_DEBUG, "block txs: %u, total len: %u", work->tx_count, totlen);
=======
	}
	else work->maxvote = 0;
	//	printf("the data: \n");
	for (i = 0; i < adata_sz; i++)
		work->data[i] = le32dec(work->data + i);

	//		printf("i %d %08x \n",i, work->data[i]);}
	//	printf("\n");
	for (i = 0; i < atarget_sz; i++)
		work->target[i] = le32dec(work->target + i);

	json_t *jr = json_object_get(val, "noncerange");
	if (jr) {
		const char * hexstr = json_string_value(jr);
		if (likely(hexstr)) {
			// never seen yet...
			hex2bin((uchar*)work->noncerange.u64, hexstr, 8);
			applog(LOG_DEBUG, "received noncerange: %08x-%08x",
				work->noncerange.u32[0], work->noncerange.u32[1]);
>>>>>>> 8c320ca... added xevan
		}
	}

	/* use work ntime as job id (solo-mining) */
	cbin2hex(work->job_id, (const char*)&work->data[17], 4);

<<<<<<< HEAD
	if (opt_algo == ALGO_DECRED) {
		uint16_t vote;
		// always keep last bit of votebits
		memcpy(&vote, &work->data[25], 2);
		vote = (opt_vote << 1) | (vote & 1);
		memcpy(&work->data[25], &vote, 2);
		// some random extradata to make it unique
		work->data[36] = (rand()*4);
		work->data[37] = (rand()*4) << 8;
		// required for the longpoll pool block info...
		work->height = work->data[32];
		if (!have_longpoll && work->height > net_blocks + 1) {
			char netinfo[64] = { 0 };
			if (opt_showdiff && net_diff > 0.) {
				if (net_diff != work->targetdiff)
					sprintf(netinfo, ", diff %.3f, pool %.1f", net_diff, work->targetdiff);
				else
					sprintf(netinfo, ", diff %.3f", net_diff);
			}
			applog(LOG_BLUE, "%s block %d%s",
				algo_names[opt_algo], work->height, netinfo);
			net_blocks = work->height - 1;
		}
		cbin2hex(work->job_id, (const char*)&work->data[34], 4);
	}

	return true;
}

#define YES "yes!"
#define YAY "yay!!!"
#define BOO "booooo"

int share_result(int result, int pooln, double sharediff, const char *reason)
{
	const char *flag;
	char suppl[32] = { 0 };
	char solved[16] = { 0 };
	char s[32] = { 0 };
	double hashrate = 0.;
	struct pool_infos *p = &pools[pooln];

	pthread_mutex_lock(&stats_lock);
	for (int i = 0; i < opt_n_threads; i++) {
		hashrate += stats_get_speed(i, thr_hashrates[i]);
	}
	pthread_mutex_unlock(&stats_lock);

	result ? p->accepted_count++ : p->rejected_count++;

	p->last_share_time = time(NULL);
	if (sharediff > p->best_share)
		p->best_share = sharediff;

	global_hashrate = llround(hashrate);

	format_hashrate(hashrate, s);
	if (opt_showdiff)
		sprintf(suppl, "diff %.3f", sharediff);
	else // accepted percent
		sprintf(suppl, "%.2f%%", 100. * p->accepted_count / (p->accepted_count + p->rejected_count));

	if (!net_diff || sharediff < net_diff) {
		flag = use_colors ?
			(result ? CL_GRN YES : CL_RED BOO)
		:	(result ? "(" YES ")" : "(" BOO ")");
	} else {
		p->solved_count++;
		flag = use_colors ?
			(result ? CL_GRN YAY : CL_RED BOO)
		:	(result ? "(" YAY ")" : "(" BOO ")");
		sprintf(solved, " solved: %u", p->solved_count);
	}

	applog(LOG_NOTICE, "accepted: %lu/%lu (%s), %s %s%s",
			p->accepted_count,
			p->accepted_count + p->rejected_count,
			suppl, s, flag, solved);
	if (reason) {
		applog(LOG_WARNING, "reject reason: %s", reason);
		if (!check_dups && strncasecmp(reason, "duplicate", 9) == 0) {
			applog(LOG_WARNING, "enabling duplicates check feature");
			check_dups = true;
			g_work_time = 0;
		}
=======
	return true;
}

/**
 * Calculate the work difficulty as double
 * Not sure it works with pools
 */
static void calc_diff(struct work *work, int known)
{
	// sample for diff 32.53 : 00000007de5f0000
	const uint64_t diffone = 0xFFFF000000000000ull;
	uint64_t *data64, d64;
	char rtarget[32];

	swab256(rtarget, work->target);
	data64 = (uint64_t *)(rtarget + 3); /* todo: index (3) can be tuned here */

	if (opt_algo == ALGO_HEAVY) {
		data64 = (uint64_t *)(rtarget + 2);
	}

	d64 = swab64(*data64);
	if (unlikely(!d64))
		d64 = 1;
	work->difficulty = (double)diffone / d64;
	if (opt_difficulty > 0.) {
		work->difficulty /= opt_difficulty;
	}
}

static int share_result(int result, const char *reason)
{
	char s[345];
	double hashrate = 0.;
	const char *sres;

	pthread_mutex_lock(&stats_lock);

	for (int i = 0; i < opt_n_threads; i++) {
		hashrate += stats_get_speed(i, thr_hashrates[i]);
	}

	result ? accepted_count++ : rejected_count++;
	pthread_mutex_unlock(&stats_lock);

	global_hashrate = llround(hashrate);

	if (use_colors)
		sres = (result ? CL_GRN "yes!" : CL_RED "nooooo");
	else
		sres = (result ? "(yes!!!)" : "(nooooo)");

	switch (opt_algo) {
	case ALGO_BASTION:
		sprintf(s, hashrate >= 1e6 ? "%.0f" : "%.2f", hashrate);
		applog(LOG_NOTICE, "accepted: %lu/%lu (%.2f%%), %s H/s %s",
			accepted_count, accepted_count + rejected_count,
			100. * accepted_count / (accepted_count + rejected_count), s, sres);
		break;
	default:
		sprintf(s, hashrate >= 1e6 ? "%.0f" : "%.2f", hashrate / 1000.0);
		applog(LOG_NOTICE, "accepted: %lu/%lu (%.2f%%), %s kH/s %s",
			accepted_count, accepted_count + rejected_count,
			100. * accepted_count / (accepted_count + rejected_count), s, sres);
		break;
	}

	if (reason) {
		applog(LOG_WARNING, "reject reason: %s", reason);
		if (strncmp(reason, "Duplicate share", 15) == 0 && !check_dups) {
			applog(LOG_WARNING, "enabling duplicates check feature");
			check_dups = true;
		}
		return 0;

>>>>>>> 8c320ca... added xevan
	}
	return 1;
}

static bool submit_upstream_work(CURL *curl, struct work *work)
{
<<<<<<< HEAD
	char s[512];
	struct pool_infos *pool = &pools[work->pooln];
	json_t *val, *res, *reason;
	bool stale_work = false;
	int idnonce = work->submit_nonce_id;

	if (pool->type & POOL_STRATUM && stratum.rpc2) {
		struct work submit_work;
		memcpy(&submit_work, work, sizeof(struct work));
		if (!hashlog_already_submittted(submit_work.job_id, submit_work.nonces[idnonce])) {
			if (rpc2_stratum_submit(pool, &submit_work))
				hashlog_remember_submit(&submit_work, submit_work.nonces[idnonce]);
			stratum.job.shares_count++;
		}
		return true;
	}

	if (pool->type & POOL_STRATUM && stratum.is_equihash) {
		struct work submit_work;
		memcpy(&submit_work, work, sizeof(struct work));
		//if (!hashlog_already_submittted(submit_work.job_id, submit_work.nonces[idnonce])) {
			if (equi_stratum_submit(pool, &submit_work))
				hashlog_remember_submit(&submit_work, submit_work.nonces[idnonce]);
			stratum.job.shares_count++;
		//}
		return true;
	}

	/* discard if a newer block was received */
	stale_work = work->height && work->height < g_work.height;
	if (have_stratum && !stale_work && opt_algo != ALGO_ZR5 && opt_algo != ALGO_SCRYPT_JANE) {
		pthread_mutex_lock(&g_work_lock);
		if (strlen(work->job_id + 8))
			stale_work = strncmp(work->job_id + 8, g_work.job_id + 8, sizeof(g_work.job_id) - 8);
		if (stale_work) {
			pool->stales_count++;
			if (opt_debug) applog(LOG_DEBUG, "outdated job %s, new %s stales=%d",
				work->job_id + 8 , g_work.job_id + 8, pool->stales_count);
			if (!check_stratum_jobs && pool->stales_count > 5) {
				if (!opt_quiet) applog(LOG_WARNING, "Enabled stratum stale jobs workaround");
				check_stratum_jobs = true;
			}
		}
		pthread_mutex_unlock(&g_work_lock);
	}

=======
	json_t *val, *res, *reason;
	bool stale_work = false;
	char s[384];

	/* discard if a newer bloc was received */
	/*
	stale_work = work->height && work->height < g_work.height;
	if (have_stratum && !stale_work) {
	pthread_mutex_lock(&g_work_lock);
	if (strlen(work->job_id + 8))
	stale_work = strcmp(work->job_id + 8, g_work.job_id + 8);
	pthread_mutex_unlock(&g_work_lock);
	}
	*/
>>>>>>> 8c320ca... added xevan
	if (!have_stratum && !stale_work && allow_gbt) {
		struct work wheight = { 0 };
		if (get_blocktemplate(curl, &wheight)) {
			if (work->height && work->height < wheight.height) {
				if (opt_debug)
<<<<<<< HEAD
					applog(LOG_WARNING, "block %u was already solved", work->height);
=======
					applog(LOG_WARNING, "bloc %u was already solved", work->height, wheight.height);
>>>>>>> 8c320ca... added xevan
				return true;
			}
		}
	}

<<<<<<< HEAD
	if (!stale_work && opt_algo == ALGO_ZR5 && !have_stratum) {
		stale_work = (memcmp(&work->data[1], &g_work.data[1], 68));
	}

	if (!submit_old && stale_work) {
=======
	if (stale_work) {
>>>>>>> 8c320ca... added xevan
		if (opt_debug)
			applog(LOG_WARNING, "stale work detected, discarding");
		return true;
	}
<<<<<<< HEAD

	if (pool->type & POOL_STRATUM) {
		uint32_t sent = 0;
		uint32_t ntime, nonce = work->nonces[idnonce];
		char *ntimestr, *noncestr, *xnonce2str, *nvotestr;
		uint16_t nvote = 0;

		switch (opt_algo) {
		case ALGO_BLAKE:
		case ALGO_BLAKECOIN:
		case ALGO_BLAKE2S:
		case ALGO_BMW:
		case ALGO_SHA256D:
		case ALGO_SHA256T:
		case ALGO_VANILLA:
			// fast algos require that... (todo: regen hash)
			check_dups = true;
			le32enc(&ntime, work->data[17]);
			le32enc(&nonce, work->data[19]);
			break;
		case ALGO_DECRED:
			be16enc(&nvote, *((uint16_t*)&work->data[25]));
			be32enc(&ntime, work->data[34]);
			be32enc(&nonce, work->data[35]);
			break;
		case ALGO_HEAVY:
			le32enc(&ntime, work->data[17]);
			le32enc(&nonce, work->data[19]);
			be16enc(&nvote, *((uint16_t*)&work->data[20]));
			break;
		case ALGO_LBRY:
			check_dups = true;
			le32enc(&ntime, work->data[25]);
			//le32enc(&nonce, work->data[27]);
			break;
		case ALGO_SIA:
			be32enc(&ntime, work->data[10]);
			be32enc(&nonce, work->data[8]);
			break;
		case ALGO_ZR5:
			check_dups = true;
			be32enc(&ntime, work->data[17]);
			be32enc(&nonce, work->data[19]);
			break;
		default:
			le32enc(&ntime, work->data[17]);
			le32enc(&nonce, work->data[19]);
		}
=======
	calc_diff(work, 0);

	if (have_stratum) 
	{
		uint32_t sent = 0;
		uint32_t ntime, nonce;
		uint16_t nvote;
		char *ntimestr, *noncestr, *xnonce2str, *nvotestr;
		le32enc(&ntime, work->data[17]);
		le32enc(&nonce, work->data[19]);
>>>>>>> 8c320ca... added xevan
		noncestr = bin2hex((const uchar*)(&nonce), 4);

		if (check_dups)
			sent = hashlog_already_submittted(work->job_id, nonce);
		if (sent > 0) {
<<<<<<< HEAD
			sent = (uint32_t) time(NULL) - sent;
=======
			sent = (uint32_t)time(NULL) - sent;
>>>>>>> 8c320ca... added xevan
			if (!opt_quiet) {
				applog(LOG_WARNING, "nonce %s was already sent %u seconds ago", noncestr, sent);
				hashlog_dump_job(work->job_id);
			}
			free(noncestr);
			// prevent useless computing on some pools
<<<<<<< HEAD
			g_work_time = 0;
			restart_threads();
=======
			stratum_need_reset = true;
			for (int i = 0; i < opt_n_threads; i++)
				work_restart[i].restart = 1;

>>>>>>> 8c320ca... added xevan
			return true;
		}

		ntimestr = bin2hex((const uchar*)(&ntime), 4);
<<<<<<< HEAD

		if (opt_algo == ALGO_DECRED) {
			xnonce2str = bin2hex((const uchar*)&work->data[36], stratum.xnonce1_size);
		} else if (opt_algo == ALGO_SIA) {
			uint16_t high_nonce = swab32(work->data[9]) >> 16;
			xnonce2str = bin2hex((unsigned char*)(&high_nonce), 2);
		} else {
			xnonce2str = bin2hex(work->xnonce2, work->xnonce2_len);
		}

		// store to keep/display the solved ratio/diff
		stratum.sharediff = work->sharediff[idnonce];

		if (net_diff && stratum.sharediff > net_diff && (opt_debug || opt_debug_diff))
			applog(LOG_INFO, "share diff: %.5f, possible block found!!!",
				stratum.sharediff);
		else if (opt_debug_diff)
			applog(LOG_DEBUG, "share diff: %.5f (x %.1f)",
				stratum.sharediff, work->shareratio[idnonce]);

		if (opt_vote) { // ALGO_HEAVY ALGO_DECRED
			nvotestr = bin2hex((const uchar*)(&nvote), 2);
			sprintf(s, "{\"method\": \"mining.submit\", \"params\": ["
					"\"%s\", \"%s\", \"%s\", \"%s\", \"%s\", \"%s\"], \"id\":%u}",
					pool->user, work->job_id + 8, xnonce2str, ntimestr, noncestr, nvotestr, stratum.job.shares_count + 10);
			free(nvotestr);
		} else {
			sprintf(s, "{\"method\": \"mining.submit\", \"params\": ["
					"\"%s\", \"%s\", \"%s\", \"%s\", \"%s\"], \"id\":%u}",
					pool->user, work->job_id + 8, xnonce2str, ntimestr, noncestr, stratum.job.shares_count + 10);
=======
		xnonce2str = bin2hex(work->xnonce2, work->xnonce2_len);

		if (opt_algo == ALGO_HEAVY) {
			be16enc(&nvote, *((uint16_t*)&work->data[20]));
			nvotestr = bin2hex((const uchar*)(&nvote), 2);
			sprintf(s,
				"{\"method\": \"mining.submit\", \"params\": [\"%s\", \"%s\", \"%s\", \"%s\", \"%s\", \"%s\"], \"id\":4}",
				rpc_user, work->job_id + 8, xnonce2str, ntimestr, noncestr, nvotestr);
			free(nvotestr);
		}
		else {
			sprintf(s,
				"{\"method\": \"mining.submit\", \"params\": [\"%s\", \"%s\", \"%s\", \"%s\", \"%s\"], \"id\":4}",
				rpc_user, work->job_id + 8, xnonce2str, ntimestr, noncestr);
>>>>>>> 8c320ca... added xevan
		}
		free(xnonce2str);
		free(ntimestr);
		free(noncestr);

		gettimeofday(&stratum.tv_submit, NULL);
		if (unlikely(!stratum_send_line(&stratum, s))) {
			applog(LOG_ERR, "submit_upstream_work stratum_send_line failed");
<<<<<<< HEAD
			return false;
		}

		if (check_dups || opt_showdiff)
			hashlog_remember_submit(work, nonce);
		stratum.job.shares_count++;

	} else {

		int data_size = 128;
		int adata_sz = data_size / sizeof(uint32_t);

		/* build hex string */
		char *str = NULL;

		if (opt_algo == ALGO_ZR5) {
			data_size = 80; adata_sz = 20;
		}
		else if (opt_algo == ALGO_DECRED) {
			data_size = 192; adata_sz = 180/4;
		}
		else if (opt_algo == ALGO_SIA) {
			return sia_submit(curl, pool, work);
		}

		if (opt_algo != ALGO_HEAVY && opt_algo != ALGO_MJOLLNIR) {
			for (int i = 0; i < adata_sz; i++)
=======
			sleep(10);
			return false;
		}

		if (check_dups)
			hashlog_remember_submit(work, nonce);

	}
	else {

		/* build hex string */
		char *str = NULL;
		int data_size;

		switch (opt_algo)
		{
		case ALGO_NEO:
			data_size = opt_broken_neo_wallet ? 84 : 80;
			break;
		case ALGO_BITC:
			data_size = 168;
			break;
		default:
			data_size = 128;
			break;
		}

		if (opt_algo != ALGO_HEAVY && opt_algo != ALGO_MJOLLNIR) {
			for (int i = 0; i < (data_size >> 2); i++)
>>>>>>> 8c320ca... added xevan
				le32enc(work->data + i, work->data[i]);
		}
		str = bin2hex((uchar*)work->data, data_size);
		if (unlikely(!str)) {
			applog(LOG_ERR, "submit_upstream_work OOM");
			return false;
		}

		/* build JSON-RPC request */
		sprintf(s,
<<<<<<< HEAD
			"{\"method\": \"getwork\", \"params\": [\"%s\"], \"id\":10}\r\n",
			str);

		/* issue JSON-RPC request */
		val = json_rpc_call_pool(curl, pool, s, false, false, NULL);
=======
			"{\"method\": \"getwork\", \"params\": [\"%s\"], \"id\":4}\r\n",
			str);

		/* issue JSON-RPC request */
		val = json_rpc_call(curl, rpc_url, rpc_userpass, s, false, false, NULL);
>>>>>>> 8c320ca... added xevan
		if (unlikely(!val)) {
			applog(LOG_ERR, "submit_upstream_work json_rpc_call failed");
			return false;
		}

		res = json_object_get(val, "result");
		reason = json_object_get(val, "reject-reason");
<<<<<<< HEAD
		if (!share_result(json_is_true(res), work->pooln, work->sharediff[0],
				reason ? json_string_value(reason) : NULL))
		{
=======
		if (!share_result(json_is_true(res), reason ? json_string_value(reason) : NULL)) {
>>>>>>> 8c320ca... added xevan
			if (check_dups)
				hashlog_purge_job(work->job_id);
		}

		json_decref(val);

		free(str);
	}

	return true;
}

/* simplified method to only get some extra infos in solo mode */
static bool gbt_work_decode(const json_t *val, struct work *work)
{
	json_t *err = json_object_get(val, "error");
	if (err && !json_is_null(err)) {
		allow_gbt = false;
<<<<<<< HEAD
		applog(LOG_INFO, "GBT not supported, block height unavailable");
=======
		applog(LOG_INFO, "GBT not supported, bloc height unavailable");
>>>>>>> 8c320ca... added xevan
		return false;
	}

	if (!work->height) {
		// complete missing data from getwork
		json_t *key = json_object_get(val, "height");
		if (key && json_is_integer(key)) {
			work->height = (uint32_t) json_integer_value(key);
			if (!opt_quiet && work->height > g_work.height) {
<<<<<<< HEAD
				if (net_diff > 0.) {
					char netinfo[64] = { 0 };
					char srate[32] = { 0 };
					sprintf(netinfo, "diff %.2f", net_diff);
					if (net_hashrate) {
						format_hashrate((double) net_hashrate, srate);
						strcat(netinfo, ", net ");
						strcat(netinfo, srate);
					}
					applog(LOG_BLUE, "%s block %d, %s",
						algo_names[opt_algo], work->height, netinfo);
				} else {
					applog(LOG_BLUE, "%s %s block %d", short_url,
						algo_names[opt_algo], work->height);
				}
=======
				applog(LOG_BLUE, "%s %s block %d", short_url,
					algo_names[opt_algo], work->height);
>>>>>>> 8c320ca... added xevan
				g_work.height = work->height;
			}
		}
	}

	return true;
}

#define GBT_CAPABILITIES "[\"coinbasetxn\", \"coinbasevalue\", \"longpoll\", \"workid\"]"
static const char *gbt_req =
<<<<<<< HEAD
	"{\"method\": \"getblocktemplate\", \"params\": [{"
	//	"\"capabilities\": " GBT_CAPABILITIES ""
	"}], \"id\":9}\r\n";

static bool get_blocktemplate(CURL *curl, struct work *work)
{
	struct pool_infos *pool = &pools[work->pooln];
	if (!allow_gbt)
		return false;

	int curl_err = 0;
	json_t *val = json_rpc_call_pool(curl, pool, gbt_req, false, false, &curl_err);

	if (!val && curl_err == -1) {
		// when getblocktemplate is not supported, disable it
		allow_gbt = false;
		if (!opt_quiet) {
				applog(LOG_BLUE, "gbt not supported, block height notices disabled");
		}
		return false;
	}
=======
	"{\"method\": \"getblocktemplate\", \"params\": ["
	//	"{\"capabilities\": " GBT_CAPABILITIES "}"
	"], \"id\":0}\r\n";

static bool get_blocktemplate(CURL *curl, struct work *work)
{
	if (!allow_gbt)
		return false;

	json_t *val = json_rpc_call(curl, rpc_url, rpc_userpass, gbt_req,
			    want_longpoll, false, NULL);

	if (!val)
		return false;
>>>>>>> 8c320ca... added xevan

	bool rc = gbt_work_decode(json_object_get(val, "result"), work);

	json_decref(val);

	return rc;
}

<<<<<<< HEAD
// good alternative for wallet mining, difficulty and net hashrate
static const char *info_req =
	"{\"method\": \"getmininginfo\", \"params\": [], \"id\":8}\r\n";

static bool get_mininginfo(CURL *curl, struct work *work)
{
	struct pool_infos *pool = &pools[work->pooln];
	int curl_err = 0;

	if (have_stratum || have_longpoll || !allow_mininginfo)
		return false;

	json_t *val = json_rpc_call_pool(curl, pool, info_req, false, false, &curl_err);

	if (!val && curl_err == -1) {
		allow_mininginfo = false;
		if (opt_debug) {
				applog(LOG_DEBUG, "getmininginfo not supported");
		}
		return false;
	} else {
		json_t *res = json_object_get(val, "result");
		// "blocks": 491493 (= current work height - 1)
		// "difficulty": 0.99607860999999998
		// "networkhashps": 56475980
		// "netmhashps": 351.74414726
		if (res) {
			json_t *key = json_object_get(res, "difficulty");
			if (key) {
				if (json_is_object(key))
					key = json_object_get(key, "proof-of-work");
				if (json_is_real(key))
					net_diff = json_real_value(key);
			}
			key = json_object_get(res, "networkhashps");
			if (key && json_is_integer(key)) {
				net_hashrate = json_integer_value(key);
			}
			key = json_object_get(res, "netmhashps");
			if (key && json_is_real(key)) {
				net_hashrate = (uint64_t)(json_real_value(key) * 1e6);
			}
			key = json_object_get(res, "blocks");
			if (key && json_is_integer(key)) {
				net_blocks = json_integer_value(key);
			}
		}
	}
	json_decref(val);
	return true;
}

static const char *json_rpc_getwork =
	"{\"method\":\"getwork\",\"params\":[],\"id\":0}\r\n";

static bool get_upstream_work(CURL *curl, struct work *work)
{
	bool rc = false;
	struct timeval tv_start, tv_end, diff;
	struct pool_infos *pool = &pools[work->pooln];
	const char *rpc_req = json_rpc_getwork;
	json_t *val;

	gettimeofday(&tv_start, NULL);

	if (opt_algo == ALGO_SIA) {
		char *sia_header = sia_getheader(curl, pool);
		if (sia_header) {
			rc = sia_work_decode(sia_header, work);
			free(sia_header);
		}
		gettimeofday(&tv_end, NULL);
		if (have_stratum || unlikely(work->pooln != cur_pooln)) {
			return rc;
		}
		return rc;
	}

	if (opt_debug_threads)
		applog(LOG_DEBUG, "%s: want_longpoll=%d have_longpoll=%d",
			__func__, want_longpoll, have_longpoll);

	/* want_longpoll/have_longpoll required here to init/unlock the lp thread */
	val = json_rpc_call_pool(curl, pool, rpc_req, want_longpoll, have_longpoll, NULL);
	gettimeofday(&tv_end, NULL);

	if (have_stratum || unlikely(work->pooln != cur_pooln)) {
		if (val)
			json_decref(val);
		return false;
=======
static const char *rpc_req =
	"{\"method\": \"getwork\", \"params\": [], \"id\":0}\r\n";

static bool get_upstream_work(CURL *curl, struct work *work)
{
	json_t *val;
	bool rc;
	struct timeval tv_start, tv_end, diff;

	gettimeofday(&tv_start, NULL);
	val = json_rpc_call(curl, rpc_url, rpc_userpass, rpc_req,
			    want_longpoll, false, NULL);
	gettimeofday(&tv_end, NULL);

	if (have_stratum) {
		if (val)
			json_decref(val);
		return true;
>>>>>>> 8c320ca... added xevan
	}

	if (!val)
		return false;

	rc = work_decode(json_object_get(val, "result"), work);

	if (opt_protocol && rc) {
		timeval_subtract(&diff, &tv_end, &tv_start);
		/* show time because curl can be slower against versions/config */
		applog(LOG_DEBUG, "got new work in %.2f ms",
		       (1000.0 * diff.tv_sec) + (0.001 * diff.tv_usec));
	}

	json_decref(val);

<<<<<<< HEAD
	get_mininginfo(curl, work);
=======
>>>>>>> 8c320ca... added xevan
	get_blocktemplate(curl, work);

	return rc;
}

static void workio_cmd_free(struct workio_cmd *wc)
{
	if (!wc)
		return;

	switch (wc->cmd) {
	case WC_SUBMIT_WORK:
		aligned_free(wc->u.work);
		break;
	default: /* do nothing */
		break;
	}

	memset(wc, 0, sizeof(*wc));	/* poison */
	free(wc);
}

static void workio_abort()
{
	struct workio_cmd *wc;

	/* fill out work request message */
	wc = (struct workio_cmd *)calloc(1, sizeof(*wc));
	if (!wc)
		return;

	wc->cmd = WC_ABORT;

	/* send work request to workio thread */
	if (!tq_push(thr_info[work_thr_id].q, wc)) {
		workio_cmd_free(wc);
	}
}

static bool workio_get_work(struct workio_cmd *wc, CURL *curl)
{
	struct work *ret_work;
	int failures = 0;

<<<<<<< HEAD
	ret_work = (struct work*)aligned_calloc(sizeof(struct work));
	if (!ret_work)
		return false;

	/* assign pool number before rpc calls */
	ret_work->pooln = wc->pooln;
	// applog(LOG_DEBUG, "%s: pool %d", __func__, wc->pooln);

	/* obtain new work from bitcoin via JSON-RPC */
	while (!get_upstream_work(curl, ret_work)) {

		if (unlikely(ret_work->pooln != cur_pooln)) {
			applog(LOG_ERR, "get_work json_rpc_call failed");
			aligned_free(ret_work);
			tq_push(wc->thr->q, NULL);
			return true;
		}

		if (unlikely((opt_retries >= 0) && (++failures > opt_retries))) {
			applog(LOG_ERR, "get_work json_rpc_call failed");
=======
	ret_work = (struct work*)aligned_calloc(sizeof(*ret_work));
	if (!ret_work)
		return false;

	/* obtain new work from bitcoin via JSON-RPC */
	while (!get_upstream_work(curl, ret_work)) {
		if (unlikely((opt_retries >= 0) && (++failures > opt_retries))) {
			applog(LOG_ERR, "json_rpc_call failed, terminating workio thread");
>>>>>>> 8c320ca... added xevan
			aligned_free(ret_work);
			return false;
		}

		/* pause, then restart work-request loop */
<<<<<<< HEAD
		applog(LOG_ERR, "get_work failed, retry after %d seconds",
=======
		applog(LOG_ERR, "json_rpc_call failed, retry after %d seconds",
>>>>>>> 8c320ca... added xevan
			opt_fail_pause);
		sleep(opt_fail_pause);
	}

	/* send work to requesting thread */
	if (!tq_push(wc->thr->q, ret_work))
		aligned_free(ret_work);

	return true;
}

static bool workio_submit_work(struct workio_cmd *wc, CURL *curl)
{
	int failures = 0;
<<<<<<< HEAD
	uint32_t pooln = wc->pooln;
	// applog(LOG_DEBUG, "%s: pool %d", __func__, wc->pooln);

	/* submit solution to bitcoin via JSON-RPC */
	while (!submit_upstream_work(curl, wc->u.work)) {
		if (pooln != cur_pooln) {
			applog(LOG_DEBUG, "work from pool %u discarded", pooln);
			return true;
		}
=======

	/* submit solution to bitcoin via JSON-RPC */
	while (!submit_upstream_work(curl, wc->u.work)) {
>>>>>>> 8c320ca... added xevan
		if (unlikely((opt_retries >= 0) && (++failures > opt_retries))) {
			applog(LOG_ERR, "...terminating workio thread");
			return false;
		}
<<<<<<< HEAD
=======

>>>>>>> 8c320ca... added xevan
		/* pause, then restart work-request loop */
		if (!opt_benchmark)
			applog(LOG_ERR, "...retry after %d seconds", opt_fail_pause);

		sleep(opt_fail_pause);
	}

	return true;
}

static void *workio_thread(void *userdata)
{
	struct thr_info *mythr = (struct thr_info*)userdata;
	CURL *curl;
	bool ok = true;

	curl = curl_easy_init();
	if (unlikely(!curl)) {
		applog(LOG_ERR, "CURL initialization failed");
		return NULL;
	}

	while (ok && !abort_flag) {
		struct workio_cmd *wc;

		/* wait for workio_cmd sent to us, on our queue */
		wc = (struct workio_cmd *)tq_pop(mythr->q, NULL);
		if (!wc) {
			ok = false;
			break;
		}

		/* process workio_cmd */
		switch (wc->cmd) {
		case WC_GET_WORK:
			ok = workio_get_work(wc, curl);
			break;
		case WC_SUBMIT_WORK:
<<<<<<< HEAD
			if (opt_led_mode == LED_MODE_SHARES)
				gpu_led_on(device_map[wc->thr->id]);
			ok = workio_submit_work(wc, curl);
			if (opt_led_mode == LED_MODE_SHARES)
				gpu_led_off(device_map[wc->thr->id]);
=======
			ok = workio_submit_work(wc, curl);
>>>>>>> 8c320ca... added xevan
			break;
		case WC_ABORT:
		default:		/* should never happen */
			ok = false;
			break;
		}

<<<<<<< HEAD
		if (!ok && num_pools > 1 && opt_pool_failover) {
			if (opt_debug_threads)
				applog(LOG_DEBUG, "%s died, failover", __func__);
			ok = pool_switch_next(-1);
			tq_push(wc->thr->q, NULL); // get_work() will return false
		}

		workio_cmd_free(wc);
	}

	if (opt_debug_threads)
		applog(LOG_DEBUG, "%s() died", __func__);
	curl_easy_cleanup(curl);
	tq_freeze(mythr->q);
	return NULL;
}

bool get_work(struct thr_info *thr, struct work *work)
=======
		workio_cmd_free(wc);
	}

	tq_freeze(mythr->q);
	curl_easy_cleanup(curl);

	return NULL;
}

static bool get_work(struct thr_info *thr, struct work *work)
>>>>>>> 8c320ca... added xevan
{
	struct workio_cmd *wc;
	struct work *work_heap;

	if (opt_benchmark) {
		memset(work->data, 0x55, 76);
		//work->data[17] = swab32((uint32_t)time(NULL));
		memset(work->data + 19, 0x00, 52);
<<<<<<< HEAD
		if (opt_algo == ALGO_DECRED) {
			memset(&work->data[35], 0x00, 52);
		} else if (opt_algo == ALGO_LBRY) {
			work->data[28] = 0x80000000;
		} else {
			work->data[20] = 0x80000000;
			work->data[31] = 0x00000280;
		}
=======
		work->data[20] = 0x80000000;
		work->data[31] = 0x00000280;
>>>>>>> 8c320ca... added xevan
		memset(work->target, 0x00, sizeof(work->target));
		return true;
	}

	/* fill out work request message */
	wc = (struct workio_cmd *)calloc(1, sizeof(*wc));
	if (!wc)
		return false;

	wc->cmd = WC_GET_WORK;
	wc->thr = thr;
<<<<<<< HEAD
	wc->pooln = cur_pooln;
=======
>>>>>>> 8c320ca... added xevan

	/* send work request to workio thread */
	if (!tq_push(thr_info[work_thr_id].q, wc)) {
		workio_cmd_free(wc);
		return false;
	}

	/* wait for response, a unit of work */
	work_heap = (struct work *)tq_pop(thr->q, NULL);
	if (!work_heap)
		return false;

	/* copy returned work into storage provided by caller */
	memcpy(work, work_heap, sizeof(*work));
	aligned_free(work_heap);

	return true;
}

static bool submit_work(struct thr_info *thr, const struct work *work_in)
{
	struct workio_cmd *wc;
	/* fill out work request message */
	wc = (struct workio_cmd *)calloc(1, sizeof(*wc));
	if (!wc)
		return false;

	wc->u.work = (struct work *)aligned_calloc(sizeof(*work_in));
	if (!wc->u.work)
		goto err_out;

	wc->cmd = WC_SUBMIT_WORK;
	wc->thr = thr;
<<<<<<< HEAD
	memcpy(wc->u.work, work_in, sizeof(struct work));
	wc->pooln = work_in->pooln;
=======
	memcpy(wc->u.work, work_in, sizeof(*work_in));
>>>>>>> 8c320ca... added xevan

	/* send solution to workio thread */
	if (!tq_push(thr_info[work_thr_id].q, wc))
		goto err_out;

	return true;

err_out:
	workio_cmd_free(wc);
	return false;
}

<<<<<<< HEAD
static bool stratum_gen_work(struct stratum_ctx *sctx, struct work *work)
{
	uchar merkle_root[64] = { 0 };
	int i;

	if (sctx->rpc2)
		return rpc2_stratum_gen_work(sctx, work);

	if (!sctx->job.job_id) {
		// applog(LOG_WARNING, "stratum_gen_work: job not yet retrieved");
		return false;
	}

	pthread_mutex_lock(&stratum_work_lock);
=======
static void stratum_gen_work(struct stratum_ctx *sctx, struct work *work)
{
	uchar merkle_root[64];
	int i;

	if (!sctx->job.job_id) {
		// applog(LOG_WARNING, "stratum_gen_work: job not yet retrieved");
		return;
	}

	pthread_mutex_lock(&sctx->work_lock);
>>>>>>> 8c320ca... added xevan

	// store the job ntime as high part of jobid
	snprintf(work->job_id, sizeof(work->job_id), "%07x %s",
		be32dec(sctx->job.ntime) & 0xfffffff, sctx->job.job_id);
	work->xnonce2_len = sctx->xnonce2_size;
	memcpy(work->xnonce2, sctx->job.xnonce2, sctx->xnonce2_size);

<<<<<<< HEAD
	// also store the block number
	work->height = sctx->job.height;
	// and the pool of the current stratum
	work->pooln = sctx->pooln;

	/* Generate merkle root */
	switch (opt_algo) {
		case ALGO_DECRED:
		case ALGO_EQUIHASH:
		case ALGO_SIA:
			// getwork over stratum, no merkle to generate
			break;
=======
	// also store the bloc number
	work->height = sctx->job.height;

	/* Generate merkle root */
	switch (opt_algo) {
>>>>>>> 8c320ca... added xevan
		case ALGO_HEAVY:
		case ALGO_MJOLLNIR:
			heavycoin_hash(merkle_root, sctx->job.coinbase, (int)sctx->job.coinbase_size);
			break;
		case ALGO_FUGUE256:
		case ALGO_GROESTL:
		case ALGO_KECCAK:
		case ALGO_BLAKECOIN:
<<<<<<< HEAD
		case ALGO_WHIRLCOIN:
			SHA256((uchar*)sctx->job.coinbase, sctx->job.coinbase_size, (uchar*)merkle_root);
			break;
		case ALGO_WHIRLPOOL:
=======
			SHA256((uchar*)sctx->job.coinbase, sctx->job.coinbase_size, (uchar*)merkle_root);
			break;
		case ALGO_WHC:
>>>>>>> 8c320ca... added xevan
		default:
			sha256d(merkle_root, sctx->job.coinbase, (int)sctx->job.coinbase_size);
	}

	for (i = 0; i < sctx->job.merkle_count; i++) {
		memcpy(merkle_root + 32, sctx->job.merkle[i], 32);
		if (opt_algo == ALGO_HEAVY || opt_algo == ALGO_MJOLLNIR)
			heavycoin_hash(merkle_root, merkle_root, 64);
		else
			sha256d(merkle_root, merkle_root, 64);
	}
	
<<<<<<< HEAD
	/* Increment extranonce2 */
	for (i = 0; i < (int)sctx->xnonce2_size && !++sctx->job.xnonce2[i]; i++);
=======
//	/+Increment extranonce2 +/

	for (i = 0; i < (int)sctx->xnonce2_size && !++sctx->job.xnonce2[i]; i++);
	{
		sctx->job.xnonce2[i]++;		
	}


>>>>>>> 8c320ca... added xevan

	/* Assemble block header */
	memset(work->data, 0, sizeof(work->data));
	work->data[0] = le32dec(sctx->job.version);
	for (i = 0; i < 8; i++)
		work->data[1 + i] = le32dec((uint32_t *)sctx->job.prevhash + i);
<<<<<<< HEAD

	if (opt_algo == ALGO_DECRED) {
		uint16_t vote;
		for (i = 0; i < 8; i++) // reversed prevhash
			work->data[1 + i] = swab32(work->data[1 + i]);
		// decred header (coinb1) [merkle...nonce]
		memcpy(&work->data[9], sctx->job.coinbase, 108);
		// last vote bit should never be changed
		memcpy(&vote, &work->data[25], 2);
		vote = (opt_vote << 1) | (vote & 1);
		memcpy(&work->data[25], &vote, 2);
		// extradata
		if (sctx->xnonce1_size > sizeof(work->data)-(32*4)) {
			// should never happen...
			applog(LOG_ERR, "extranonce size overflow!");
			sctx->xnonce1_size = sizeof(work->data)-(32*4);
		}
		memcpy(&work->data[36], sctx->xnonce1, sctx->xnonce1_size);
		work->data[37] = (rand()*4) << 8; // random work data
		// block header suffix from coinb2 (stake version)
		memcpy(&work->data[44], &sctx->job.coinbase[sctx->job.coinbase_size-4], 4);
		sctx->job.height = work->data[32];
		//applog_hex(work->data, 180);
	} else if (opt_algo == ALGO_EQUIHASH) {
		memcpy(&work->data[9], sctx->job.coinbase, 32+32); // merkle [9..16] + reserved
		work->data[25] = le32dec(sctx->job.ntime);
		work->data[26] = le32dec(sctx->job.nbits);
		memcpy(&work->data[27], sctx->xnonce1, sctx->xnonce1_size & 0x1F); // pool extranonce
		work->data[35] = 0x80;
		//applog_hex(work->data, 140);
	} else if (opt_algo == ALGO_LBRY) {
		for (i = 0; i < 8; i++)
			work->data[9 + i] = be32dec((uint32_t *)merkle_root + i);
		for (i = 0; i < 8; i++)
			work->data[17 + i] = ((uint32_t*)sctx->job.claim)[i];
		work->data[25] = le32dec(sctx->job.ntime);
		work->data[26] = le32dec(sctx->job.nbits);
		work->data[28] = 0x80000000;
	} else if (opt_algo == ALGO_SIA) {
		uint32_t extra = 0;
		memcpy(&extra, &sctx->job.coinbase[32], 2);
		for (i = 0; i < 8; i++) // reversed hash
			work->data[i] = ((uint32_t*)sctx->job.prevhash)[7-i];
		work->data[8] = 0; // nonce
		work->data[9] = swab32(extra) | ((rand() << 8) & 0xffff);
		work->data[10] = be32dec(sctx->job.ntime);
		work->data[11] = be32dec(sctx->job.nbits);
		memcpy(&work->data[12], sctx->job.coinbase, 32); // merkle_root
		work->data[20] = 0x80000000;
		if (opt_debug) applog_hex(work->data, 80);
	} else {
		for (i = 0; i < 8; i++)
			work->data[9 + i] = be32dec((uint32_t *)merkle_root + i);
		work->data[17] = le32dec(sctx->job.ntime);
		work->data[18] = le32dec(sctx->job.nbits);
		work->data[20] = 0x80000000;
		work->data[31] = (opt_algo == ALGO_MJOLLNIR) ? 0x000002A0 : 0x00000280;
	}

	if (opt_showdiff || opt_max_diff > 0.)
		calc_network_diff(work);

	switch (opt_algo) {
	case ALGO_MJOLLNIR:
	case ALGO_HEAVY:
	case ALGO_ZR5:
		for (i = 0; i < 20; i++)
			work->data[i] = swab32(work->data[i]);
		break;
	}

=======
	for (i = 0; i < 8; i++)
		work->data[9 + i] = be32dec((uint32_t *)merkle_root + i);
	work->data[17] = le32dec(sctx->job.ntime);
	work->data[18] = le32dec(sctx->job.nbits);
	if (opt_algo == ALGO_MJOLLNIR || opt_algo == ALGO_HEAVY)
	{
		for (i = 0; i < 20; i++)
			work->data[i] = be32dec((uint32_t *)&work->data[i]);
	}

	work->data[20] = 0x80000000;
	work->data[31] = (opt_algo == ALGO_MJOLLNIR) ? 0x000002A0 : 0x00000280;

>>>>>>> 8c320ca... added xevan
	// HeavyCoin (vote / reward)
	if (opt_algo == ALGO_HEAVY) {
		work->maxvote = 2048;
		uint16_t *ext = (uint16_t*)(&work->data[20]);
		ext[0] = opt_vote;
		ext[1] = be16dec(sctx->job.nreward);
		// applog(LOG_DEBUG, "DEBUG: vote=%hx reward=%hx", ext[0], ext[1]);
	}

<<<<<<< HEAD
	pthread_mutex_unlock(&stratum_work_lock);

	if (opt_debug && opt_algo != ALGO_DECRED && opt_algo != ALGO_EQUIHASH && opt_algo != ALGO_SIA) {
		uint32_t utm = work->data[17];
		if (opt_algo != ALGO_ZR5) utm = swab32(utm);
		char *tm = atime2str(utm - sctx->srvtime_diff);
=======
	pthread_mutex_unlock(&sctx->work_lock);

	if (opt_debug) {
		char *tm = atime2str(swab32(work->data[17]) - sctx->srvtime_diff);
>>>>>>> 8c320ca... added xevan
		char *xnonce2str = bin2hex(work->xnonce2, sctx->xnonce2_size);
		applog(LOG_DEBUG, "DEBUG: job_id=%s xnonce2=%s time=%s",
		       work->job_id, xnonce2str, tm);
		free(tm);
		free(xnonce2str);
	}

<<<<<<< HEAD
	if (opt_difficulty == 0.)
		opt_difficulty = 1.;

	switch (opt_algo) {
		case ALGO_HMQ1725:
		case ALGO_JACKPOT:
		case ALGO_JHA:
		case ALGO_NEOSCRYPT:
		case ALGO_SCRYPT:
		case ALGO_SCRYPT_JANE:
			work_set_target(work, sctx->job.diff / (65536.0 * opt_difficulty));
			break;
		case ALGO_DMD_GR:
		case ALGO_FRESH:
		case ALGO_FUGUE256:
		case ALGO_GROESTL:
		case ALGO_LBRY:
		case ALGO_LYRA2v2:
		case ALGO_LYRA2Z:
		case ALGO_TIMETRAVEL:
		case ALGO_BITCORE:
			work_set_target(work, sctx->job.diff / (256.0 * opt_difficulty));
			break;
		case ALGO_KECCAK:
		case ALGO_LYRA2:
			work_set_target(work, sctx->job.diff / (128.0 * opt_difficulty));
			break;
		case ALGO_EQUIHASH:
			equi_work_set_target(work, sctx->job.diff / opt_difficulty);
			break;
		default:
			work_set_target(work, sctx->job.diff / opt_difficulty);
	}

	if (stratum_diff != sctx->job.diff) {
		char sdiff[32] = { 0 };
		// store for api stats
		stratum_diff = sctx->job.diff;
		if (opt_showdiff && work->targetdiff != stratum_diff)
			snprintf(sdiff, 32, " (%.5f)", work->targetdiff);
		applog(LOG_WARNING, "Stratum difficulty set to %g%s", stratum_diff, sdiff);
	}

	return true;
}

void restart_threads(void)
{
	if (opt_debug && !opt_quiet)
		applog(LOG_DEBUG,"%s", __FUNCTION__);

=======
	switch (opt_algo) {
		case ALGO_JACKPOT:
		case ALGO_SCRYPT:
		case ALGO_SCRYPT_JANE:
		case ALGO_NEO:
			diff_to_target(work->target, sctx->job.diff / (65536.0 * opt_difficulty));
			break;
		case ALGO_DMD_GR:
		case ALGO_MYR_GR:
		case ALGO_FRESH:
		case ALGO_FUGUE256:
		case ALGO_GROESTL:
		case ALGO_KECCAK:
		case ALGO_LYRA2v2:
			diff_to_target(work->target, sctx->job.diff / (256.0 * opt_difficulty));
			break;
		case ALGO_LYRA2:
			diff_to_target(work->target, sctx->job.diff / (128.0 * opt_difficulty));
			break;
		default:
			diff_to_target(work->target, sctx->job.diff / opt_difficulty);
	}
}

static void restart_threads(void)
{
	if (opt_debug && !opt_quiet)
		applog(LOG_DEBUG,"%s", __FUNCTION__);
>>>>>>> 8c320ca... added xevan
	for (int i = 0; i < opt_n_threads && work_restart; i++)
		work_restart[i].restart = 1;
}

<<<<<<< HEAD
static bool wanna_mine(int thr_id)
{
	bool state = true;
	bool allow_pool_rotate = (thr_id == 0 && num_pools > 1 && !pool_is_switching);

	if (opt_max_temp > 0.0) {
#ifdef USE_WRAPNVML
		struct cgpu_info * cgpu = &thr_info[thr_id].gpu;
		float temp = gpu_temp(cgpu);
		if (temp > opt_max_temp) {
			if (!conditional_state[thr_id] && !opt_quiet)
				gpulog(LOG_INFO, thr_id, "temperature too high (%.0f°c), waiting...", temp);
			state = false;
		} else if (opt_max_temp > 0. && opt_resume_temp > 0. && conditional_state[thr_id] && temp > opt_resume_temp) {
			if (!thr_id && opt_debug)
				applog(LOG_DEBUG, "temperature did not reach resume value %.1f...", opt_resume_temp);
			state = false;
		}
#endif
	}
	// Network Difficulty
	if (opt_max_diff > 0.0 && net_diff > opt_max_diff) {
		int next = pool_get_first_valid(cur_pooln+1);
		if (num_pools > 1 && pools[next].max_diff != pools[cur_pooln].max_diff && opt_resume_diff <= 0.)
			conditional_pool_rotate = allow_pool_rotate;
		if (!thr_id && !conditional_state[thr_id] && !opt_quiet)
			applog(LOG_INFO, "network diff too high, waiting...");
		state = false;
	} else if (opt_max_diff > 0. && opt_resume_diff > 0. && conditional_state[thr_id] && net_diff > opt_resume_diff) {
		if (!thr_id && opt_debug)
			applog(LOG_DEBUG, "network diff did not reach resume value %.3f...", opt_resume_diff);
		state = false;
	}
	// Network hashrate
	if (opt_max_rate > 0.0 && net_hashrate > opt_max_rate) {
		int next = pool_get_first_valid(cur_pooln+1);
		if (pools[next].max_rate != pools[cur_pooln].max_rate && opt_resume_rate <= 0.)
			conditional_pool_rotate = allow_pool_rotate;
		if (!thr_id && !conditional_state[thr_id] && !opt_quiet) {
			char rate[32];
			format_hashrate(opt_max_rate, rate);
			applog(LOG_INFO, "network hashrate too high, waiting %s...", rate);
		}
		state = false;
	} else if (opt_max_rate > 0. && opt_resume_rate > 0. && conditional_state[thr_id] && net_hashrate > opt_resume_rate) {
		if (!thr_id && opt_debug)
			applog(LOG_DEBUG, "network rate did not reach resume value %.3f...", opt_resume_rate);
		state = false;
	}
	conditional_state[thr_id] = (uint8_t) !state; // only one wait message in logs
	return state;
}

static void *miner_thread(void *userdata)
{
	struct thr_info *mythr = (struct thr_info *)userdata;
	int switchn = pool_switch_count;
	int thr_id = mythr->id;
	int dev_id = device_map[thr_id % MAX_GPUS];
	struct cgpu_info * cgpu = &thr_info[thr_id].gpu;
	struct work work;
	uint64_t loopcnt = 0;
	uint32_t max_nonce;
	uint32_t end_nonce = UINT32_MAX / opt_n_threads * (thr_id + 1) - (thr_id + 1);
	time_t tm_rate_log = 0;
=======
static void *miner_thread(void *userdata)
{
	struct thr_info *mythr = (struct thr_info *)userdata;
	int thr_id = mythr->id;
	struct work work;
	uint64_t loopcnt = 0;
	uint32_t max_nonce;
	uint32_t end_nonce = 0xffffffffU / opt_n_threads * (thr_id + 1) - (thr_id + 1);
	time_t firstwork_time = 0;
>>>>>>> 8c320ca... added xevan
	bool work_done = false;
	bool extrajob = false;
	char s[16];
	int rc = 0;

	memset(&work, 0, sizeof(work)); // prevent work from being used uninitialized

<<<<<<< HEAD
	if (opt_priority > 0) {
		int prio = 2; // default to normal
#ifndef WIN32
		prio = 0;
		// note: different behavior on linux (-19 to 19)
		switch (opt_priority) {
			case 0:
				prio = 15;
				break;
=======
	/* Set worker threads to nice 19 and then preferentially to SCHED_IDLE
	 * and if that fails, then SCHED_BATCH. No need for this to be an
	 * error if it fails */
	if (!opt_benchmark && opt_priority == 0) 
	{
		setpriority(PRIO_PROCESS, 0, 18);
		drop_policy();
	} else {
		int prio = 0;
#ifndef WIN32
		prio = -15;
		// note: different behavior on linux (-19 to 19)
		switch (opt_priority) {
>>>>>>> 8c320ca... added xevan
			case 1:
				prio = 5;
				break;
			case 2:
<<<<<<< HEAD
				prio = 0; // normal process
				break;
			case 3:
				prio = -1; // above
=======
				prio = 0;
				break;
			case 3:
				prio = -5;
>>>>>>> 8c320ca... added xevan
				break;
			case 4:
				prio = -10;
				break;
			case 5:
				prio = -15;
		}
<<<<<<< HEAD
		if (opt_debug)
			applog(LOG_DEBUG, "Thread %d priority %d (nice %d)",
				thr_id,	opt_priority, prio);
#endif
		setpriority(PRIO_PROCESS, 0, prio);
		drop_policy();
	}

	/* Cpu thread affinity */
	if (num_cpus > 1) {
		if (opt_affinity == -1L && opt_n_threads > 1) {
			if (opt_debug)
				applog(LOG_DEBUG, "Binding thread %d to cpu %d (mask %x)", thr_id,
						thr_id % num_cpus, (1UL << (thr_id % num_cpus)));
			affine_to_cpu_mask(thr_id, 1 << (thr_id % num_cpus));
		} else if (opt_affinity != -1L) {
			if (opt_debug)
				applog(LOG_DEBUG, "Binding thread %d to cpu mask %lx", thr_id,
						(long) opt_affinity);
			affine_to_cpu_mask(thr_id, (unsigned long) opt_affinity);
		}
	}

	gpu_led_off(dev_id);

	while (!abort_flag) {
		struct timeval tv_start, tv_end, diff;
		unsigned long hashes_done;
		uint32_t start_nonce;
		uint32_t scan_time = have_longpoll ? LP_SCANTIME : opt_scantime;
		uint64_t max64, minmax = 0x100000;
		int nodata_check_oft = 0;
		bool regen = false;

		// &work.data[19]
		int wcmplen = (opt_algo == ALGO_DECRED) ? 140 : 76;
		int wcmpoft = 0;

		if (opt_algo == ALGO_LBRY) wcmplen = 108;
		else if (opt_algo == ALGO_SIA) {
			wcmpoft = (32+16)/4;
			wcmplen = 32;
		}

		uint32_t *nonceptr = (uint32_t*) (((char*)work.data) + wcmplen);

		if (opt_algo == ALGO_WILDKECCAK) {
			nonceptr = (uint32_t*) (((char*)work.data) + 1);
			wcmpoft = 2;
			wcmplen = 32;
		} else if (opt_algo == ALGO_CRYPTOLIGHT || opt_algo == ALGO_CRYPTONIGHT) {
			nonceptr = (uint32_t*) (((char*)work.data) + 39);
			wcmplen = 39;
		} else if (opt_algo == ALGO_EQUIHASH) {
			nonceptr = &work.data[EQNONCE_OFFSET]; // 27 is pool extranonce (256bits nonce space)
			wcmplen = 4+32+32;
		}

		if (have_stratum) {
			uint32_t sleeptime = 0;

			if (opt_algo == ALGO_DECRED || opt_algo == ALGO_WILDKECCAK /* getjob */)
				work_done = true; // force "regen" hash
			while (!work_done && time(NULL) >= (g_work_time + opt_scantime)) {
=======
		applog(LOG_DEBUG, "Thread %d priority %d (set to %d)", thr_id,
			opt_priority, prio);
#endif
		int ret = setpriority(PRIO_PROCESS, 0, prio);
		if (opt_priority == 0) {
			drop_policy();
		}
	}

	/* Cpu thread affinity */
	if (num_cpus > 1) 
	{
		if (opt_affinity == -1) 
		{
			if (!opt_quiet)
				applog(LOG_DEBUG, "Binding thread %d to cpu %d (mask %x)", thr_id,
				thr_id%num_cpus, (1 << (thr_id)));
			affine_to_cpu_mask(thr_id, 1 << (thr_id));
		} else if (opt_affinity != -1) 
		{
			if (!opt_quiet)
				applog(LOG_DEBUG, "Binding thread %d to gpu mask %x", thr_id,
						opt_affinity);
			affine_to_cpu_mask(thr_id, opt_affinity);
		}
	}

	while (!abort_flag)
	{
		if (opt_benchmark)
		{
//			work.data[19] = work.data[19] & 0xfffffffU;	//reset Hashcounters
//			work.data[21] = work.data[21] & 0xfffffffU;
		}

		struct timeval tv_start, tv_end, diff;
		unsigned long hashes_done=0;
		uint32_t start_nonce;
		uint32_t scan_time = have_longpoll ? LP_SCANTIME : opt_scantime;
		uint64_t max64, minmax = 0x100000;

		// &work.data[19]
		int wcmplen = (opt_algo == ALGO_BITC) ? 140 : 76;
		uint32_t *nonceptr = (uint32_t*) (((char*)work.data) + wcmplen);

		if (have_stratum) 
		{
			uint32_t sleeptime = 0;
			while (!work_done && time(NULL) >= (g_work_time + 60)) 
			{
>>>>>>> 8c320ca... added xevan
				usleep(100*1000);
				if (sleeptime > 4) {
					extrajob = true;
					break;
				}
				sleeptime++;
			}
			if (sleeptime && opt_debug && !opt_quiet)
<<<<<<< HEAD
				applog(LOG_DEBUG, "sleeptime: %u ms", sleeptime*100);
			//nonceptr = (uint32_t*) (((char*)work.data) + wcmplen);
			pthread_mutex_lock(&g_work_lock);
			extrajob |= work_done;

			regen = (nonceptr[0] >= end_nonce);
			if (opt_algo == ALGO_SIA) {
				regen = ((nonceptr[1] & 0xFF00) >= 0xF000);
			}
			regen = regen || extrajob;

			if (regen) {
				work_done = false;
				extrajob = false;
				if (stratum_gen_work(&stratum, &g_work))
					g_work_time = time(NULL);
				if (opt_algo == ALGO_CRYPTONIGHT || opt_algo == ALGO_CRYPTOLIGHT)
					nonceptr[0] += 0x100000;
			}
		} else {
			uint32_t secs = 0;
			pthread_mutex_lock(&g_work_lock);
			secs = (uint32_t) (time(NULL) - g_work_time);
			if (secs >= scan_time || nonceptr[0] >= (end_nonce - 0x100)) {
				if (opt_debug && g_work_time && !opt_quiet)
					applog(LOG_DEBUG, "work time %u/%us nonce %x/%x", secs, scan_time, nonceptr[0], end_nonce);
				/* obtain new work from internal workio thread */
				if (unlikely(!get_work(mythr, &g_work))) {
					pthread_mutex_unlock(&g_work_lock);
					if (switchn != pool_switch_count) {
						switchn = pool_switch_count;
						continue;
					} else {
						applog(LOG_ERR, "work retrieval failed, exiting mining thread %d", mythr->id);
						goto out;
					}
=======
			{
				applog(LOG_DEBUG, "sleeptime: %u ms", sleeptime * 100);
			}
				nonceptr = (uint32_t*) (((char*)work.data) + wcmplen);
			pthread_mutex_lock(&g_work_lock);
			extrajob |= work_done;
			if (nonceptr[0] >= end_nonce || extrajob) {
				work_done = false;
				extrajob = false;
				stratum_gen_work(&stratum, &g_work);
			}
		} else 
		{
			pthread_mutex_lock(&g_work_lock);
			if ((time(NULL) - g_work_time) >= scan_time || nonceptr[0] >= (end_nonce - 0x100)) {
				if (opt_debug && g_work_time && !opt_quiet)
					applog(LOG_DEBUG, "work time %u/%us nonce %x/%x", time(NULL) - g_work_time,
						scan_time, nonceptr[0], end_nonce);
				/* obtain new work from internal workio thread */
				if (unlikely(!get_work(mythr, &g_work))) {
					pthread_mutex_unlock(&g_work_lock);
					applog(LOG_ERR, "work retrieval failed, exiting mining thread %d", mythr->id);
					goto out;
>>>>>>> 8c320ca... added xevan
				}
				g_work_time = time(NULL);
			}
		}

<<<<<<< HEAD
		// reset shares id counter on new job
		if (strcmp(work.job_id, g_work.job_id))
			stratum.job.shares_count = 0;

		if (!opt_benchmark && (g_work.height != work.height || memcmp(work.target, g_work.target, sizeof(work.target))))
		{
			if (opt_debug) {
				uint64_t target64 = g_work.target[7] * 0x100000000ULL + g_work.target[6];
				applog(LOG_DEBUG, "job %s target change: %llx (%.1f)", g_work.job_id, target64, g_work.targetdiff);
			}
			memcpy(work.target, g_work.target, sizeof(work.target));
			work.targetdiff = g_work.targetdiff;
			work.height = g_work.height;
			//nonceptr[0] = (UINT32_MAX / opt_n_threads) * thr_id; // 0 if single thr
		}

		if (opt_algo == ALGO_ZR5) {
			// ignore pok/version header
			wcmpoft = 1;
			wcmplen -= 4;
		}

		if (opt_algo == ALGO_CRYPTONIGHT || opt_algo == ALGO_CRYPTOLIGHT) {
			uint32_t oldpos = nonceptr[0];
			bool nicehash = strstr(pools[cur_pooln].url, "nicehash") != NULL;
			if (memcmp(&work.data[wcmpoft], &g_work.data[wcmpoft], wcmplen)) {
				memcpy(&work, &g_work, sizeof(struct work));
				if (!nicehash) nonceptr[0] = (rand()*4) << 24;
				nonceptr[0] &=  0xFF000000u; // nicehash prefix hack
				nonceptr[0] |= (0x00FFFFFFu / opt_n_threads) * thr_id;
			}
			// also check the end, nonce in the middle
			else if (memcmp(&work.data[44/4], &g_work.data[0], 76-44)) {
				memcpy(&work, &g_work, sizeof(struct work));
			}
			if (oldpos & 0xFFFF) {
				if (!nicehash) nonceptr[0] = oldpos + 0x1000000u;
				else {
					uint32_t pfx = nonceptr[0] & 0xFF000000u;
					nonceptr[0] = pfx | ((oldpos + 0x8000u) & 0xFFFFFFu);
				}
			}
		}

		else if (memcmp(&work.data[wcmpoft], &g_work.data[wcmpoft], wcmplen)) {
=======
		if (!opt_benchmark && (g_work.height != work.height || memcmp(work.target, g_work.target, sizeof(work.target))))
		{
			calc_diff(&g_work, 0);
			if (!have_stratum)
				global_diff = g_work.difficulty;
			if (opt_debug) {
				uint64_t target64 = g_work.target[7] * 0x100000000ULL + g_work.target[6];
				applog(LOG_DEBUG, "job %s target change: %llx (%.1f)", g_work.job_id, target64, g_work.difficulty);
			}
			memcpy(work.target, g_work.target, sizeof(work.target));
			work.difficulty = g_work.difficulty;
			work.height = g_work.height;
			/* on new target, ignoring nonce, clear sent data (hashlog) */
			if (memcmp(work.target, g_work.target, sizeof(work.target))) {
				if (check_dups)
					hashlog_purge_job(work.job_id);
			}
		}
		if (memcmp(work.data, g_work.data, wcmplen)) {
>>>>>>> 8c320ca... added xevan
			#if 0
			if (opt_debug) {
				for (int n=0; n <= (wcmplen-8); n+=8) {
					if (memcmp(work.data + n, g_work.data + n, 8)) {
						applog(LOG_DEBUG, "job %s work updated at offset %d:", g_work.job_id, n);
						applog_hash((uchar*) &work.data[n]);
						applog_compare_hash((uchar*) &g_work.data[n], (uchar*) &work.data[n]);
					}
				}
			}
			#endif
			memcpy(&work, &g_work, sizeof(struct work));
			nonceptr[0] = (UINT32_MAX / opt_n_threads) * thr_id; // 0 if single thr
		} else
			nonceptr[0]++; //??

<<<<<<< HEAD
		if (opt_algo == ALGO_DECRED) {
			// suprnova job_id check without data/target/height change...
			if (check_stratum_jobs && strcmp(work.job_id, g_work.job_id)) {
				pthread_mutex_unlock(&g_work_lock);
				continue;
			}

			// use the full range per loop
			nonceptr[0] = 0;
			end_nonce = UINT32_MAX;
			// and make an unique work (extradata)
			nonceptr[1] += 1;
			nonceptr[2] |= thr_id;

		} else if (opt_algo == ALGO_EQUIHASH) {
			nonceptr[1]++;
			nonceptr[1] |= thr_id << 24;
			//applog_hex(&work.data[27], 32);
		} else if (opt_algo == ALGO_WILDKECCAK) {
			//nonceptr[1] += 1;
		} else if (opt_algo == ALGO_SIA) {
			// suprnova job_id check without data/target/height change...
			if (have_stratum && strcmp(work.job_id, g_work.job_id)) {
				pthread_mutex_unlock(&g_work_lock);
				work_done = true;
				continue;
			}
			nonceptr[1] += opt_n_threads;
			nonceptr[1] |= thr_id;
			// range max
			nonceptr[0] = 0;
			end_nonce = UINT32_MAX;
		} else if (opt_benchmark) {
			// randomize work
			nonceptr[-1] += 1;
		}

		pthread_mutex_unlock(&g_work_lock);

		// --benchmark [-a all]
		if (opt_benchmark && bench_algo >= 0) {
			//gpulog(LOG_DEBUG, thr_id, "loop %d", loopcnt);
			if (loopcnt >= 3) {
				if (!bench_algo_switch_next(thr_id) && thr_id == 0)
				{
					bench_display_results();
					proper_exit(0);
					break;
				}
				loopcnt = 0;
			}
		}
		loopcnt++;

		// prevent gpu scans before a job is received
		if (opt_algo == ALGO_SIA) nodata_check_oft = 7; // no stratum version
		else if (opt_algo == ALGO_DECRED) nodata_check_oft = 4; // testnet ver is 0
		else nodata_check_oft = 0;
		if (have_stratum && work.data[nodata_check_oft] == 0 && !opt_benchmark) {
			sleep(1);
			if (!thr_id) pools[cur_pooln].wait_time += 1;
			gpulog(LOG_DEBUG, thr_id, "no data");
			continue;
		}
		if (opt_algo == ALGO_WILDKECCAK && !scratchpad_size) {
			sleep(1);
			if (!thr_id) pools[cur_pooln].wait_time += 1;
			continue;
		}

		/* conditional mining */
		if (!wanna_mine(thr_id))
		{
			// reset default mem offset before idle..
#if defined(WIN32) && defined(USE_WRAPNVML)
			if (need_memclockrst) nvapi_toggle_clocks(thr_id, false);
#else
			if (need_nvsettings) nvs_reset_clocks(dev_id);
#endif
			// free gpu resources
			algo_free_all(thr_id);
			// clear any free error (algo switch)
			cuda_clear_lasterror();

			// conditional pool switch
			if (num_pools > 1 && conditional_pool_rotate) {
				if (!pool_is_switching)
					pool_switch_next(thr_id);
				else if (time(NULL) - firstwork_time > 35) {
					if (!opt_quiet)
						applog(LOG_WARNING, "Pool switching timed out...");
					if (!thr_id) pools[cur_pooln].wait_time += 1;
					pool_is_switching = false;
				}
				sleep(1);
				continue;
			}

			pool_on_hold = true;
			global_hashrate = 0;
			sleep(5);
			if (!thr_id) pools[cur_pooln].wait_time += 5;
			continue;
		} else {
			// reapply mem offset if needed
#if defined(WIN32) && defined(USE_WRAPNVML)
			if (need_memclockrst) nvapi_toggle_clocks(thr_id, true);
#else
			if (need_nvsettings) nvs_set_clocks(dev_id);
#endif
		}

		pool_on_hold = false;

		work_restart[thr_id].restart = 0;

=======
		work_restart[thr_id].restart = 0;
		pthread_mutex_unlock(&g_work_lock);

		/* prevent gpu scans before a job is received */
		if ((have_stratum && work.data[0] == 0 || network_fail_flag) && !opt_benchmark)
		{
			sleep(1);
			continue;	
		}

>>>>>>> 8c320ca... added xevan
		/* adjust max_nonce to meet target scan time */
		if (have_stratum)
			max64 = LP_SCANTIME;
		else
<<<<<<< HEAD
			max64 = max(1, (int64_t) scan_time + g_work_time - time(NULL));

		/* time limit */
		if (opt_time_limit > 0 && firstwork_time) {
			int passed = (int)(time(NULL) - firstwork_time);
			int remain = (int)(opt_time_limit - passed);
			if (remain < 0)  {
				if (thr_id != 0) {
					sleep(1); continue;
				}
				if (num_pools > 1 && pools[cur_pooln].time_limit > 0) {
					if (!pool_is_switching) {
						if (!opt_quiet)
							applog(LOG_INFO, "Pool mining timeout of %ds reached, rotate...", opt_time_limit);
						pool_switch_next(thr_id);
					} else if (passed > 35) {
						// ensure we dont stay locked if pool_is_switching is not reset...
						applog(LOG_WARNING, "Pool switch to %d timed out...", cur_pooln);
						if (!thr_id) pools[cur_pooln].wait_time += 1;
						pool_is_switching = false;
					}
					sleep(1);
					continue;
				}
				app_exit_code = EXIT_CODE_TIME_LIMIT;
				abort_flag = true;
				if (opt_benchmark) {
					char rate[32];
					format_hashrate((double)global_hashrate, rate);
					applog(LOG_NOTICE, "Benchmark: %s", rate);
=======
			max64 = max(1, scan_time + g_work_time - time(NULL));
		

		/* time limit */
		if (opt_time_limit && firstwork_time) {
			int passed = (int)(time(NULL) - firstwork_time);
			int remain = (int)(opt_time_limit - passed);
			if (remain < 0)  {
				abort_flag = true;
				if (opt_benchmark) {
					char rate[32];
					format_hashrate(global_hashrate, rate);
	                                applog(LOG_NOTICE, "Benchmark: %s", rate);
>>>>>>> 8c320ca... added xevan
					usleep(200*1000);
					fprintf(stderr, "%llu\n", (long long unsigned int) global_hashrate);
				} else {
					applog(LOG_NOTICE, "Mining timeout of %ds reached, exiting...", opt_time_limit);
				}
				workio_abort();
				break;
			}
			if (remain < max64) max64 = remain;
		}

<<<<<<< HEAD
		/* shares limit */
		if (opt_shares_limit > 0 && firstwork_time) {
			int64_t shares = (pools[cur_pooln].accepted_count + pools[cur_pooln].rejected_count);
			if (shares >= opt_shares_limit) {
				int passed = (int)(time(NULL) - firstwork_time);
				if (thr_id != 0) {
					sleep(1); continue;
				}
				if (num_pools > 1 && pools[cur_pooln].shares_limit > 0) {
					if (!pool_is_switching) {
						if (!opt_quiet)
							applog(LOG_INFO, "Pool shares limit of %d reached, rotate...", opt_shares_limit);
						pool_switch_next(thr_id);
					} else if (passed > 35) {
						// ensure we dont stay locked if pool_is_switching is not reset...
						applog(LOG_WARNING, "Pool switch to %d timed out...", cur_pooln);
						if (!thr_id) pools[cur_pooln].wait_time += 1;
						pool_is_switching = false;
					}
					sleep(1);
					continue;
				}
				abort_flag = true;
				app_exit_code = EXIT_CODE_OK;
				applog(LOG_NOTICE, "Mining limit of %d shares reached, exiting...", opt_shares_limit);
				workio_abort();
				break;
			}
		}
=======
>>>>>>> 8c320ca... added xevan

		max64 *= (uint32_t)thr_hashrates[thr_id];

		/* on start, max64 should not be 0,
		 *    before hashrate is computed */
<<<<<<< HEAD
		if (max64 < minmax) {
			switch (opt_algo) {
			case ALGO_BLAKECOIN:
			case ALGO_BLAKE2S:
			case ALGO_VANILLA:
				minmax = 0x80000000U;
				break;
			case ALGO_BLAKE:
			case ALGO_BMW:
			case ALGO_DECRED:
			case ALGO_SHA256D:
			case ALGO_SHA256T:
			//case ALGO_WHIRLPOOLX:
				minmax = 0x40000000U;
				break;
			case ALGO_KECCAK:
			case ALGO_LBRY:
			case ALGO_LUFFA:
			case ALGO_SIA:
			case ALGO_SKEIN:
			case ALGO_SKEIN2:
			case ALGO_TRIBUS:
				minmax = 0x1000000;
				break;
			case ALGO_C11:
			case ALGO_DEEP:
			case ALGO_HEAVY:
			case ALGO_JACKPOT:
			case ALGO_JHA:
			case ALGO_LYRA2v2:
			case ALGO_S3:
			case ALGO_SKUNK:
			case ALGO_TIMETRAVEL:
			case ALGO_BITCORE:
			case ALGO_X11EVO:
			case ALGO_X11:
			case ALGO_X13:
			case ALGO_WHIRLCOIN:
			case ALGO_WHIRLPOOL:
				minmax = 0x400000;
				break;
			case ALGO_X14:
			case ALGO_X15:
				minmax = 0x300000;
				break;
			case ALGO_LYRA2:
			case ALGO_LYRA2Z:
			case ALGO_NEOSCRYPT:
			case ALGO_SIB:
			case ALGO_SCRYPT:
			case ALGO_VELTOR:
				minmax = 0x80000;
				break;
			case ALGO_CRYPTOLIGHT:
			case ALGO_CRYPTONIGHT:
			case ALGO_SCRYPT_JANE:
				minmax = 0x1000;
=======
		
		if (max64 < minmax) {
			switch (opt_algo) {
			case ALGO_KECCAK:
			case ALGO_BLAKECOIN:
			case ALGO_BLAKE:
			case ALGO_VANILLA:
			case ALGO_PENTABLAKE:
			case ALGO_WHC:
				minmax = 0x70000000U;
				break;
			case ALGO_SKEIN:
			case ALGO_BITCOIN:
			case ALGO_WHCX:
			case ALGO_QUBIT:
			case ALGO_QUARK:
			case ALGO_X14:
			case ALGO_LYRA2v2:
				minmax = 0x40000000U;
				break;
			case ALGO_DOOM:
			case ALGO_JACKPOT:
			case ALGO_LUFFA_DOOM:
			case ALGO_NEO:
				minmax = 0x2000000;
				break;
			case ALGO_X11:
			case ALGO_C11:
			case ALGO_X17:
			case ALGO_XEVAN:
			case ALGO_SCRYPT_JANE:
				minmax = 0x800000;
				break;
			case ALGO_S3:
				minmax = 0x400000;
				break;
			case ALGO_X13:
			case ALGO_X15:
			case ALGO_LYRA2:
				minmax = 0x300000;
				break;
			case ALGO_SCRYPT:
				minmax = 0x100000;
>>>>>>> 8c320ca... added xevan
				break;
			}
			max64 = max(minmax-1, max64);
		}

<<<<<<< HEAD
		// we can't scan more than uint32 capacity
		max64 = min(UINT32_MAX, max64);

		start_nonce = nonceptr[0];

		/* never let small ranges at end */
		if (end_nonce >= UINT32_MAX - 256)
			end_nonce = UINT32_MAX;

		if ((max64 + start_nonce) >= end_nonce)
			max_nonce = end_nonce;
		else
			max_nonce = (uint32_t) (max64 + start_nonce);

		// todo: keep it rounded to a multiple of 256 ?

		if (unlikely(start_nonce > max_nonce)) {
			// should not happen but seen in skein2 benchmark with 2 gpus
			max_nonce = end_nonce = UINT32_MAX;
		}

		work.scanned_from = start_nonce;

		gpulog(LOG_DEBUG, thr_id, "start=%08x end=%08x range=%08x",
			start_nonce, max_nonce, (max_nonce-start_nonce));

		if (opt_led_mode == LED_MODE_MINING)
			gpu_led_on(dev_id);

		if (cgpu && loopcnt > 1) {
			cgpu->monitor.sampling_flag = true;
			pthread_cond_signal(&cgpu->monitor.sampling_signal);
		}
=======
		// we can't scan more than uint capacity
		max64 = min(UINT32_MAX, max64);
		start_nonce = nonceptr[0];

		if (opt_benchmark)
		{
			max_nonce = start_nonce + 0x5000000U;
		}
		else
		{

			/* never let small ranges at end */
			if (end_nonce >= UINT32_MAX - 256)
				end_nonce = UINT32_MAX;

			if ((max64 + start_nonce) >= end_nonce)
				max_nonce = end_nonce;
			else
				max_nonce = (uint32_t)(max64 + start_nonce);

			// todo: keep it rounded for gpu threads ?
			work.scanned_from = start_nonce;
			nonceptr[0] = start_nonce;
		}
		if (opt_debug)
			applog(LOG_DEBUG, "GPU #%d: start=%08x end=%08x range=%08x",
				device_map[thr_id], start_nonce, max_nonce, (max_nonce-start_nonce));
>>>>>>> 8c320ca... added xevan

		hashes_done = 0;
		gettimeofday(&tv_start, NULL);

<<<<<<< HEAD
		// check (and reset) previous errors
		cudaError_t err = cudaGetLastError();
		if (err != cudaSuccess && !opt_quiet)
			gpulog(LOG_WARNING, thr_id, "%s", cudaGetErrorString(err));

		work.valid_nonces = 0;

		/* scan nonces for a proof-of-work hash */
		switch (opt_algo) {

		case ALGO_BASTION:
			rc = scanhash_bastion(thr_id, &work, max_nonce, &hashes_done);
			break;
		case ALGO_BLAKECOIN:
			rc = scanhash_blake256(thr_id, &work, max_nonce, &hashes_done, 8);
			break;
		case ALGO_BLAKE:
			rc = scanhash_blake256(thr_id, &work, max_nonce, &hashes_done, 14);
			break;
		case ALGO_BLAKE2S:
			rc = scanhash_blake2s(thr_id, &work, max_nonce, &hashes_done);
			break;
		case ALGO_BMW:
			rc = scanhash_bmw(thr_id, &work, max_nonce, &hashes_done);
			break;
		case ALGO_C11:
			rc = scanhash_c11(thr_id, &work, max_nonce, &hashes_done);
			break;
		case ALGO_CRYPTOLIGHT:
			rc = scanhash_cryptolight(thr_id, &work, max_nonce, &hashes_done);
			break;
		case ALGO_CRYPTONIGHT:
			rc = scanhash_cryptonight(thr_id, &work, max_nonce, &hashes_done);
			break;
		case ALGO_DECRED:
			//applog(LOG_BLUE, "version %x, nbits %x, ntime %x extra %x",
			//	work.data[0], work.data[29], work.data[34], work.data[38]);
			rc = scanhash_decred(thr_id, &work, max_nonce, &hashes_done);
			break;
		case ALGO_DEEP:
			rc = scanhash_deep(thr_id, &work, max_nonce, &hashes_done);
			break;
		case ALGO_EQUIHASH:
			rc = scanhash_equihash(thr_id, &work, max_nonce, &hashes_done);
			break;
		case ALGO_FRESH:
			rc = scanhash_fresh(thr_id, &work, max_nonce, &hashes_done);
			break;
		case ALGO_FUGUE256:
			rc = scanhash_fugue256(thr_id, &work, max_nonce, &hashes_done);
=======
		/* scan nonces for a proof-of-work hash */
		switch (opt_algo) {

		case ALGO_HEAVY:
			rc = scanhash_heavy(thr_id, work.data, work.target,
			                      max_nonce, &hashes_done, work.maxvote, HEAVYCOIN_BLKHDR_SZ);
			break;

		case ALGO_KECCAK:
			rc = scanhash_keccak256(thr_id, work.data, work.target,
			                      max_nonce, &hashes_done);
			break;

		case ALGO_MJOLLNIR:
			rc = scanhash_heavy(thr_id, work.data, work.target,
			                      max_nonce, &hashes_done, 0, MNR_BLKHDR_SZ);
			break;

		case ALGO_DEEP:
			rc = scanhash_deep(thr_id, work.data, work.target,
			                      max_nonce, &hashes_done);
			break;

		case ALGO_DOOM:
		case ALGO_LUFFA_DOOM:
			rc = scanhash_doom(thr_id, work.data, work.target,
			                      max_nonce, &hashes_done);
			break;

		case ALGO_C11:
			rc = scanhash_c11(thr_id, work.data, work.target,
			max_nonce, &hashes_done);
			break;
				
		case ALGO_FUGUE256:
			rc = scanhash_fugue256(thr_id, work.data, work.target,
			                      max_nonce, &hashes_done);
>>>>>>> 8c320ca... added xevan
			break;

		case ALGO_GROESTL:
		case ALGO_DMD_GR:
<<<<<<< HEAD
			rc = scanhash_groestlcoin(thr_id, &work, max_nonce, &hashes_done);
			break;
		case ALGO_MYR_GR:
			rc = scanhash_myriad(thr_id, &work, max_nonce, &hashes_done);
			break;

		case ALGO_HMQ1725:
			rc = scanhash_hmq17(thr_id, &work, max_nonce, &hashes_done);
			break;

		case ALGO_HEAVY:
			rc = scanhash_heavy(thr_id, &work, max_nonce, &hashes_done, work.maxvote, HEAVYCOIN_BLKHDR_SZ);
			break;
		case ALGO_MJOLLNIR:
			rc = scanhash_heavy(thr_id, &work, max_nonce, &hashes_done, 0, MNR_BLKHDR_SZ);
			break;

		case ALGO_KECCAK:
			rc = scanhash_keccak256(thr_id, &work, max_nonce, &hashes_done);
			break;

		case ALGO_JACKPOT:
			rc = scanhash_jackpot(thr_id, &work, max_nonce, &hashes_done);
			break;
		case ALGO_JHA:
			rc = scanhash_jha(thr_id, &work, max_nonce, &hashes_done);
			break;

		case ALGO_LBRY:
			rc = scanhash_lbry(thr_id, &work, max_nonce, &hashes_done);
			break;
		case ALGO_LUFFA:
			rc = scanhash_luffa(thr_id, &work, max_nonce, &hashes_done);
			break;
		case ALGO_QUARK:
			rc = scanhash_quark(thr_id, &work, max_nonce, &hashes_done);
			break;
		case ALGO_QUBIT:
			rc = scanhash_qubit(thr_id, &work, max_nonce, &hashes_done);
			break;
		case ALGO_LYRA2:
			rc = scanhash_lyra2(thr_id, &work, max_nonce, &hashes_done);
			break;
		case ALGO_LYRA2v2:
			rc = scanhash_lyra2v2(thr_id, &work, max_nonce, &hashes_done);
			break;
		case ALGO_LYRA2Z:
			rc = scanhash_lyra2Z(thr_id, &work, max_nonce, &hashes_done);
			break;
		case ALGO_NEOSCRYPT:
			rc = scanhash_neoscrypt(thr_id, &work, max_nonce, &hashes_done);
			break;
		case ALGO_NIST5:
			rc = scanhash_nist5(thr_id, &work, max_nonce, &hashes_done);
			break;
		case ALGO_PENTABLAKE:
			rc = scanhash_pentablake(thr_id, &work, max_nonce, &hashes_done);
			break;
		case ALGO_SCRYPT:
			rc = scanhash_scrypt(thr_id, &work, max_nonce, &hashes_done,
				NULL, &tv_start, &tv_end);
			break;
		case ALGO_SCRYPT_JANE:
			rc = scanhash_scrypt_jane(thr_id, &work, max_nonce, &hashes_done,
				NULL, &tv_start, &tv_end);
			break;
		case ALGO_SKEIN:
			rc = scanhash_skeincoin(thr_id, &work, max_nonce, &hashes_done);
			break;
		case ALGO_SKEIN2:
			rc = scanhash_skein2(thr_id, &work, max_nonce, &hashes_done);
			break;
		case ALGO_SKUNK:
			rc = scanhash_skunk(thr_id, &work, max_nonce, &hashes_done);
			break;
		case ALGO_SHA256D:
			rc = scanhash_sha256d(thr_id, &work, max_nonce, &hashes_done);
			break;
		case ALGO_SHA256T:
			rc = scanhash_sha256t(thr_id, &work, max_nonce, &hashes_done);
			break;
		case ALGO_SIA:
			rc = scanhash_sia(thr_id, &work, max_nonce, &hashes_done);
			break;
		case ALGO_SIB:
			rc = scanhash_sib(thr_id, &work, max_nonce, &hashes_done);
			break;
		case ALGO_S3:
			rc = scanhash_s3(thr_id, &work, max_nonce, &hashes_done);
			break;
		case ALGO_VANILLA:
			rc = scanhash_vanilla(thr_id, &work, max_nonce, &hashes_done, 8);
			break;
		case ALGO_VELTOR:
			rc = scanhash_veltor(thr_id, &work, max_nonce, &hashes_done);
			break;
		case ALGO_WHIRLCOIN:
		case ALGO_WHIRLPOOL:
			rc = scanhash_whirl(thr_id, &work, max_nonce, &hashes_done);
			break;
		//case ALGO_WHIRLPOOLX:
		//	rc = scanhash_whirlx(thr_id, &work, max_nonce, &hashes_done);
		//	break;
		case ALGO_WILDKECCAK:
			rc = scanhash_wildkeccak(thr_id, &work, max_nonce, &hashes_done);
			break;
		case ALGO_TIMETRAVEL:
			rc = scanhash_timetravel(thr_id, &work, max_nonce, &hashes_done);
			break;
		case ALGO_TRIBUS:
			rc = scanhash_tribus(thr_id, &work, max_nonce, &hashes_done);
			break;
		case ALGO_BITCORE:
			rc = scanhash_bitcore(thr_id, &work, max_nonce, &hashes_done);
			break;
		case ALGO_X11EVO:
			rc = scanhash_x11evo(thr_id, &work, max_nonce, &hashes_done);
			break;
		case ALGO_X11:
			rc = scanhash_x11(thr_id, &work, max_nonce, &hashes_done);
			break;
		case ALGO_X13:
			rc = scanhash_x13(thr_id, &work, max_nonce, &hashes_done);
			break;
		case ALGO_X14:
			rc = scanhash_x14(thr_id, &work, max_nonce, &hashes_done);
			break;
		case ALGO_X15:
			rc = scanhash_x15(thr_id, &work, max_nonce, &hashes_done);
			break;
		case ALGO_X17:
			rc = scanhash_x17(thr_id, &work, max_nonce, &hashes_done);
			break;
		case ALGO_ZR5:
			rc = scanhash_zr5(thr_id, &work, max_nonce, &hashes_done);
			break;

=======
			rc = scanhash_groestlcoin(thr_id, work.data, work.target,
			                      max_nonce, &hashes_done);
			break;

		case ALGO_MYR_GR:
			rc = scanhash_myriad(thr_id, work.data, work.target,
			                      max_nonce, &hashes_done);
			break;

		case ALGO_JACKPOT:
			rc = scanhash_jackpot(thr_id, work.data, work.target,
			                      max_nonce, &hashes_done);
			break;

		case ALGO_QUARK:
			rc = scanhash_quark(thr_id, work.data, work.target,
			                      max_nonce, &hashes_done);
			break;

		case ALGO_QUBIT:
			rc = scanhash_qubit(thr_id, work.data, work.target,
			                      max_nonce, &hashes_done);
			break;
		case ALGO_SCRYPT:
			rc = scanhash_scrypt(thr_id, work.data, work.target, NULL,
			max_nonce, &hashes_done, &tv_start, &tv_end);
			break;
			
		case ALGO_SCRYPT_JANE:
			rc = scanhash_scrypt_jane(thr_id, work.data, work.target, NULL,
			max_nonce, &hashes_done, &tv_start, &tv_end);
			break;

		case ALGO_SKEIN:
			rc = scanhash_skeincoin(thr_id, work.data, work.target,
				max_nonce, (uint32_t*)&hashes_done);
						break;

		case ALGO_BASTION:
			rc = scanhash_bastion(thr_id, work.data, work.target,
				max_nonce, &hashes_done);
			break;

		case ALGO_BITCOIN:
			rc = scanhash_bitcoin(thr_id, work.data, work.target,
				max_nonce, &hashes_done);
			break;

		case ALGO_BLAKECOIN:
			rc = scanhash_blake256(thr_id, work.data, work.target,
			                      max_nonce, &hashes_done, 8);
			break;

		case ALGO_BLAKE:
			rc = scanhash_blake256(thr_id, work.data, work.target,
			                      max_nonce, &hashes_done, 14);
			break;

		case ALGO_FRESH:
			rc = scanhash_fresh(thr_id, work.data, work.target,
			                      max_nonce, &hashes_done);
			break;

		case ALGO_LYRA2:
			rc = scanhash_lyra2(thr_id, work.data, work.target,
			                      max_nonce, &hashes_done);
			break;
		case ALGO_LYRA2v2:
			rc = scanhash_lyra2v2(thr_id, work.data, work.target,
				max_nonce, &hashes_done);
			break;

		case ALGO_NIST5:
			rc = scanhash_nist5(thr_id, work.data, work.target,
			                      max_nonce, &hashes_done);
			break;

		case ALGO_PENTABLAKE:
			rc = scanhash_pentablake(thr_id, work.data, work.target,
			                      max_nonce, &hashes_done);
			break;

		case ALGO_S3:
			rc = scanhash_s3(thr_id, work.data, work.target,
			                      max_nonce, &hashes_done);
			break;

		case ALGO_WHC:
			rc = scanhash_whc(thr_id, work.data, work.target,
			                      max_nonce, &hashes_done);
			break;

		case ALGO_WHCX:
			rc = scanhash_whirlpoolx(thr_id, work.data, work.target,
				max_nonce, (uint32_t*)&hashes_done);
			break;

		case ALGO_X11:
			rc = scanhash_x11(thr_id, work.data, work.target,
			                      max_nonce, &hashes_done);
			break;

		case ALGO_X13:
			rc = scanhash_x13(thr_id, work.data, work.target,
			                      max_nonce, &hashes_done);
			break;

		case ALGO_X14:
			rc = scanhash_x14(thr_id, work.data, work.target,
				max_nonce, &hashes_done);
			break;

		case ALGO_X15:
			rc = scanhash_x15(thr_id, work.data, work.target,
				max_nonce, &hashes_done);
			break;

		case ALGO_X17:
			rc = scanhash_x17(thr_id, work.data, work.target,
				max_nonce, &hashes_done);
			break;
		case ALGO_XEVAN:
			rc = scanhash_xevan(thr_id, work.data, work.target,
				max_nonce, &hashes_done);
			break;
		case ALGO_VANILLA:
			rc = scanhash_blake256(thr_id, work.data, work.target,
				max_nonce, &hashes_done, 8);
			break;

		case ALGO_NEO:
			rc = scanhash_neoscrypt(have_stratum, thr_id, work.data, work.target, max_nonce, &hashes_done);
			break;
		case ALGO_BITC:
			rc = scanhash_bitcredit(thr_id, work.data, work.target, work.midstate, max_nonce, &hashes_done);
			break;			
>>>>>>> 8c320ca... added xevan
		default:
			/* should never happen */
			goto out;
		}

<<<<<<< HEAD
		if (opt_led_mode == LED_MODE_MINING)
			gpu_led_off(dev_id);

		if (abort_flag)
			break; // time to leave the mining loop...

		if (work_restart[thr_id].restart)
			continue;

		/* record scanhash elapsed time */
		gettimeofday(&tv_end, NULL);

		switch (opt_algo) {
			// algos to migrate to replace pdata[21] by work.nonces[]
			case ALGO_HEAVY:
			case ALGO_SCRYPT:
			case ALGO_SCRYPT_JANE:
			//case ALGO_WHIRLPOOLX:
				work.nonces[0] = nonceptr[0];
				work.nonces[1] = nonceptr[2];
		}

		if (stratum.rpc2 && (rc == -EBUSY || work_restart[thr_id].restart)) {
			// bbr scratchpad download or stale result
			sleep(1);
			if (!thr_id) pools[cur_pooln].wait_time += 1;
			continue;
		}

		if (rc > 0 && opt_debug)
			applog(LOG_NOTICE, CL_CYN "found => %08x" CL_GRN " %08x", work.nonces[0], swab32(work.nonces[0]));
		if (rc > 1 && opt_debug)
			applog(LOG_NOTICE, CL_CYN "found => %08x" CL_GRN " %08x", work.nonces[1], swab32(work.nonces[1]));

		timeval_subtract(&diff, &tv_end, &tv_start);

		if (cgpu && diff.tv_sec) { // stop monitoring
			cgpu->monitor.sampling_flag = false;
		}

		if (diff.tv_usec || diff.tv_sec) {
=======
		/* record scanhash elapsed time */
		gettimeofday(&tv_end, NULL);

		if (firstwork_time == 0)
			firstwork_time = time(NULL);

		if (rc && opt_debug)
			applog(LOG_NOTICE, CL_CYN "found => %08x" CL_GRN " %08x", nonceptr[0], swab32(nonceptr[0])); // data[19]
		if (rc > 1 && opt_debug)
			applog(LOG_NOTICE, CL_CYN "found => %08x" CL_GRN " %08x", nonceptr[2], swab32(nonceptr[2])); // data[21]

		timeval_subtract(&diff, &tv_end, &tv_start);

//		diff.tv_sec == 0 &&
		if (diff.tv_sec > 0 || (diff.tv_sec == 0 && diff.tv_usec>2000)) // avoid totally wrong hash rates
		{
>>>>>>> 8c320ca... added xevan
			double dtime = (double) diff.tv_sec + 1e-6 * diff.tv_usec;

			/* hashrate factors for some algos */
			double rate_factor = 1.0;
			switch (opt_algo) {
				case ALGO_JACKPOT:
				case ALGO_QUARK:
					// to stay comparable to other ccminer forks or pools
					rate_factor = 0.5;
					break;
			}

			/* store thread hashrate */
			if (dtime > 0.0) {
				pthread_mutex_lock(&stats_lock);
				thr_hashrates[thr_id] = hashes_done / dtime;
				thr_hashrates[thr_id] *= rate_factor;
<<<<<<< HEAD
				if (loopcnt > 2) // ignore first (init time)
					stats_remember_speed(thr_id, hashes_done, thr_hashrates[thr_id], (uint8_t) rc, work.height);
=======
				stats_remember_speed(thr_id, hashes_done, thr_hashrates[thr_id], (uint8_t) rc, work.height);
>>>>>>> 8c320ca... added xevan
				pthread_mutex_unlock(&stats_lock);
			}
		}

<<<<<<< HEAD
		if (rc > 0)
			work.scanned_to = work.nonces[0];
		if (rc > 1)
			work.scanned_to = max(work.nonces[0], work.nonces[1]);
		else {
			work.scanned_to = max_nonce;
			if (opt_debug && opt_benchmark) {
				// to debug nonce ranges
				gpulog(LOG_DEBUG, thr_id, "ends=%08x range=%08x", nonceptr[0], (nonceptr[0] - start_nonce));
			}
			// prevent low scan ranges on next loop on fast algos (blake)
			if (nonceptr[0] > UINT32_MAX - 64)
				nonceptr[0] = UINT32_MAX;
		}

		// only required to debug purpose
		if (opt_debug && check_dups && opt_algo != ALGO_DECRED && opt_algo != ALGO_EQUIHASH && opt_algo != ALGO_SIA)
			hashlog_remember_scan_range(&work);

		/* output */
		if (!opt_quiet && loopcnt > 1 && (time(NULL) - tm_rate_log) > opt_maxlograte) {
			format_hashrate(thr_hashrates[thr_id], s);
			gpulog(LOG_INFO, thr_id, "%s, %s", device_name[dev_id], s);
			tm_rate_log = time(NULL);
		}

		/* ignore first loop hashrate */
		if (firstwork_time && thr_id == (opt_n_threads - 1)) {
			double hashrate = 0.;
			pthread_mutex_lock(&stats_lock);
			for (int i = 0; i < opt_n_threads && thr_hashrates[i]; i++)
				hashrate += stats_get_speed(i, thr_hashrates[i]);
			pthread_mutex_unlock(&stats_lock);
			if (opt_benchmark && bench_algo == -1 && loopcnt > 2) {
				format_hashrate(hashrate, s);
				applog(LOG_NOTICE, "Total: %s", s);
			}

			// since pool start
			pools[cur_pooln].work_time = (uint32_t) (time(NULL) - firstwork_time);

			// X-Mining-Hashrate
			global_hashrate = llround(hashrate);
		}

		if (firstwork_time == 0)
			firstwork_time = time(NULL);

		if (cgpu) cgpu->accepted += work.valid_nonces;

		/* if nonce found, submit work */
		if (rc > 0 && !opt_benchmark) {
			uint32_t curnonce = nonceptr[0]; // current scan position

			if (opt_led_mode == LED_MODE_SHARES)
				gpu_led_percent(dev_id, 50);

			work.submit_nonce_id = 0;
			nonceptr[0] = work.nonces[0];
			if (!submit_work(mythr, &work))
				break;
			nonceptr[0] = curnonce;

			// prevent stale work in solo
			// we can't submit twice a block!
			if (!have_stratum && !have_longpoll) {
=======
		work.scanned_to = start_nonce + hashes_done;
		if (opt_debug && opt_benchmark) 
		{
			// to debug nonce ranges
			applog(LOG_DEBUG, "GPU #%d:  ends=%08x range=%llx", device_map[thr_id],
				start_nonce + hashes_done, hashes_done);
		}

		if (check_dups)
			hashlog_remember_scan_range(&work);

		if (((opt_algo == ALGO_BITC) ? (loopcnt % 400 == 0) : (loopcnt)))
		{
			bool   writelog = false;
			double hashrate = 0.0;

			if (opt_n_gputhreads != 1)
			{
				if (loopcnt%opt_n_gputhreads == 0 ) //Display the hash 1 time per gpu and not opt_n_gputhreads times per gpu
				{
					int index = thr_id / opt_n_gputhreads;
					for (int i = 0; i < opt_n_gputhreads; i++)
					{
						hashrate += thr_hashrates[(index*opt_n_gputhreads) + i];
					}
					if (!opt_quiet) writelog = true;
				}
			}
			else
			{	

				if(!opt_quiet) writelog = true;
				hashrate = thr_hashrates[thr_id];
			}
			if (hashrate == 0.0) writelog = false;
			if (writelog)
			{
#ifdef USE_WRAPNVML
				if (hnvml != NULL) {
					uint32_t tempC=0, fanpcnt=0, mwatts=0, graphics_clock=0, mem_clock=0;

					nvml_get_tempC(hnvml, device_map[thr_id], &tempC);
					nvml_get_fanpcnt(hnvml, device_map[thr_id], &fanpcnt);
					nvml_get_current_clocks(hnvml, device_map[thr_id], &graphics_clock, &mem_clock);
					//if (nvml_get_power_usage(hnvml, device_map[thr_id], &mwatts) == 0)
					//    sprintf(gpupowbuf, "%dW", (mwatts / 1000));

					applog(LOG_INFO, "GPU #%d: %s, %*.f (T=%3dC F=%3d%% C=%d/%d)", device_map[thr_id], device_name[device_map[thr_id]], (hashrate > 1e6) ? 0 : 2, 1e-3 * hashrate, tempC, fanpcnt, graphics_clock, mem_clock);
				}
				else
#endif
				{
					applog(LOG_INFO, "GPU #%d: %s, %*.f", device_map[thr_id], device_name[device_map[thr_id]], (hashrate > 1e6) ? 0 : 2, 1e-3 * hashrate);
				}
			}
		}

		/* loopcnt: ignore first loop hashrate */
		if ((loopcnt>0) && thr_id == (opt_n_threads - 1)) 
		{
			double hashrate = 0.;
			pthread_mutex_lock(&stats_lock);
			for (int i = 0; i < opt_n_threads; i++)
				hashrate += stats_get_speed(i, thr_hashrates[i]);
			pthread_mutex_unlock(&stats_lock);
			if (opt_benchmark) 
			{
				double hashrate = 0.;
				pthread_mutex_lock(&stats_lock);
				for (int i = 0; i < opt_n_threads && thr_hashrates[i]; i++)
					hashrate += stats_get_speed(i, thr_hashrates[i]);
				pthread_mutex_unlock(&stats_lock);
				if (opt_benchmark && loopcnt >1) {
					format_hashrate(hashrate, s);
					applog(LOG_NOTICE, "Total: %s", s);
				}
				// X-Mining-Hashrate
				global_hashrate = llround(hashrate);	
			}
		}

		/* if nonce found, submit work */
		if (rc && !opt_benchmark) {
			if (!submit_work(mythr, &work))
				break;

			// prevent stale work in solo
			// we can't submit twice a block!
			if (!have_stratum) {
>>>>>>> 8c320ca... added xevan
				pthread_mutex_lock(&g_work_lock);
				// will force getwork
				g_work_time = 0;
				pthread_mutex_unlock(&g_work_lock);
				continue;
			}

			// second nonce found, submit too (on pool only!)
<<<<<<< HEAD
			if (rc > 1 && work.nonces[1]) {
				work.submit_nonce_id = 1;
				nonceptr[0] = work.nonces[1];
				if (opt_algo == ALGO_ZR5) {
					work.data[0] = work.data[22]; // pok
					work.data[22] = 0;
				}
				if (!submit_work(mythr, &work))
					break;
				nonceptr[0] = curnonce;
				work.nonces[1] = 0; // reset
			}
		}
	}

out:
	if (opt_led_mode)
		gpu_led_off(dev_id);
	if (opt_debug_threads)
		applog(LOG_DEBUG, "%s() died", __func__);
	tq_freeze(mythr->q);
=======
			if (rc > 1 && work.data[21]) {
				work.data[19] = work.data[21];
				work.data[21] = 0;
				if (!submit_work(mythr, &work))
					break;
			}
		}
		work.data[19] = start_nonce + hashes_done;
		loopcnt++;
	}

	return NULL;

out:
	tq_freeze(mythr->q);

>>>>>>> 8c320ca... added xevan
	return NULL;
}

static void *longpoll_thread(void *userdata)
{
	struct thr_info *mythr = (struct thr_info *)userdata;
<<<<<<< HEAD
	struct pool_infos *pool;
	CURL *curl = NULL;
	char *hdr_path = NULL, *lp_url = NULL;
	const char *rpc_req = json_rpc_getwork;
	bool need_slash = false;
	int pooln, switchn;

	curl = curl_easy_init();
	if (unlikely(!curl)) {
		applog(LOG_ERR, "%s() CURL init failed", __func__);
		goto out;
	}

wait_lp_url:
	hdr_path = (char*)tq_pop(mythr->q, NULL); // wait /LP url
	if (!hdr_path)
		goto out;

	if (!(pools[cur_pooln].type & POOL_STRATUM)) {
		pooln = cur_pooln;
		pool = &pools[pooln];
	} else {
		// hack...
		have_stratum = true;
	}

	// to detect pool switch during loop
	switchn = pool_switch_count;

	if (opt_algo == ALGO_SIA) {
		goto out;
	}

	/* full URL */
	else if (strstr(hdr_path, "://")) {
		lp_url = hdr_path;
		hdr_path = NULL;
	}
	/* absolute path, on current server */
	else {
		char *copy_start = (*hdr_path == '/') ? (hdr_path + 1) : hdr_path;
=======
	CURL *curl = NULL;
	char *copy_start, *hdr_path = NULL, *lp_url = NULL;
	bool need_slash = false;

	curl = curl_easy_init();
	if (unlikely(!curl)) {
		applog(LOG_ERR, "CURL initialization failed");
		goto out;
	}

	hdr_path = (char*)tq_pop(mythr->q, NULL);
	if (!hdr_path)
		goto out;

	/* full URL */
	if (strstr(hdr_path, "://")) {
		lp_url = hdr_path;
		hdr_path = NULL;
	}
	
	/* absolute path, on current server */
	else {
		copy_start = (*hdr_path == '/') ? (hdr_path + 1) : hdr_path;
>>>>>>> 8c320ca... added xevan
		if (rpc_url[strlen(rpc_url) - 1] != '/')
			need_slash = true;

		lp_url = (char*)malloc(strlen(rpc_url) + strlen(copy_start) + 2);
		if (!lp_url)
			goto out;

		sprintf(lp_url, "%s%s%s", rpc_url, need_slash ? "/" : "", copy_start);
	}

<<<<<<< HEAD
	if (!pool_is_switching)
		applog(LOG_BLUE, "Long-polling on %s", lp_url);

	pool_is_switching = false;

	pool->type |= POOL_LONGPOLL;

longpoll_retry:

	while (!abort_flag) {
		json_t *val = NULL, *soval;
		int err = 0;

		if (opt_debug_threads)
			applog(LOG_DEBUG, "longpoll %d: %d count %d %d, switching=%d, have_stratum=%d",
				pooln, cur_pooln, switchn, pool_switch_count, pool_is_switching, have_stratum);

		// exit on pool switch
		if (switchn != pool_switch_count)
			goto need_reinit;

		if (opt_algo == ALGO_SIA) {
			char *sia_header = sia_getheader(curl, pool);
			if (sia_header) {
				pthread_mutex_lock(&g_work_lock);
				if (sia_work_decode(sia_header, &g_work)) {
					g_work_time = time(NULL);
				}
				free(sia_header);
				pthread_mutex_unlock(&g_work_lock);
			}
			continue;
		}

		val = json_rpc_longpoll(curl, lp_url, pool, rpc_req, &err);
		if (have_stratum || switchn != pool_switch_count) {
			if (val)
				json_decref(val);
			goto need_reinit;
		}
		if (likely(val)) {
=======
	applog(LOG_INFO, "Long-polling activated for %s", lp_url);

	while (!abort_flag) {
		json_t *val, *soval;
		int err;

		val = json_rpc_call(curl, lp_url, rpc_userpass, rpc_req,
				    false, true, &err);


		network_fail_flag = (err != CURLE_OK);

		if (have_stratum) {
			if (val)
				json_decref(val);
			goto out;
		}
		if (likely(val)) 
		{
			if (!opt_quiet) applog(LOG_INFO, "LONGPOLL detected new block");
>>>>>>> 8c320ca... added xevan
			soval = json_object_get(json_object_get(val, "result"), "submitold");
			submit_old = soval ? json_is_true(soval) : false;
			pthread_mutex_lock(&g_work_lock);
			if (work_decode(json_object_get(val, "result"), &g_work)) {
<<<<<<< HEAD
				restart_threads();
				if (!opt_quiet) {
					char netinfo[64] = { 0 };
					if (net_diff > 0.) {
						sprintf(netinfo, ", diff %.3f", net_diff);
					}
					if (opt_showdiff) {
						sprintf(&netinfo[strlen(netinfo)], ", target %.3f", g_work.targetdiff);
					}
					if (g_work.height)
						applog(LOG_BLUE, "%s block %u%s", algo_names[opt_algo], g_work.height, netinfo);
					else
						applog(LOG_BLUE, "%s detected new block%s", short_url, netinfo);
				}
				g_work_time = time(NULL);
=======
				if (opt_debug)
					applog(LOG_BLUE, "LONGPOLL pushed new work");
				g_work_time = time(NULL);
				applog(LOG_BLUE, "Restart threafds");
				restart_threads();
>>>>>>> 8c320ca... added xevan
			}
			pthread_mutex_unlock(&g_work_lock);
			json_decref(val);
		} else {
<<<<<<< HEAD
			// to check...
			g_work_time = 0;
			if (err != CURLE_OPERATION_TIMEDOUT) {
				if (opt_debug_threads) applog(LOG_DEBUG, "%s() err %d, retry in %s seconds",
					__func__, err, opt_fail_pause);
				sleep(opt_fail_pause);
				goto longpoll_retry;
=======
			pthread_mutex_lock(&g_work_lock);
			g_work_time -= LP_SCANTIME;
			pthread_mutex_unlock(&g_work_lock);
			restart_threads();
			if (err != CURLE_OPERATION_TIMEDOUT) {
				have_longpoll = false;
				free(hdr_path);
				free(lp_url);
				lp_url = NULL;
				sleep(opt_fail_pause);
>>>>>>> 8c320ca... added xevan
			}
		}
	}

out:
<<<<<<< HEAD
	have_longpoll = false;
	if (opt_debug_threads)
		applog(LOG_DEBUG, "%s() died", __func__);

=======
>>>>>>> 8c320ca... added xevan
	free(hdr_path);
	free(lp_url);
	tq_freeze(mythr->q);
	if (curl)
		curl_easy_cleanup(curl);

	return NULL;
<<<<<<< HEAD

need_reinit:
	/* this thread should not die to allow pool switch */
	have_longpoll = false;
	if (opt_debug_threads)
		applog(LOG_DEBUG, "%s() reinit...", __func__);
	if (hdr_path) free(hdr_path); hdr_path = NULL;
	if (lp_url) free(lp_url); lp_url = NULL;
	goto wait_lp_url;
=======
>>>>>>> 8c320ca... added xevan
}

static bool stratum_handle_response(char *buf)
{
	json_t *val, *err_val, *res_val, *id_val;
	json_error_t err;
	struct timeval tv_answer, diff;
<<<<<<< HEAD
	int num = 0, job_nonce_id = 0;
	double sharediff = stratum.sharediff;
=======
>>>>>>> 8c320ca... added xevan
	bool ret = false;

	val = JSON_LOADS(buf, &err);
	if (!val) {
		applog(LOG_INFO, "JSON decode failed(%d): %s", err.line, err.text);
		goto out;
	}

	res_val = json_object_get(val, "result");
	err_val = json_object_get(val, "error");
	id_val = json_object_get(val, "id");

<<<<<<< HEAD
	if (!id_val || json_is_null(id_val))
		goto out;

	// ignore late login answers
	num = (int) json_integer_value(id_val);
	if (num < 4)
		goto out;

	// We dont have the work anymore, so use the hashlog to get the right sharediff for multiple nonces
	job_nonce_id = num - 10;
	if (opt_showdiff && check_dups)
		sharediff = hashlog_get_sharediff(g_work.job_id, job_nonce_id, sharediff);

=======
	if (!id_val || json_is_null(id_val) || !res_val)
		goto out;

	// ignore subscribe late answer (yaamp)
	if (json_integer_value(id_val) < 4)
		goto out;

>>>>>>> 8c320ca... added xevan
	gettimeofday(&tv_answer, NULL);
	timeval_subtract(&diff, &tv_answer, &stratum.tv_submit);
	// store time required to the pool to answer to a submit
	stratum.answer_msec = (1000 * diff.tv_sec) + (uint32_t) (0.001 * diff.tv_usec);

<<<<<<< HEAD
	if (stratum.rpc2) {
		const char* reject_reason = err_val ? json_string_value(json_object_get(err_val, "message")) : NULL;
		// {"id":10,"jsonrpc":"2.0","error":null,"result":{"status":"OK"}}
		share_result(json_is_null(err_val), stratum.pooln, sharediff, reject_reason);
		if (reject_reason) {
			g_work_time = 0;
			restart_threads();
		}
	} else {
		if (!res_val)
			goto out;
		share_result(json_is_true(res_val), stratum.pooln, sharediff,
			err_val ? json_string_value(json_array_get(err_val, 1)) : NULL);
	}
=======
	share_result(json_is_true(res_val),
		err_val ? json_string_value(json_array_get(err_val, 1)) : NULL);
>>>>>>> 8c320ca... added xevan

	ret = true;
out:
	if (val)
		json_decref(val);

	return ret;
}

static void *stratum_thread(void *userdata)
{
	struct thr_info *mythr = (struct thr_info *)userdata;
<<<<<<< HEAD
	struct pool_infos *pool;
	stratum_ctx *ctx = &stratum;
	int pooln, switchn;
	char *s;

wait_stratum_url:
	stratum.url = (char*)tq_pop(mythr->q, NULL);
	if (!stratum.url)
		goto out;

	if (!pool_is_switching)
		applog(LOG_BLUE, "Starting on %s", stratum.url);

	ctx->pooln = pooln = cur_pooln;
	switchn = pool_switch_count;
	pool = &pools[pooln];

	pool_is_switching = false;
	stratum_need_reset = false;
=======
	char *s;

	stratum.url = (char*)tq_pop(mythr->q, NULL);
	if (!stratum.url)
		goto out;
	applog(LOG_BLUE, "Starting Stratum on %s", stratum.url);
>>>>>>> 8c320ca... added xevan

	while (!abort_flag) {
		int failures = 0;

		if (stratum_need_reset) {
			stratum_need_reset = false;
<<<<<<< HEAD
			if (stratum.url)
				stratum_disconnect(&stratum);
			else
				stratum.url = strdup(pool->url); // may be useless
=======
			stratum_disconnect(&stratum);
			applog(LOG_DEBUG, "stratum connection reset");
>>>>>>> 8c320ca... added xevan
		}

		while (!stratum.curl && !abort_flag) {
			pthread_mutex_lock(&g_work_lock);
			g_work_time = 0;
<<<<<<< HEAD
			g_work.data[0] = 0;
			pthread_mutex_unlock(&g_work_lock);
			restart_threads();

			if (!stratum_connect(&stratum, pool->url) ||
			    !stratum_subscribe(&stratum) ||
			    !stratum_authorize(&stratum, pool->user, pool->pass))
			{
				stratum_disconnect(&stratum);
				if (opt_retries >= 0 && ++failures > opt_retries) {
					if (num_pools > 1 && opt_pool_failover) {
						applog(LOG_WARNING, "Stratum connect timeout, failover...");
						pool_switch_next(-1);
					} else {
						applog(LOG_ERR, "...terminating workio thread");
						//tq_push(thr_info[work_thr_id].q, NULL);
						workio_abort();
						proper_exit(EXIT_CODE_POOL_TIMEOUT);
						goto out;
					}
				}
				if (switchn != pool_switch_count)
					goto pool_switched;
=======
			pthread_mutex_unlock(&g_work_lock);
			restart_threads();

			if (!stratum_connect(&stratum, stratum.url) ||
			    !stratum_subscribe(&stratum) ||
			    !stratum_authorize(&stratum, rpc_user, rpc_pass,opt_extranonce)) {
				stratum_disconnect(&stratum);
				network_fail_flag = true;

				if (opt_retries >= 0 && ++failures > opt_retries) {
					applog(LOG_ERR, "...terminating workio thread");
					tq_push(thr_info[work_thr_id].q, NULL);
					abort_flag = true;
					goto out;
				}
>>>>>>> 8c320ca... added xevan
				if (!opt_benchmark)
					applog(LOG_ERR, "...retry after %d seconds", opt_fail_pause);
				sleep(opt_fail_pause);
			}
		}

<<<<<<< HEAD
		if (stratum.rpc2) {
			rpc2_stratum_thread_stuff(pool);
		}

		if (switchn != pool_switch_count) goto pool_switched;

		if (stratum.job.job_id &&
		    (!g_work_time || strncmp(stratum.job.job_id, g_work.job_id + 8, sizeof(g_work.job_id)-8))) {
			pthread_mutex_lock(&g_work_lock);
			if (stratum_gen_work(&stratum, &g_work))
				g_work_time = time(NULL);
			if (stratum.job.clean) {
				static uint32_t last_block_height;
				if ((!opt_quiet || !firstwork_time) && stratum.job.height != last_block_height) {
					last_block_height = stratum.job.height;
					if (net_diff > 0.)
						applog(LOG_BLUE, "%s block %d, diff %.3f", algo_names[opt_algo],
							stratum.job.height, net_diff);
					else
						applog(LOG_BLUE, "%s %s block %d", pool->short_url, algo_names[opt_algo],
							stratum.job.height);
				}
				restart_threads();
				if (check_dups || opt_showdiff)
					hashlog_purge_old();
				stats_purge_old();
			} else if (opt_debug && !opt_quiet) {
					applog(LOG_BLUE, "%s asks job %d for block %d", pool->short_url,
=======
		if (stratum.job.job_id &&
		    (!g_work_time || strncmp(stratum.job.job_id, g_work.job_id + 8, 120))) {
			pthread_mutex_lock(&g_work_lock);
			stratum_gen_work(&stratum, &g_work);
			g_work_time = time(NULL);
			if (stratum.job.clean) 
			{
				network_fail_flag = false;
				if (!opt_quiet)
					applog(LOG_BLUE, "%s %s block %d", short_url, algo_names[opt_algo],
						stratum.job.height);
				restart_threads();
				if (check_dups)
					hashlog_purge_old();
				stats_purge_old();
			} else if (opt_debug && !opt_quiet) {
					applog(LOG_BLUE, "%s asks job %d for block %d", short_url,
>>>>>>> 8c320ca... added xevan
						strtoul(stratum.job.job_id, NULL, 16), stratum.job.height);
			}
			pthread_mutex_unlock(&g_work_lock);
		}
		
<<<<<<< HEAD
		// check we are on the right pool
		if (switchn != pool_switch_count) goto pool_switched;

		if (!stratum_socket_full(&stratum, opt_timeout)) {
			if (opt_debug)
				applog(LOG_WARNING, "Stratum connection timed out");
			s = NULL;
		} else
			s = stratum_recv_line(&stratum);

		// double check we are on the right pool
		if (switchn != pool_switch_count) goto pool_switched;

		if (!s) {
			stratum_disconnect(&stratum);
			if (!opt_quiet && !pool_on_hold)
				applog(LOG_WARNING, "Stratum connection interrupted");
=======
		if (!stratum_socket_full(&stratum, 120)) {
			applog(LOG_ERR, "Stratum connection timed out");
			s = NULL;
		} else
			s = stratum_recv_line(&stratum);
		if (!s) {
			stratum_disconnect(&stratum);
			applog(LOG_ERR, "Stratum connection interrupted");
>>>>>>> 8c320ca... added xevan
			continue;
		}
		if (!stratum_handle_method(&stratum, s))
			stratum_handle_response(s);
		free(s);
	}

<<<<<<< HEAD
out:
	if (opt_debug_threads)
		applog(LOG_DEBUG, "%s() died", __func__);

	return NULL;

pool_switched:
	/* this thread should not die on pool switch */
	stratum_disconnect(&(pools[pooln].stratum));
	if (stratum.url) free(stratum.url); stratum.url = NULL;
	if (opt_debug_threads)
		applog(LOG_DEBUG, "%s() reinit...", __func__);
	goto wait_stratum_url;
=======
	stratum_disconnect(&stratum);

out:
	return NULL;
>>>>>>> 8c320ca... added xevan
}

static void show_version_and_exit(void)
{
	printf("%s v%s\n"
#ifdef WIN32
		"pthreads static %s\n"
#endif
		"%s\n",
		PACKAGE_NAME, PACKAGE_VERSION,
#ifdef WIN32
		PTW32_VERSION_STRING,
#endif
		curl_version());
<<<<<<< HEAD
	proper_exit(EXIT_CODE_OK);
=======
	proper_exit(0);
>>>>>>> 8c320ca... added xevan
}

static void show_usage_and_exit(int status)
{
	if (status)
		fprintf(stderr, "Try `" PROGRAM_NAME " --help' for more information.\n");
	else
		printf(usage);
<<<<<<< HEAD

	if (opt_algo == ALGO_SCRYPT || opt_algo == ALGO_SCRYPT_JANE) {
		printf(scrypt_usage);
	}
	else if (opt_algo == ALGO_CRYPTONIGHT || opt_algo == ALGO_CRYPTOLIGHT) {
		printf(xmr_usage);
	}
	else if (opt_algo == ALGO_WILDKECCAK) {
		printf(bbr_usage);
	}
	proper_exit(status);
}

void parse_arg(int key, char *arg)
{
	char *p = arg;
	int v, i;
	uint64_t ul;
	double d;

	switch(key) {
	case 'a': /* --algo */
		p = strstr(arg, ":"); // optional factor
		if (p) *p = '\0';

		i = algo_to_int(arg);
		if (i >= 0)
			opt_algo = (enum sha_algos)i;
		else {
			applog(LOG_ERR, "Unknown algo parameter '%s'", arg);
			show_usage_and_exit(1);
		}

		if (p) {
			opt_nfactor = atoi(p + 1);
			if (opt_algo == ALGO_SCRYPT_JANE) {
				free(jane_params);
				jane_params = strdup(p+1);
			}
		}
		if (!opt_nfactor) {
			switch (opt_algo) {
			case ALGO_SCRYPT:      opt_nfactor = 9;  break;
			case ALGO_SCRYPT_JANE: opt_nfactor = 14; break;
=======
	if (opt_algo == ALGO_SCRYPT || opt_algo == ALGO_SCRYPT_JANE) 
	{
		printf(scrypt_usage);	
	}
	proper_exit(0);
}

static void parse_arg(int key, char *arg)
{
	char *p = arg;
	int v, i;
	double d;
	char *pch;
	int n;
	int last;
	opterr = 1;

	switch(key) {
	case 'C':
		opt_cpumining = true;
		applog(LOG_INFO, "Cpu mining enabled...");
		break;
	case 'a':
		p = strstr(arg, ":"); // optional factor
		if (p) *p = '\0';
		for (i = 0; i < ALGO_COUNT; i++) {
			if (algo_names[i] && !strcasecmp(arg, algo_names[i])) {
				opt_algo = (enum sha_algos)i;
				break;
			}
		}
		if (i == ALGO_COUNT)
			show_usage_and_exit(1);

		if (p) 
		{
			opt_nfactor = atoi(p + 1);
			if (opt_algo == ALGO_SCRYPT_JANE) 
			{
				free(jane_params);
				jane_params = strdup(p + 1);				
			}			
		}
		if (!opt_nfactor) 
		{
			switch (opt_algo) 
			{
				case ALGO_SCRYPT:      opt_nfactor = 9;  break;
				case ALGO_SCRYPT_JANE: opt_nfactor = 14; break;				
>>>>>>> 8c320ca... added xevan
			}
		}
		break;
	case 'b':
		p = strstr(arg, ":");
		if (p) {
			/* ip:port */
			if (p - arg > 0) {
<<<<<<< HEAD
				free(opt_api_bind);
				opt_api_bind = strdup(arg);
				opt_api_bind[p - arg] = '\0';
			}
			opt_api_port = atoi(p + 1);
		}
		else if (arg && strstr(arg, ".")) {
			/* ip only */
			free(opt_api_bind);
			opt_api_bind = strdup(arg);
		}
		else if (arg) {
			/* port or 0 to disable */
			opt_api_port = atoi(arg);
		}
		break;
	case 1030: /* --api-remote */
		if (opt_api_allow) free(opt_api_allow);
		opt_api_allow = strdup("0/0");
		break;
	case 1031: /* --api-allow */
		// --api-allow 0/0 means opened to all, so assume -b 0.0.0.0
		if (!strcmp(arg, "0/0") && !strcmp(opt_api_bind, "127.0.0.1"))
			parse_arg('b', (char*)"0.0.0.0");
		if (opt_api_allow) free(opt_api_allow);
		opt_api_allow = strdup(arg);
		break;
	case 1032: /* --api-groups */
		if (opt_api_groups) free(opt_api_groups);
		opt_api_groups = strdup(arg);
		break;
	case 1033: /* --api-mcast */
		opt_api_mcast = true;
		break;
	case 1034: /* --api-mcast-addr */
		free(opt_api_mcast_addr);
		opt_api_mcast_addr = strdup(arg);
	case 1035: /* --api-mcast-code */
		free(opt_api_mcast_code);
		opt_api_mcast_code = strdup(arg);
		break;
	case 1036: /* --api-mcast-des */
		free(opt_api_mcast_des);
		opt_api_mcast_des = strdup(arg);
		break;
	case 1037: /* --api-mcast-port */
		v = atoi(arg);
		if (v < 1 || v > 65535) // sanity check
			show_usage_and_exit(1);
		opt_api_mcast_port = v;
=======
				free(opt_api_allow);
				opt_api_allow = strdup(arg);
				opt_api_allow[p - arg] = '\0';
			}
			opt_api_listen = atoi(p + 1);
		}
		else if (arg && strstr(arg, ".")) {
			/* ip only */
			free(opt_api_allow);
			opt_api_allow = strdup(arg);
		}
		else if (arg) {
			/* port or 0 to disable */
			opt_api_listen = atoi(arg);
		}
		break;
>>>>>>> 8c320ca... added xevan
	case 'B':
		opt_background = true;
		break;
	case 'c': {
		json_error_t err;
<<<<<<< HEAD
		if (opt_config) {
			json_decref(opt_config);
			opt_config = NULL;
		}
		if (arg && strstr(arg, "://")) {
			opt_config = json_load_url(arg, &err);
		} else {
			opt_config = JSON_LOADF(arg, &err);
		}
		if (!json_is_object(opt_config)) {
			applog(LOG_ERR, "JSON decode of %s failed", arg);
			proper_exit(EXIT_CODE_USAGE);
		}
		break;
	}
	case 'k':
		opt_scratchpad_url = strdup(arg);
		break;
=======
		if (opt_config)
			json_decref(opt_config);
#if JANSSON_VERSION_HEX >= 0x020000
		opt_config = json_load_file(arg, 0, &err);
#else
		opt_config = json_load_file(arg, &err);
#endif
		if (!json_is_object(opt_config)) {
			applog(LOG_ERR, "JSON decode of %s failed", arg);
			proper_exit(1);
		}
		break;
	}
>>>>>>> 8c320ca... added xevan
	case 'i':
		d = atof(arg);
		v = (uint32_t) d;
		if (v < 0 || v > 31)
			show_usage_and_exit(1);
		{
			int n = 0;
			int ngpus = cuda_num_devices();
			uint32_t last = 0;
			char * pch = strtok(arg,",");
			while (pch != NULL) {
				d = atof(pch);
				v = (uint32_t) d;
				if (v > 7) { /* 0 = default */
					if ((d - v) > 0.0) {
						uint32_t adds = (uint32_t)floor((d - v) * (1 << (v - 8))) * 256;
						gpus_intensity[n] = (1 << v) + adds;
						applog(LOG_INFO, "Adding %u threads to intensity %u, %u cuda threads",
							adds, v, gpus_intensity[n]);
					}
					else if (gpus_intensity[n] != (1 << v)) {
						gpus_intensity[n] = (1 << v);
<<<<<<< HEAD
=======
						applog(LOG_INFO, "Intensity set to %u, %u cuda threads",
							v, gpus_intensity[n]);
>>>>>>> 8c320ca... added xevan
					}
				}
				last = gpus_intensity[n];
				n++;
				pch = strtok(NULL, ",");
			}
			while (n < MAX_GPUS)
				gpus_intensity[n++] = last;
		}
		break;
<<<<<<< HEAD
	case 'D':
		opt_debug = true;
=======
	case 'X':
		v = atoi(arg);
		if (v < 0 || v > 999)
			show_usage_and_exit(1);
		{
			int n = 0;
			int ngpus = cuda_num_devices();
			uint32_t last = 0;
			char * pch = strtok(arg,",");
			while (pch != NULL) {
				d = atof(pch);
				v = (uint32_t) d;
					if ((d - v) > 0) {
						uint32_t adds = (v*256*256);
						gpus_intensity[n] = (1 << v) + adds;
						applog(LOG_INFO, "Adding %u threads to Xintensity %u, %u cuda threads",
							adds, v, gpus_intensity[n]);
					}
					else if (gpus_intensity[n] != (1 << v)) {
						gpus_intensity[n] = (v*256*256);
						applog(LOG_INFO, "XIntensity set to %u, %u cuda threads",
							v, gpus_intensity[n]);
					}
				last = gpus_intensity[n];
				n++;
				pch = strtok(NULL, ",");
			}
			while (n < MAX_GPUS)
				gpus_intensity[n++] = last;
		}
		break;
	case 'n': /* --ndevs */
		cuda_print_devices();
		proper_exit(0);
>>>>>>> 8c320ca... added xevan
		break;
	case 'N':
		v = atoi(arg);
		if (v < 1)
			opt_statsavg = INT_MAX;
		opt_statsavg = v;
		break;
<<<<<<< HEAD
	case 'n': /* --ndevs */
		// to get gpu vendors...
		#ifdef USE_WRAPNVML
		hnvml = nvml_create();
		#ifdef WIN32
		nvapi_init();
		cuda_devicenames(); // req for leds
		nvapi_init_settings();
		#endif
		#endif
		cuda_print_devices();
		proper_exit(EXIT_CODE_OK);
		break;
=======
>>>>>>> 8c320ca... added xevan
	case 'q':
		opt_quiet = true;
		break;
	case 'p':
		free(rpc_pass);
		rpc_pass = strdup(arg);
<<<<<<< HEAD
		pool_set_creds(cur_pooln);
=======
>>>>>>> 8c320ca... added xevan
		break;
	case 'P':
		opt_protocol = true;
		break;
	case 'r':
		v = atoi(arg);
		if (v < -1 || v > 9999)	/* sanity check */
			show_usage_and_exit(1);
		opt_retries = v;
		break;
	case 'R':
		v = atoi(arg);
		if (v < 1 || v > 9999)	/* sanity check */
			show_usage_and_exit(1);
		opt_fail_pause = v;
		break;
	case 's':
		v = atoi(arg);
		if (v < 1 || v > 9999)	/* sanity check */
			show_usage_and_exit(1);
		opt_scantime = v;
		break;
	case 'T':
		v = atoi(arg);
		if (v < 1 || v > 99999)	/* sanity check */
			show_usage_and_exit(1);
		opt_timeout = v;
		break;
	case 't':
		v = atoi(arg);
<<<<<<< HEAD
		if (v < 0 || v > 9999)	/* sanity check */
			show_usage_and_exit(1);
		opt_n_threads = v;
		break;
	case 1022: // --vote
=======
		if (v < 1 || v > 9999)	/* sanity check */
			show_usage_and_exit(1);
		opt_n_threads = v;
		break;
	case 'v':
>>>>>>> 8c320ca... added xevan
		v = atoi(arg);
		if (v < 0 || v > 8192)	/* sanity check */
			show_usage_and_exit(1);
		opt_vote = (uint16_t)v;
		break;
<<<<<<< HEAD
	case 1023: // --trust-pool
=======
	case 'm':
>>>>>>> 8c320ca... added xevan
		opt_trust_pool = true;
		break;
	case 'u':
		free(rpc_user);
		rpc_user = strdup(arg);
<<<<<<< HEAD
		pool_set_creds(cur_pooln);
		break;
	case 'o':			/* --url */
		if (pools[cur_pooln].type != POOL_UNUSED) {
			// rotate pool pointer
			cur_pooln = (cur_pooln + 1) % MAX_POOLS;
			num_pools = max(cur_pooln+1, num_pools);
			// change some defaults if multi pools
			if (opt_retries == -1) opt_retries = 1;
			if (opt_fail_pause == 30) opt_fail_pause = 5;
			if (opt_timeout == 300) opt_timeout = 60;
		}
=======
		break;
	case 'o':			/* --url */
>>>>>>> 8c320ca... added xevan
		p = strstr(arg, "://");
		if (p) {
			if (strncasecmp(arg, "http://", 7) && strncasecmp(arg, "https://", 8) &&
					strncasecmp(arg, "stratum+tcp://", 14))
				show_usage_and_exit(1);
			free(rpc_url);
			rpc_url = strdup(arg);
			short_url = &rpc_url[(p - arg) + 3];
		} else {
			if (!strlen(arg) || *arg == '/')
				show_usage_and_exit(1);
			free(rpc_url);
			rpc_url = (char*)malloc(strlen(arg) + 8);
			sprintf(rpc_url, "http://%s", arg);
			short_url = &rpc_url[7];
		}
		p = strrchr(rpc_url, '@');
		if (p) {
			char *sp, *ap;
			*p = '\0';
			ap = strstr(rpc_url, "://") + 3;
			sp = strchr(ap, ':');
<<<<<<< HEAD
			if (sp && sp < p) {
=======
			if (sp) {
				free(rpc_userpass);
				rpc_userpass = strdup(ap);
>>>>>>> 8c320ca... added xevan
				free(rpc_user);
				rpc_user = (char*)calloc(sp - ap + 1, 1);
				strncpy(rpc_user, ap, sp - ap);
				free(rpc_pass);
				rpc_pass = strdup(sp + 1);
			} else {
<<<<<<< HEAD
				free(rpc_user);
				rpc_user = strdup(ap);
			}
			// remove user[:pass]@ from rpc_url
			memmove(ap, p + 1, strlen(p + 1) + 1);
			// host:port only
			short_url = ap;
		}
		have_stratum = !opt_benchmark && !strncasecmp(rpc_url, "stratum", 7);
		pool_set_creds(cur_pooln);
		break;
	case 'O':			/* --userpass */
		p = strchr(arg, ':');
		if (!p)
			show_usage_and_exit(1);
		free(rpc_user);
		rpc_user = (char*)calloc(p - arg + 1, 1);
		strncpy(rpc_user, arg, p - arg);
		free(rpc_pass);
		rpc_pass = strdup(p + 1);
		pool_set_creds(cur_pooln);
		break;
	case 'x':			/* --proxy */
		if (!strncasecmp(arg, "socks4://", 9))
			opt_proxy_type = CURLPROXY_SOCKS4;
		else if (!strncasecmp(arg, "socks5://", 9))
			opt_proxy_type = CURLPROXY_SOCKS5;
#if LIBCURL_VERSION_NUM >= 0x071200
		else if (!strncasecmp(arg, "socks4a://", 10))
			opt_proxy_type = CURLPROXY_SOCKS4A;
		else if (!strncasecmp(arg, "socks5h://", 10))
			opt_proxy_type = CURLPROXY_SOCKS5_HOSTNAME;
#endif
		else
			opt_proxy_type = CURLPROXY_HTTP;
		free(opt_proxy);
		opt_proxy = strdup(arg);
		pool_set_creds(cur_pooln);
		break;
	case 1001:
		free(opt_cert);
		opt_cert = strdup(arg);
		break;
	case 1002:
		use_colors = false;
		break;
	case 1004:
		opt_autotune = false;
		break;
	case 'l': /* --launch-config */
		{
			char *last = NULL, *pch = strtok(arg,",");
			int n = 0;
			while (pch != NULL) {
				device_config[n++] = last = strdup(pch);
				pch = strtok(NULL, ",");
			}
			while (n < MAX_GPUS)
				device_config[n++] = last;
		}
		break;
	case 'L': /* scrypt --lookup-gap */
		{
			char *pch = strtok(arg,",");
			int n = 0, last = atoi(arg);
			while (pch != NULL) {
				device_lookup_gap[n++] = last = atoi(pch);
				pch = strtok(NULL, ",");
			}
			while (n < MAX_GPUS)
				device_lookup_gap[n++] = last;
		}
		break;
	case 1050: /* scrypt --interactive */
		{
			char *pch = strtok(arg,",");
			int n = 0, last = atoi(arg);
			while (pch != NULL) {
				device_interactive[n++] = last = atoi(pch);
				pch = strtok(NULL, ",");
			}
			while (n < MAX_GPUS)
				device_interactive[n++] = last;
		}
		break;
	case 1051: /* scrypt --texture-cache */
		{
			char *pch = strtok(arg,",");
			int n = 0, last = atoi(arg);
			while (pch != NULL) {
				device_texturecache[n++] = last = atoi(pch);
				pch = strtok(NULL, ",");
			}
			while (n < MAX_GPUS)
				device_texturecache[n++] = last;
		}
		break;
	case 1055: /* cryptonight --bfactor */
		{
			char *pch = strtok(arg, ",");
			int n = 0, last = atoi(arg);
			while (pch != NULL) {
				last = atoi(pch);
				if (last > 15) last = 15;
				device_bfactor[n++] = last;
				pch = strtok(NULL, ",");
			}
			while (n < MAX_GPUS)
				device_bfactor[n++] = last;
		}
		break;
	case 1070: /* --gpu-clock */
		{
			char *pch = strtok(arg,",");
			int n = 0;
			while (pch != NULL && n < MAX_GPUS) {
				int dev_id = device_map[n++];
				device_gpu_clocks[dev_id] = atoi(pch);
				pch = strtok(NULL, ",");
			}
		}
		break;
	case 1071: /* --mem-clock */
		{
			char *pch = strtok(arg,",");
			int n = 0;
			while (pch != NULL && n < MAX_GPUS) {
				int dev_id = device_map[n++];
				if (*pch == '+' || *pch == '-')
					device_mem_offsets[dev_id] = atoi(pch);
				else
					device_mem_clocks[dev_id] = atoi(pch);
				need_nvsettings = true;
				pch = strtok(NULL, ",");
			}
		}
		break;
	case 1072: /* --pstate */
		{
			char *pch = strtok(arg,",");
			int n = 0;
			while (pch != NULL && n < MAX_GPUS) {
				int dev_id = device_map[n++];
				device_pstate[dev_id] = (int8_t) atoi(pch);
				pch = strtok(NULL, ",");
			}
		}
		break;
	case 1073: /* --plimit */
		{
			char *pch = strtok(arg,",");
			int n = 0;
			while (pch != NULL && n < MAX_GPUS) {
				int dev_id = device_map[n++];
				device_plimit[dev_id] = atoi(pch);
				pch = strtok(NULL, ",");
			}
		}
		break;
	case 1074: /* --keep-clocks */
		opt_keep_clocks = true;
		break;
	case 1075: /* --tlimit */
		{
			char *pch = strtok(arg,",");
			int n = 0;
			while (pch != NULL && n < MAX_GPUS) {
				int dev_id = device_map[n++];
				device_tlimit[dev_id] = (uint8_t) atoi(pch);
				pch = strtok(NULL, ",");
			}
		}
		break;
	case 1080: /* --led */
		{
			if (!opt_led_mode)
				opt_led_mode = LED_MODE_SHARES;
			char *pch = strtok(arg,",");
			int n = 0, lastval, val;
			while (pch != NULL && n < MAX_GPUS) {
				int dev_id = device_map[n++];
				char * p = strstr(pch, "0x");
				val = p ? (int32_t) strtoul(p, NULL, 16) : atoi(pch);
				if (!val && !strcmp(pch, "mining"))
					opt_led_mode = LED_MODE_MINING;
				else if (device_led[dev_id] == -1)
					device_led[dev_id] = lastval = val;
				pch = strtok(NULL, ",");
			}
			if (lastval) while (n < MAX_GPUS) {
				device_led[n++] = lastval;
			}
=======
				free(rpc_user);
				rpc_user = strdup(ap);
			}
			memmove(ap, p + 1, strlen(p + 1) + 1);
			short_url = p + 1;
		}
		have_stratum = !opt_benchmark && !strncasecmp(rpc_url, "stratum", 7);
		break;
	case 'O':			/* --userpass */
		p = strchr(arg, ':');
		if (!p)
			show_usage_and_exit(1);
		free(rpc_userpass);
		rpc_userpass = strdup(arg);
		free(rpc_user);
		rpc_user = (char*)calloc(p - arg + 1, 1);
		strncpy(rpc_user, arg, p - arg);
		free(rpc_pass);
		rpc_pass = strdup(p + 1);
		break;
	case 'x':			/* --proxy */
		if (!strncasecmp(arg, "socks4://", 9))
			opt_proxy_type = CURLPROXY_SOCKS4;
		else if (!strncasecmp(arg, "socks5://", 9))
			opt_proxy_type = CURLPROXY_SOCKS5;
#if LIBCURL_VERSION_NUM >= 0x071200
		else if (!strncasecmp(arg, "socks4a://", 10))
			opt_proxy_type = CURLPROXY_SOCKS4A;
		else if (!strncasecmp(arg, "socks5h://", 10))
			opt_proxy_type = CURLPROXY_SOCKS5_HOSTNAME;
#endif
		else
			opt_proxy_type = CURLPROXY_HTTP;
		free(opt_proxy);
		opt_proxy = strdup(arg);
		break;
	case 1001:
		free(opt_cert);
		opt_cert = strdup(arg);
		break;
	case 1002:
		use_colors = false;
		break;
	case 1004:
		opt_autotune = false;
		break;
		case 'l': /* scrypt --launch-config */
		{
				char *last = NULL, *pch = strtok(arg, ",");
				int n = 0;
				while (pch != NULL) {
					device_config[n++] = last = strdup(pch);
					pch = strtok(NULL, ",");
					
				}
				while (n < MAX_GPUS)
				device_config[n++] = last;
		}
		break;
		case 'L': /* scrypt --lookup-gap */
		{
			char *pch = strtok(arg, ",");
			int n = 0, last = 0;
			while (pch != NULL) 
			{
				device_lookup_gap[n++] = last = atoi(pch);
				pch = strtok(NULL, ",");				
			}
			while (n < MAX_GPUS)
				 device_lookup_gap[n++] = last;
>>>>>>> 8c320ca... added xevan
		}
		break;
	case 1005:
		opt_benchmark = true;
		want_longpoll = false;
		want_stratum = false;
		have_stratum = false;
		break;
	case 1006:
		print_hash_tests();
<<<<<<< HEAD
		proper_exit(EXIT_CODE_OK);
=======
		proper_exit(0);
>>>>>>> 8c320ca... added xevan
		break;
	case 1003:
		want_longpoll = false;
		break;
	case 1007:
		want_stratum = false;
<<<<<<< HEAD
		opt_extranonce = false;
=======
>>>>>>> 8c320ca... added xevan
		break;
	case 1008:
		opt_time_limit = atoi(arg);
		break;
<<<<<<< HEAD
	case 1009:
		opt_shares_limit = atoi(arg);
		break;
	case 1011:
		allow_gbt = false;
		break;
	case 1012:
		opt_extranonce = false;
		break;
	case 1013:
		opt_showdiff = true;
		break;
	case 1014:
		opt_showdiff = false;
		break;
=======
	case 1011:
		allow_gbt = false;
		break;
>>>>>>> 8c320ca... added xevan
	case 'S':
	case 1018:
		applog(LOG_INFO, "Now logging to syslog...");
		use_syslog = true;
		if (arg && strlen(arg)) {
			free(opt_syslog_pfx);
			opt_syslog_pfx = strdup(arg);
		}
		break;
<<<<<<< HEAD
	case 1019: // max-log-rate
		opt_maxlograte = atoi(arg);
		break;
	case 1020:
		p = strstr(arg, "0x");
		ul = p ? strtoul(p, NULL, 16) : atol(arg);
		if (ul > (1UL<<num_cpus)-1)
			ul = -1L;
		opt_affinity = ul;
=======
	case 1020:
		v = atoi(arg);
		if (v < -1)
			v = -1;
		if (v > (1<<num_cpus)-1)
			v = -1;
		opt_affinity = v;
>>>>>>> 8c320ca... added xevan
		break;
	case 1021:
		v = atoi(arg);
		if (v < 0 || v > 5)	/* sanity check */
			show_usage_and_exit(1);
		opt_priority = v;
		break;
<<<<<<< HEAD
	case 1025: // cuda-schedule
		opt_cudaschedule = atoi(arg);
		break;
	case 1060: // max-temp
		d = atof(arg);
		opt_max_temp = d;
		break;
	case 1061: // max-diff
		d = atof(arg);
		opt_max_diff = d;
		break;
	case 1062: // max-rate
		d = atof(arg);
		p = strstr(arg, "K");
		if (p) d *= 1e3;
		p = strstr(arg, "M");
		if (p) d *= 1e6;
		p = strstr(arg, "G");
		if (p) d *= 1e9;
		opt_max_rate = d;
		break;
	case 1063: // resume-diff
		d = atof(arg);
		opt_resume_diff = d;
		break;
	case 1064: // resume-rate
		d = atof(arg);
		p = strstr(arg, "K");
		if (p) d *= 1e3;
		p = strstr(arg, "M");
		if (p) d *= 1e6;
		p = strstr(arg, "G");
		if (p) d *= 1e9;
		opt_resume_rate = d;
		break;
	case 1065: // resume-temp
		d = atof(arg);
		opt_resume_temp = d;
		break;
	case 'd': // --device
		{
			int device_thr[MAX_GPUS] = { 0 };
			int ngpus = cuda_num_devices();
			char * pch = strtok (arg,",");
			opt_n_threads = 0;
			while (pch != NULL && opt_n_threads < MAX_GPUS) {
=======
	case 'd': // CB
		{
			int ngpus = cuda_num_devices();
			char * pch = strtok (arg,",");
			opt_n_threads = 0;
			while (pch != NULL) {
>>>>>>> 8c320ca... added xevan
				if (pch[0] >= '0' && pch[0] <= '9' && pch[1] == '\0')
				{
					if (atoi(pch) < ngpus)
						device_map[opt_n_threads++] = atoi(pch);
					else {
						applog(LOG_ERR, "Non-existant CUDA device #%d specified in -d option", atoi(pch));
<<<<<<< HEAD
						proper_exit(EXIT_CODE_CUDA_NODEVICE);
=======
						proper_exit(1);
>>>>>>> 8c320ca... added xevan
					}
				} else {
					int device = cuda_finddevice(pch);
					if (device >= 0 && device < ngpus)
						device_map[opt_n_threads++] = device;
					else {
						applog(LOG_ERR, "Non-existant CUDA device '%s' specified in -d option", pch);
<<<<<<< HEAD
						proper_exit(EXIT_CODE_CUDA_NODEVICE);
					}
				}
				pch = strtok (NULL, ",");
			}
			// count threads per gpu
			for (int n=0; n < opt_n_threads; n++) {
				int device = device_map[n];
				device_thr[device]++;
			}
			for (int n=0; n < ngpus; n++) {
				gpu_threads = max(gpu_threads, device_thr[n]);
			}
		}
		break;

	case 'f': // --diff-factor
		d = atof(arg);
		if (d <= 0.)
			show_usage_and_exit(1);
		opt_difficulty = d;
		break;
	case 'm': // --diff-multiplier
		d = atof(arg);
		if (d <= 0.)
			show_usage_and_exit(1);
		opt_difficulty = 1.0/d;
		break;

	/* PER POOL CONFIG OPTIONS */

	case 1100: /* pool name */
		pool_set_attr(cur_pooln, "name", arg);
		break;
	case 1101: /* pool algo */
		pool_set_attr(cur_pooln, "algo", arg);
		break;
	case 1102: /* pool scantime */
		pool_set_attr(cur_pooln, "scantime", arg);
		break;
	case 1108: /* pool time-limit */
		pool_set_attr(cur_pooln, "time-limit", arg);
		break;
	case 1109: /* pool shares-limit (1.7.6) */
		pool_set_attr(cur_pooln, "shares-limit", arg);
		break;
	case 1161: /* pool max-diff */
		pool_set_attr(cur_pooln, "max-diff", arg);
		break;
	case 1162: /* pool max-rate */
		pool_set_attr(cur_pooln, "max-rate", arg);
		break;
	case 1199:
		pool_set_attr(cur_pooln, "disabled", arg);
		break;

=======
						proper_exit(1);
					}
				}
				// set number of active gpus
				active_gpus = opt_n_threads;
				pch = strtok (NULL, ",");
			}
		}
		break;
	case 'f': // CH - Divisor for Difficulty
		d = atof(arg);
		if (d == 0)	/* sanity check */
			show_usage_and_exit(1);
		opt_difficulty = d;
		break;

	case 'e':
		opt_extranonce = false;
		break;
	case 1070:
		pch = strtok(arg, ",");
		n = 0, last = atoi(arg);
		while (pch != NULL)
		{
			device_gpuspeed[n++] = last = atoi(pch);
			pch = strtok(NULL, ",");
		}
		break;
	case 1071:
		pch = strtok(arg, ",");
		n = 0, last = atoi(arg);
		while (pch != NULL) 
		{
			device_memspeed[n++] = last = atoi(pch);
			pch = strtok(NULL, ",");		
		}
		break;
	case 'g':
		v = atoi(arg);
		if (v < 1 || v > 9999)	/* sanity check */
			show_usage_and_exit(1);
		opt_n_gputhreads = v;

		int buf[MAX_GPUS];
		for (int i = 0; i < active_gpus; i++)
		{
			buf[i] = device_map[i];
		}
		for (int i = 0; i < active_gpus; i++)
		{
			for (int j = 0; j<opt_n_gputhreads; j++)
			{
				device_map[(i * opt_n_gputhreads) + j] = buf[i];
			}
		}
		opt_n_threads = active_gpus*opt_n_gputhreads;
		active_gpus= opt_n_threads;
		opt_extranonce = false;
		break;
	case 1030:
		opt_broken_neo_wallet = true;
		break;
	case 'D':
		opt_debug = true;
		break;
>>>>>>> 8c320ca... added xevan
	case 'V':
		show_version_and_exit();
	case 'h':
		show_usage_and_exit(0);
	default:
		show_usage_and_exit(1);
	}

	if (use_syslog)
		use_colors = false;
}

<<<<<<< HEAD
void parse_config(json_t* json_obj)
=======

/**
 * Parse json config file
 */
static void parse_config(void)
>>>>>>> 8c320ca... added xevan
{
	int i;
	json_t *val;

<<<<<<< HEAD
	if (!json_is_object(json_obj))
=======
	if (!json_is_object(opt_config))
>>>>>>> 8c320ca... added xevan
		return;

	for (i = 0; i < ARRAY_SIZE(options); i++) {

		if (!options[i].name)
			break;
<<<<<<< HEAD

		if (!strcasecmp(options[i].name, "config"))
			continue;

		val = json_object_get(json_obj, options[i].name);
=======
		if (!strcmp(options[i].name, "config"))
			continue;

		val = json_object_get(opt_config, options[i].name);
>>>>>>> 8c320ca... added xevan
		if (!val)
			continue;

		if (options[i].has_arg && json_is_string(val)) {
			char *s = strdup(json_string_value(val));
			if (!s)
				continue;
			parse_arg(options[i].val, s);
			free(s);
		}
		else if (options[i].has_arg && json_is_integer(val)) {
			char buf[16];
			sprintf(buf, "%d", (int) json_integer_value(val));
			parse_arg(options[i].val, buf);
		}
		else if (options[i].has_arg && json_is_real(val)) {
			char buf[16];
			sprintf(buf, "%f", json_real_value(val));
			parse_arg(options[i].val, buf);
		}
		else if (!options[i].has_arg) {
			if (json_is_true(val))
				parse_arg(options[i].val, (char*) "");
		}
		else
			applog(LOG_ERR, "JSON option %s invalid",
				options[i].name);
	}
<<<<<<< HEAD

	val = json_object_get(json_obj, "pools");
	if (val && json_typeof(val) == JSON_ARRAY) {
		parse_pool_array(val);
	}
=======
>>>>>>> 8c320ca... added xevan
}

static void parse_cmdline(int argc, char *argv[])
{
	int key;

	while (1) {
#if HAVE_GETOPT_LONG
		key = getopt_long(argc, argv, short_options, options, NULL);
#else
		key = getopt(argc, argv, short_options);
#endif
		if (key < 0)
			break;

		parse_arg(key, optarg);
	}
	if (optind < argc) {
<<<<<<< HEAD
		fprintf(stderr, "%s: unsupported non-option argument '%s' (see --help)\n",
			argv[0], argv[optind]);
		//show_usage_and_exit(1);
	}

	parse_config(opt_config);

	if (opt_algo == ALGO_HEAVY && opt_vote == 9999 && !opt_benchmark) {
=======
		fprintf(stderr, "%s: unsupported non-option argument '%s'\n",
			argv[0], argv[optind]);
		show_usage_and_exit(1);
	}

	parse_config();

	if (opt_algo == ALGO_HEAVY && opt_vote == 9999) {
>>>>>>> 8c320ca... added xevan
		fprintf(stderr, "%s: Heavycoin hash requires block reward vote parameter (see --vote)\n",
			argv[0]);
		show_usage_and_exit(1);
	}
<<<<<<< HEAD

	if (opt_vote == 9999) {
		opt_vote = 0; // default, don't vote
	}
}

static void parse_single_opt(int opt, int argc, char *argv[])
{
	int key, prev = optind;
	while (1) {
#if HAVE_GETOPT_LONG
		key = getopt_long(argc, argv, short_options, options, NULL);
#else
		key = getopt(argc, argv, short_options);
#endif
		if (key < 0)
			break;
		if (key == opt /* || key == 'c'*/)
			parse_arg(key, optarg);
	}
	//todo with a filter: parse_config(opt_config);

	optind = prev; // reset argv index
}

#ifndef WIN32
=======
}

#ifndef WIN32
static void signal_handler2(int sig)
{
	switch (sig) {
	case SIGINT:
		signal(sig, SIG_IGN);
		applog(LOG_INFO, "SIGINT received, aborting miner jobs");
                scan_abort_flag = true;
		break;
	}
}
>>>>>>> 8c320ca... added xevan
static void signal_handler(int sig)
{
	switch (sig) {
	case SIGHUP:
		applog(LOG_INFO, "SIGHUP received");
		break;
	case SIGINT:
<<<<<<< HEAD
		signal(sig, SIG_IGN);
		applog(LOG_INFO, "SIGINT received, exiting");
		proper_exit(EXIT_CODE_KILLED);
		break;
	case SIGTERM:
		applog(LOG_INFO, "SIGTERM received, exiting");
		proper_exit(EXIT_CODE_KILLED);
=======
		signal(sig, signal_handler2);
		applog(LOG_INFO, "SIGINT received, exiting once miner jobs complete.  Ctrl+C again to abort miner jobs");
		proper_exit(CCEXIT_SIG);
		break;
	case SIGTERM:
		scan_abort_flag = true;
		applog(LOG_INFO, "SIGTERM received, exiting");
		proper_exit(CCEXIT_SIG);
>>>>>>> 8c320ca... added xevan
		break;
	}
}
#else
BOOL WINAPI ConsoleHandler(DWORD dwType)
{
	switch (dwType) {
	case CTRL_C_EVENT:
<<<<<<< HEAD
		applog(LOG_INFO, "CTRL_C_EVENT received, exiting");
		proper_exit(EXIT_CODE_KILLED);
		break;
	case CTRL_BREAK_EVENT:
		applog(LOG_INFO, "CTRL_BREAK_EVENT received, exiting");
		proper_exit(EXIT_CODE_KILLED);
		break;
	case CTRL_LOGOFF_EVENT:
		applog(LOG_INFO, "CTRL_LOGOFF_EVENT received, exiting");
		proper_exit(EXIT_CODE_KILLED);
		break;
	case CTRL_SHUTDOWN_EVENT:
		applog(LOG_INFO, "CTRL_SHUTDOWN_EVENT received, exiting");
		proper_exit(EXIT_CODE_KILLED);
=======
	{
		static bool called = false;
		if (!called) {
			called = true;
			applog(LOG_INFO, "CTRL_C_EVENT received, exiting once miner jobs complete.  Ctrl+C again to abort miner jobs");
			proper_exit(CCEXIT_SIG);
		} else {
			applog(LOG_INFO, "CTRL_C_EVENT received, aborting miner jobs");
			scan_abort_flag = true;
		}


		break;
	}
	case CTRL_BREAK_EVENT:
		applog(LOG_INFO, "CTRL_BREAK_EVENT received, exiting");
		proper_exit(CCEXIT_SIG);
>>>>>>> 8c320ca... added xevan
		break;
	default:
		return false;
	}
	return true;
}
#endif

int main(int argc, char *argv[])
{
	struct thr_info *thr;
	long flags;
	int i;
<<<<<<< HEAD

	// get opt_quiet early
	parse_single_opt('q', argc, argv);

	printf("*** ccminer " PACKAGE_VERSION " for nVidia GPUs by tpruvot@github ***\n");
	if (!opt_quiet) {
		const char* arch = is_x64() ? "64-bits" : "32-bits";
#ifdef _MSC_VER
		printf("    Built with VC++ %d and nVidia CUDA SDK %d.%d %s\n\n", msver(),
#else
		printf("    Built with the nVidia CUDA Toolkit %d.%d %s\n\n",
#endif
			CUDART_VERSION/1000, (CUDART_VERSION % 1000)/10, arch);
		printf("  Originally based on Christian Buchner and Christian H. project\n");
		printf("  Include some algos from alexis78, djm34, sp, tsiv and klausT.\n\n");
		printf("BTC donation address: 1AJdfCpLWPNoAMDfHF1wD5y8VgKSSTHxPo (tpruvot)\n\n");
	}

	rpc_user = strdup("");
	rpc_pass = strdup("");
	rpc_url = strdup("");
	jane_params = strdup("");

	pthread_mutex_init(&applog_lock, NULL);
	pthread_mutex_init(&stratum_sock_lock, NULL);
	pthread_mutex_init(&stratum_work_lock, NULL);
	pthread_mutex_init(&stats_lock, NULL);
	pthread_mutex_init(&g_work_lock, NULL);

=======
	
	// strdup on char* to allow a common free() if used
	opt_syslog_pfx = strdup(PROGRAM_NAME);
	opt_api_allow = strdup("127.0.0.1"); /* 0.0.0.0 for all ips */

	printf("SP-Mod 1.5.81 \n");
#ifdef _MSC_VER
	printf("Compiled with Visual C++ %d ", _MSC_VER / 100);
#else
#ifdef __clang__
	printf("Compiled with Clang %s ", __clang_version__);
#else
#ifdef __GNUC__
	printf("Compiled with GCC %d.%d ", __GNUC__, __GNUC_MINOR__);
#else
	printf("Compiled with an unknown compiler ");
#endif
#endif
#endif
	printf("using Nvidia CUDA Toolkit %d.%d\n\n", CUDART_VERSION / 1000, (CUDART_VERSION % 1000) / 10);
	printf("  Based on pooler cpuminer 2.3.2 and the tpruvot@github fork\n");
	printf("  CUDA support by Christian Buchner, Christian H. and DJM34\n");
	printf("  Includes optimizations implemented by sp, klaust, tpruvot and tsiv.\n\n");

	rpc_user = strdup("");
	rpc_pass = strdup("");
	jane_params = strdup("");

>>>>>>> 8c320ca... added xevan
	// number of cpus for thread affinity
#if defined(WIN32)
	SYSTEM_INFO sysinfo;
	GetSystemInfo(&sysinfo);
	num_cpus = sysinfo.dwNumberOfProcessors;
#elif defined(_SC_NPROCESSORS_CONF)
	num_cpus = sysconf(_SC_NPROCESSORS_CONF);
#elif defined(CTL_HW) && defined(HW_NCPU)
	int req[] = { CTL_HW, HW_NCPU };
	size_t len = sizeof(num_cpus);
<<<<<<< HEAD
	sysctl(req, 2, &num_cpus, &len, NULL, 0);
#else
	num_cpus = 1;
#endif
	if (num_cpus < 1)
		num_cpus = 1;

	// number of gpus
	active_gpus = cuda_num_devices();

	for (i = 0; i < MAX_GPUS; i++) {
		device_map[i] = i % active_gpus;
		device_name[i] = NULL;
		device_config[i] = NULL;
		device_backoff[i] = is_windows() ? 12 : 2;
		device_bfactor[i] = is_windows() ? 11 : 0;
		device_lookup_gap[i] = 1;
		device_batchsize[i] = 1024;
		device_interactive[i] = -1;
		device_texturecache[i] = -1;
		device_singlememory[i] = -1;
		device_pstate[i] = -1;
		device_led[i] = -1;
=======
	sysc tl(req, 2, &num_cpus, &len, NULL, 0);
#else
	num_cpus = 1;
#endif
	// number of gpus
	active_gpus = cuda_num_devices();


	if (active_gpus > 1)
	{
		// default thread to device map
		for (i = 0; i < MAX_GPUS; i++)
		{
			device_map[i] = i;
			device_name[i] = NULL;
					// for future use, maybe
			device_interactive[i] = -1;
			device_batchsize[i] = 1024;
			device_backoff[i] = is_windows() ? 12 : 2;
			device_lookup_gap[i] = 1;
			device_texturecache[i] = -1;
			device_singlememory[i] = -1;
			device_config[i] = NULL;
		}
>>>>>>> 8c320ca... added xevan
	}

	cuda_devicenames();

	/* parse command line */
	parse_cmdline(argc, argv);
<<<<<<< HEAD

	if (!opt_benchmark && !strlen(rpc_url)) {
		// try default config file (user then binary folder)
		char defconfig[MAX_PATH] = { 0 };
		get_defconfig_path(defconfig, MAX_PATH, argv[0]);
		if (strlen(defconfig)) {
			if (opt_debug)
				applog(LOG_DEBUG, "Using config %s", defconfig);
			parse_arg('c', defconfig);
			parse_cmdline(argc, argv);
		}
	}

	if (!strlen(rpc_url)) {
		if (!opt_benchmark) {
			fprintf(stderr, "%s: no URL supplied\n", argv[0]);
			show_usage_and_exit(1);
		}
		// ensure a pool is set with default params...
		pool_set_creds(0);
	}

	/* init stratum data.. */
	memset(&stratum.url, 0, sizeof(stratum));

	// ensure default params are set
	pool_init_defaults();

	if (opt_debug)
		pool_dump_infos();
	cur_pooln = pool_get_first_valid(0);
	pool_switch(-1, cur_pooln);

	if (opt_algo == ALGO_DECRED || opt_algo == ALGO_SIA) {
		allow_gbt = false;
		allow_mininginfo = false;
	}

	if (opt_algo == ALGO_EQUIHASH) {
		opt_extranonce = false; // disable subscribe
	}

	if (opt_algo == ALGO_CRYPTONIGHT || opt_algo == ALGO_CRYPTOLIGHT) {
		rpc2_init();
		if (!opt_quiet) applog(LOG_INFO, "Using JSON-RPC 2.0");
	}

	if (opt_algo == ALGO_WILDKECCAK) {
		rpc2_init();
		if (!opt_quiet) applog(LOG_INFO, "Using JSON-RPC 2.0");
		GetScratchpad();
	}

	flags = !opt_benchmark && strncmp(rpc_url, "https:", 6)
=======
	if (abort_flag) return 0;

	if (!opt_benchmark && !rpc_url) {
		fprintf(stderr, "%s: no URL supplied\n", argv[0]);
		show_usage_and_exit(1);
	}
		
	if (!rpc_userpass) {
		rpc_userpass = (char*)malloc(strlen(rpc_user) + strlen(rpc_pass) + 2);
		if (!rpc_userpass)
			return 1;
		sprintf(rpc_userpass, "%s:%s", rpc_user, rpc_pass);
	}


	cuda_devicereset();

	/* init stratum data.. */
	memset(&stratum.url, 0, sizeof(stratum));

	pthread_mutex_init(&stratum.sock_lock, NULL);
	pthread_mutex_init(&stratum.work_lock, NULL);

	flags = !opt_benchmark && rpc_url && strncmp(rpc_url, "https:", 6)
>>>>>>> 8c320ca... added xevan
	      ? (CURL_GLOBAL_ALL & ~CURL_GLOBAL_SSL)
	      : CURL_GLOBAL_ALL;
	if (curl_global_init(flags)) {
		applog(LOG_ERR, "CURL initialization failed");
<<<<<<< HEAD
		return EXIT_CODE_SW_INIT_ERROR;
	}

	if (opt_background) {
#ifndef WIN32
		i = fork();
		if (i < 0) proper_exit(EXIT_CODE_SW_INIT_ERROR);
		if (i > 0) proper_exit(EXIT_CODE_OK);
=======
		return 1;
	}

#ifndef WIN32
	if (opt_background) {
		i = fork();
		if (i < 0) exit(1);
		if (i > 0) exit(0);
>>>>>>> 8c320ca... added xevan
		i = setsid();
		if (i < 0)
			applog(LOG_ERR, "setsid() failed (errno = %d)", errno);
		i = chdir("/");
		if (i < 0)
			applog(LOG_ERR, "chdir() failed (errno = %d)", errno);
		signal(SIGHUP, signal_handler);
		signal(SIGTERM, signal_handler);
<<<<<<< HEAD
#else
		HWND hcon = GetConsoleWindow();
		if (hcon) {
			// this method also hide parent command line window
			ShowWindow(hcon, SW_HIDE);
		} else {
			HANDLE h = GetStdHandle(STD_OUTPUT_HANDLE);
			CloseHandle(h);
			FreeConsole();
		}
#endif
	}

#ifndef WIN32
=======
	}
>>>>>>> 8c320ca... added xevan
	/* Always catch Ctrl+C */
	signal(SIGINT, signal_handler);
#else
	SetConsoleCtrlHandler((PHANDLER_ROUTINE)ConsoleHandler, TRUE);
<<<<<<< HEAD
	if (opt_priority > 0) {
		DWORD prio = NORMAL_PRIORITY_CLASS;
=======
	if (opt_priority > 0)
	{
		DWORD prio = NORMAL_PRIORITY_CLASS;
		prio = REALTIME_PRIORITY_CLASS;//default realtime

>>>>>>> 8c320ca... added xevan
		switch (opt_priority) {
		case 1:
			prio = BELOW_NORMAL_PRIORITY_CLASS;
			break;
<<<<<<< HEAD
		case 2:
			prio = NORMAL_PRIORITY_CLASS;
			break;
=======
>>>>>>> 8c320ca... added xevan
		case 3:
			prio = ABOVE_NORMAL_PRIORITY_CLASS;
			break;
		case 4:
			prio = HIGH_PRIORITY_CLASS;
			break;
		case 5:
			prio = REALTIME_PRIORITY_CLASS;
		}
<<<<<<< HEAD
		SetPriorityClass(GetCurrentProcess(), prio);
	}
	// Prevent windows to sleep while mining
	SetThreadExecutionState(ES_CONTINUOUS | ES_SYSTEM_REQUIRED);
=======
		if (SetPriorityClass(GetCurrentProcess(), prio) == 0)
		{
			LPSTR messageBuffer = nullptr;
			size_t size = FormatMessage(FORMAT_MESSAGE_ALLOCATE_BUFFER | FORMAT_MESSAGE_FROM_SYSTEM | FORMAT_MESSAGE_IGNORE_INSERTS,
				NULL, GetLastError(), MAKELANGID(LANG_NEUTRAL, SUBLANG_DEFAULT), (LPSTR)&messageBuffer, 0, NULL);
			applog(LOG_ERR, "Error while trying to set the priority:");
			applog(LOG_ERR, "%s", messageBuffer);
			LocalFree(messageBuffer);
		}
		prio = GetPriorityClass(GetCurrentProcess());
		switch (prio)
		{
			case NORMAL_PRIORITY_CLASS:
				applog(LOG_INFO, "CPU priority: %s", "normal");
				break;
			case BELOW_NORMAL_PRIORITY_CLASS:
				applog(LOG_INFO, "CPU priority: %s", "below normal");
				break;
			case ABOVE_NORMAL_PRIORITY_CLASS:
				applog(LOG_INFO, "CPU priority: %s", "above normal");
				break;
			case HIGH_PRIORITY_CLASS:
				applog(LOG_INFO, "CPU priority: %s", "high");
				break;
			case REALTIME_PRIORITY_CLASS:
				applog(LOG_INFO, "CPU priority: %s", "realtime");
				break;
			case IDLE_PRIORITY_CLASS:
				applog(LOG_INFO, "CPU priority: %s", "idle");
				break;
			default:
				applog(LOG_INFO, "CPU priority class: %d", prio);
		}
	}
>>>>>>> 8c320ca... added xevan
#endif
	if (opt_affinity != -1) {
		if (!opt_quiet)
			applog(LOG_DEBUG, "Binding process to cpu mask %x", opt_affinity);
<<<<<<< HEAD
		affine_to_cpu_mask(-1, (unsigned long)opt_affinity);
=======
		affine_to_cpu_mask(-1, opt_affinity);
>>>>>>> 8c320ca... added xevan
	}
	if (active_gpus == 0) {
		applog(LOG_ERR, "No CUDA devices found! terminating.");
		exit(1);
	}
	if (!opt_n_threads)
		opt_n_threads = active_gpus;
<<<<<<< HEAD
	else if (active_gpus > opt_n_threads)
		active_gpus = opt_n_threads;

	// generally doesn't work well...
	gpu_threads = max(gpu_threads, opt_n_threads / active_gpus);

	if (opt_benchmark && opt_algo == ALGO_AUTO) {
		bench_init(opt_n_threads);
		for (int n=0; n < MAX_GPUS; n++) {
			gpus_intensity[n] = 0; // use default
		}
		opt_autotune = false;
	}

=======



// set memspeed /clockspeed
	if (device_memspeed[0] != 0 || device_gpuspeed[0] != 0)
	{
#ifdef WIN32
		applog(LOG_ERR, "Trying to set coreclock to: %d, and memclock to: %d", device_gpuspeed[0],device_memspeed[0]);

		char path[1024];
		system("C:\\Progra~1\\NVIDIA~1\\NVSMI\\nvidia-smi -acp 0");
		for (int i = 0; i < active_gpus; i++)
		{
			sprintf(path, "C:\\Progra~1\\NVIDIA~1\\NVSMI\\nvidia-smi -i %d -ac %d,%d", device_map[i], device_memspeed[0], device_gpuspeed[0]);
			system(path);
		}
#else
		applog(LOG_ERR, "Change the clock is not supported on linux");

#endif
	}


>>>>>>> 8c320ca... added xevan
#ifdef HAVE_SYSLOG_H
	if (use_syslog)
		openlog(opt_syslog_pfx, LOG_PID, LOG_USER);
#endif

	work_restart = (struct work_restart *)calloc(opt_n_threads, sizeof(*work_restart));
	if (!work_restart)
<<<<<<< HEAD
		return EXIT_CODE_SW_INIT_ERROR;

	thr_info = (struct thr_info *)calloc(opt_n_threads + 5, sizeof(*thr));
	if (!thr_info)
		return EXIT_CODE_SW_INIT_ERROR;

	/* longpoll thread */
	longpoll_thr_id = opt_n_threads + 1;
	thr = &thr_info[longpoll_thr_id];
	thr->id = longpoll_thr_id;
	thr->q = tq_new();
	if (!thr->q)
		return EXIT_CODE_SW_INIT_ERROR;

	/* always start the longpoll thread (will wait a tq_push on workio /LP) */
	if (unlikely(pthread_create(&thr->pth, NULL, longpoll_thread, thr))) {
		applog(LOG_ERR, "longpoll thread create failed");
		return EXIT_CODE_SW_INIT_ERROR;
	}

	/* stratum thread */
	stratum_thr_id = opt_n_threads + 2;
	thr = &thr_info[stratum_thr_id];
	thr->id = stratum_thr_id;
	thr->q = tq_new();
	if (!thr->q)
		return EXIT_CODE_SW_INIT_ERROR;

	/* always start the stratum thread (will wait a tq_push) */
	if (unlikely(pthread_create(&thr->pth, NULL, stratum_thread, thr))) {
		applog(LOG_ERR, "stratum thread create failed");
		return EXIT_CODE_SW_INIT_ERROR;
	}

	/* init workio thread */
=======
		return 1;

	thr_info = (struct thr_info *)calloc(opt_n_threads + 4, sizeof(*thr));
	if (!thr_info)
		return 1;

	/* init workio thread info */
>>>>>>> 8c320ca... added xevan
	work_thr_id = opt_n_threads;
	thr = &thr_info[work_thr_id];
	thr->id = work_thr_id;
	thr->q = tq_new();
	if (!thr->q)
<<<<<<< HEAD
		return EXIT_CODE_SW_INIT_ERROR;

	if (pthread_create(&thr->pth, NULL, workio_thread, thr)) {
		applog(LOG_ERR, "workio thread create failed");
		return EXIT_CODE_SW_INIT_ERROR;
	}

	/* real start of the stratum work */
	if (want_stratum && have_stratum) {
		tq_push(thr_info[stratum_thr_id].q, strdup(rpc_url));
	}

#ifdef __linux__
	if (need_nvsettings) {
		if (nvs_init() < 0)
			need_nvsettings = false;
	}
#endif

#ifdef USE_WRAPNVML
#if defined(__linux__) || defined(_WIN64)
	/* nvml is currently not the best choice on Windows (only in x64) */
	hnvml = nvml_create();
	if (hnvml) {
		bool gpu_reinit = (opt_cudaschedule >= 0); //false
		cuda_devicenames(); // refresh gpu vendor name
		if (!opt_quiet)
			applog(LOG_INFO, "NVML GPU monitoring enabled.");
		for (int n=0; n < active_gpus; n++) {
			if (nvml_set_pstate(hnvml, device_map[n]) == 1)
				gpu_reinit = true;
			if (nvml_set_plimit(hnvml, device_map[n]) == 1)
				gpu_reinit = true;
			if (!is_windows() && nvml_set_clocks(hnvml, device_map[n]) == 1)
				gpu_reinit = true;
			if (gpu_reinit) {
				cuda_reset_device(n, NULL);
			}
		}
	}
#endif
#ifdef WIN32
	if (nvapi_init() == 0) {
		if (!opt_quiet)
			applog(LOG_INFO, "NVAPI GPU monitoring enabled.");
		if (!hnvml) {
			cuda_devicenames(); // refresh gpu vendor name
		}
		nvapi_init_settings();
	}
#endif
	else if (!hnvml && !opt_quiet)
		applog(LOG_INFO, "GPU monitoring is not available.");

	// force reinit to set default device flags
	if (opt_cudaschedule >= 0 && !hnvml) {
		for (int n=0; n < active_gpus; n++) {
			cuda_reset_device(n, NULL);
		}
	}
#endif

	if (opt_api_port) {
=======
		return 1;

	/* start work I/O thread */
	if (pthread_create(&thr->pth, NULL, workio_thread, thr)) {
		applog(LOG_ERR, "workio thread create failed");
		return 1;
	}

	if (want_longpoll && !have_stratum) {
		/* init longpoll thread info */
		longpoll_thr_id = opt_n_threads + 1;
		thr = &thr_info[longpoll_thr_id];
		thr->id = longpoll_thr_id;
		thr->q = tq_new();
		if (!thr->q)
			return 1;

		/* start longpoll thread */
		if (unlikely(pthread_create(&thr->pth, NULL, longpoll_thread, thr))) {
			applog(LOG_ERR, "longpoll thread create failed");
			return 1;
		}
	}

	if (want_stratum) {
		/* init stratum thread info */
		stratum_thr_id = opt_n_threads + 2;
		thr = &thr_info[stratum_thr_id];
		thr->id = stratum_thr_id;
		thr->q = tq_new();
		if (!thr->q)
			return 1;

		/* start stratum thread */
		if (unlikely(pthread_create(&thr->pth, NULL, stratum_thread, thr))) {
			applog(LOG_ERR, "stratum thread create failed");
			return 1;
		}

		if (have_stratum)
			tq_push(thr_info[stratum_thr_id].q, strdup(rpc_url));
	}

#ifdef USE_WRAPNVML
#ifndef WIN32
	/* nvml is currently not the best choice on Windows (only in x64) */
	hnvml = nvml_create();
	if (hnvml)
		applog(LOG_INFO, "NVML GPU monitoring enabled.");
#else
	if (nvapi_init() == 0)
		applog(LOG_INFO, "NVAPI GPU monitoring enabled.");
#endif
	else
		applog(LOG_INFO, "GPU monitoring is not available.");
#endif

	if (opt_api_listen) {
>>>>>>> 8c320ca... added xevan
		/* api thread */
		api_thr_id = opt_n_threads + 3;
		thr = &thr_info[api_thr_id];
		thr->id = api_thr_id;
		thr->q = tq_new();
		if (!thr->q)
<<<<<<< HEAD
			return EXIT_CODE_SW_INIT_ERROR;
=======
			return 1;
>>>>>>> 8c320ca... added xevan

		/* start stratum thread */
		if (unlikely(pthread_create(&thr->pth, NULL, api_thread, thr))) {
			applog(LOG_ERR, "api thread create failed");
<<<<<<< HEAD
			return EXIT_CODE_SW_INIT_ERROR;
		}
	}

#ifdef USE_WRAPNVML
	// to monitor gpu activitity during work, a thread is required
	if (1) {
		monitor_thr_id = opt_n_threads + 4;
		thr = &thr_info[monitor_thr_id];
		thr->id = monitor_thr_id;
		thr->q = tq_new();
		if (!thr->q)
			return EXIT_CODE_SW_INIT_ERROR;
		if (unlikely(pthread_create(&thr->pth, NULL, monitor_thread, thr))) {
			applog(LOG_ERR, "Monitoring thread %d create failed", i);
			return EXIT_CODE_SW_INIT_ERROR;
		}
	}
#endif
=======
			return 1;
		}
	}
>>>>>>> 8c320ca... added xevan

	/* start mining threads */
	for (i = 0; i < opt_n_threads; i++) {
		thr = &thr_info[i];

		thr->id = i;
		thr->gpu.thr_id = i;
		thr->gpu.gpu_id = (uint8_t) device_map[i];
		thr->gpu.gpu_arch = (uint16_t) device_sm[device_map[i]];
		thr->q = tq_new();
		if (!thr->q)
<<<<<<< HEAD
			return EXIT_CODE_SW_INIT_ERROR;

		pthread_mutex_init(&thr->gpu.monitor.lock, NULL);
		pthread_cond_init(&thr->gpu.monitor.sampling_signal, NULL);

		if (unlikely(pthread_create(&thr->pth, NULL, miner_thread, thr))) {
			applog(LOG_ERR, "thread %d create failed", i);
			return EXIT_CODE_SW_INIT_ERROR;
=======
			return 1;

		if (unlikely(pthread_create(&thr->pth, NULL, miner_thread, thr))) {
			applog(LOG_ERR, "thread %d create failed", i);
			return 1;
>>>>>>> 8c320ca... added xevan
		}
	}

	applog(LOG_INFO, "%d miner thread%s started, "
		"using '%s' algorithm.",
		opt_n_threads, opt_n_threads > 1 ? "s":"",
		algo_names[opt_algo]);

#ifdef WIN32
	timeBeginPeriod(1); // enable high timer precision (similar to Google Chrome Trick)
#endif

	/* main loop - simply wait for workio thread to exit */
	pthread_join(thr_info[work_thr_id].pth, NULL);

<<<<<<< HEAD
	abort_flag = true;

	/* wait for mining threads */
	for (i = 0; i < opt_n_threads; i++) {
		struct cgpu_info *cgpu = &thr_info[i].gpu;
		if (monitor_thr_id != -1 && cgpu) {
			pthread_cond_signal(&cgpu->monitor.sampling_signal);
		}
		pthread_join(thr_info[i].pth, NULL);
	}

	if (monitor_thr_id != -1) {
		pthread_join(thr_info[monitor_thr_id].pth, NULL);
		//tq_free(thr_info[monitor_thr_id].q);
	}

	if (opt_debug)
		applog(LOG_DEBUG, "workio thread dead, exiting.");

	proper_exit(EXIT_CODE_OK);
=======
	/* wait for mining threads */
	for (i = 0; i < opt_n_threads; i++)
		pthread_join(thr_info[i].pth, NULL);
#ifdef WIN32
	timeEndPeriod(1); // be nice and forego high timer precision
#endif
	if (opt_debug)
		applog(LOG_INFO, "workio thread dead, exiting.");

	proper_exit(0);

>>>>>>> 8c320ca... added xevan
	return 0;
}
