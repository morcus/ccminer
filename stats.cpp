/**
 * Stats place holder
 *
 * Note: this source is C++ (requires std::map)
 *
 * tpruvot@github 2014
 */
#include <stdlib.h>
#include <memory.h>
#include <map>

#include "miner.h"

static std::map<uint64_t, stats_data> tlastscans;
static uint64_t uid = 0;

<<<<<<< HEAD
#define STATS_AVG_SAMPLES 30
#define STATS_PURGE_TIMEOUT 120*60 /* 120 mn */

extern uint64_t global_hashrate;
extern int opt_statsavg;
=======
//#define STATS_AVG_SAMPLES 60
#define STATS_PURGE_TIMEOUT 240*30 /* 60 mn */

extern uint64_t global_hashrate;
extern uint32_t opt_statsavg;
>>>>>>> 8c320ca... added xevan

/**
 * Store speed per thread
 */
void stats_remember_speed(int thr_id, uint32_t hashcount, double hashrate, uint8_t found, uint32_t height)
{
<<<<<<< HEAD
	const uint64_t key = uid++;
=======
	uint8_t  gpu = thr_id;// (uint8_t) device_map[thr_id];

	const uint64_t key = ((uid++ % UINT32_MAX) << 32) + gpu;
>>>>>>> 8c320ca... added xevan
	stats_data data;
	// to enough hashes to give right stats
	if (hashcount < 1000 || hashrate < 0.01)
		return;

	// first hash rates are often erroneous
<<<<<<< HEAD
	//if (uid < opt_n_threads * 2)
	//	return;

	memset(&data, 0, sizeof(data));
	data.uid = (uint32_t) uid;
	data.gpu_id = (uint8_t) device_map[thr_id];
	data.thr_id = (uint8_t) thr_id;
	data.tm_stat = (uint32_t) time(NULL);
	data.height = height;
	data.npool = (uint8_t) cur_pooln;
	data.pool_type = pools[cur_pooln].type;
	data.hashcount = hashcount;
	data.hashfound = found;
	data.hashrate = hashrate;
	data.difficulty = net_diff ? net_diff : stratum_diff;
	if (opt_n_threads == 1 && global_hashrate && uid > 10) {
=======
	if (uid < opt_n_threads * opt_n_gputhreads)
		return;

	memset(&data, 0, sizeof(data));
	data.uid = (uint32_t) uid;
	data.gpu_id = gpu;
	data.thr_id = (uint8_t)thr_id;
	data.tm_stat = (uint32_t) time(NULL);
	data.height = height;
	data.hashcount = hashcount;
	data.hashfound = found;
	data.hashrate = hashrate;
	data.difficulty = global_diff;
	if (opt_n_threads == 1 && global_hashrate && uid > 10) 
	{
>>>>>>> 8c320ca... added xevan
		// prevent stats on too high vardiff (erroneous rates)
		double ratio = (hashrate / (1.0 * global_hashrate));
		if (ratio < 0.4 || ratio > 1.6)
			data.ignored = 1;
	}
	tlastscans[key] = data;
}

/**
 * Get the computed average speed
 * @param thr_id int (-1 for all threads)
 */
double stats_get_speed(int thr_id, double def_speed)
{
<<<<<<< HEAD
	double speed = 0.0;
	int records = 0;

	std::map<uint64_t, stats_data>::reverse_iterator i = tlastscans.rbegin();
	while (i != tlastscans.rend() && records < opt_statsavg) {
		if (!i->second.ignored)
		if (thr_id == -1 || i->second.thr_id == thr_id) {
=======
	uint64_t gpu = thr_id;//device_map[thr_id];

	const uint64_t keymsk = 0xffULL; // last u8 is the gpu
	double speed = 0.0;
	uint32_t records = 0;

	std::map<uint64_t, stats_data>::reverse_iterator i = tlastscans.rbegin();
	while (i != tlastscans.rend() && records < opt_statsavg) 
	{
		if (!i->second.ignored)
		if (thr_id == -1 || (keymsk & i->first) == gpu) {
>>>>>>> 8c320ca... added xevan
			if (i->second.hashcount > 1000) {
				speed += i->second.hashrate;
				records++;
				// applog(LOG_BLUE, "%d %x %.1f", thr_id, i->second.thr_id, i->second.hashrate);
			}
		}
		++i;
	}

	if (records)
		speed /= (double)(records);
	else
		speed = def_speed;

	if (thr_id == -1)
		speed *= (double)(opt_n_threads);

	return speed;
}

/**
<<<<<<< HEAD
 * Get the gpu average speed
 * @param gpu_id int (-1 for all threads)
 */
double stats_get_gpu_speed(int gpu_id)
{
	double speed = 0.0;

	for (int thr_id=0; thr_id<opt_n_threads; thr_id++) {
		int dev_id = device_map[thr_id];
		if (gpu_id == -1 || dev_id == gpu_id)
			speed += stats_get_speed(thr_id, 0.0);
	}

	return speed;
}

/**
=======
>>>>>>> 8c320ca... added xevan
 * Export data for api calls
 */
int stats_get_history(int thr_id, struct stats_data *data, int max_records)
{
<<<<<<< HEAD
	int records = 0;

	std::map<uint64_t, stats_data>::reverse_iterator i = tlastscans.rbegin();
	while (i != tlastscans.rend() && records < max_records) {
		if (!i->second.ignored)
			if (thr_id == -1 || i->second.thr_id == thr_id) {
=======
	const uint64_t gpu = device_map[thr_id];
	const uint64_t keymsk = 0xffULL; // last u8 is the gpu
	int records = 0;

	std::map<uint64_t, stats_data>::reverse_iterator i = tlastscans.rbegin();
	while (i != tlastscans.rend() && records < max_records) 
	{
		if (!i->second.ignored)
			if (thr_id == -1 || (keymsk & i->first) == gpu) {
>>>>>>> 8c320ca... added xevan
				memcpy(&data[records], &(i->second), sizeof(struct stats_data));
				records++;
			}
		++i;
	}
	return records;
}

/**
 * Remove old entries to reduce memory usage
 */
void stats_purge_old(void)
{
	int deleted = 0;
	uint32_t now = (uint32_t) time(NULL);
<<<<<<< HEAD
	uint32_t sz = (uint32_t) tlastscans.size();
	std::map<uint64_t, stats_data>::iterator i = tlastscans.begin();
	while (i != tlastscans.end()) {
		if (i->second.ignored || (now - i->second.tm_stat) > STATS_PURGE_TIMEOUT) {
=======
	uint32_t sz = tlastscans.size();
	std::map<uint64_t, stats_data>::iterator i = tlastscans.begin();
	while (i != tlastscans.end()) {
		if (i->second.ignored || (now - i->second.tm_stat) > STATS_PURGE_TIMEOUT) 
		{
>>>>>>> 8c320ca... added xevan
			deleted++;
			tlastscans.erase(i++);
		}
		else ++i;
	}
	if (opt_debug && deleted) {
		applog(LOG_DEBUG, "stats: %d/%d records purged", deleted, sz);
	}
}

/**
 * Reset the cache
 */
void stats_purge_all(void)
{
	tlastscans.clear();
}

/**
 * API meminfo
 */
void stats_getmeminfo(uint64_t *mem, uint32_t *records)
{
<<<<<<< HEAD
	(*records) = (uint32_t) tlastscans.size();
=======
	(*records) = tlastscans.size();
>>>>>>> 8c320ca... added xevan
	(*mem) = (*records) * sizeof(stats_data);
}
