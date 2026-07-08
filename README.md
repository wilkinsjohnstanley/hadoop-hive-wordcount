# Hive on HDFS — SQL vs raw MapReduce

Loaded the output of a WordCount MapReduce job into a Hive external table and queried it with SQL, to contrast writing SQL against hand-written Java MapReduce.

Builds on the [hadoop-wordcount]([../hadoop-wordcount](https://github.com/wilkinsjohnstanley/hadoop-wordcount)) project — this uses the same Hadoop container and the WordCount output already sitting in HDFS.

## Setup

1. Downloaded and extracted Hive 3.1.3 (Apache's main mirror had nothing for this version — used the archive instead):
   ```
   curl -O https://archive.apache.org/dist/hive/hive-3.1.3/apache-hive-3.1.3-bin.tar.gz
   tar -xzf apache-hive-3.1.3-bin.tar.gz
   mv apache-hive-3.1.3-bin /opt/hive
   ```

2. Set environment variables:
   ```
   export HIVE_HOME=/opt/hive
   export PATH=$PATH:$HIVE_HOME/bin
   export HADOOP_HOME=/opt/hadoop
   ```

3. Initialized the (embedded Derby) metastore:
   ```
   schematool -dbType derby -initSchema
   ```

4. Launched the Hive CLI:
   ```
   hive
   ```

## Table + queries

See `wordcount.hql`.

- Pointed an **external table** at the existing WordCount MapReduce output in HDFS (`/user/hive/warehouse/wordcount`) — no data copy/transform needed, Hive reads the TSV directly.
- `SELECT *` — plain scan; Hive skips launching a MapReduce job entirely for this.
- `SELECT SUM(count) ...` and `... ORDER BY count DESC` — both compiled down to real YARN MapReduce jobs automatically (visible as `job_..._0005`, `job_..._0006` in the CLI output), same execution engine as the hand-written Java job.

## Takeaway

Hive lets you express the same aggregation logic in a few lines of SQL instead of a full Mapper/Reducer class, at the cost of some low-level control (e.g. no direct hand-tuning of a combiner or partitioner the way raw MapReduce allows).

## Gotchas

- Apache's main download mirror had no listing for Hive 3.1.3 — had to pull from `archive.apache.org` instead.
- Hive-on-MR prints a deprecation warning (Tez/Spark are the recommended engines now) — harmless for this exercise, MR still works fine.
