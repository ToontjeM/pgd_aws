--
-- /!\ Execute in psql:
-- \i conflicts_start_transaction.sql
-- Doc: https://www.enterprisedb.com/docs/pgd/latest/consistency/conflicts/

start transaction;
insert into test_conflict values (1, 'from '||pg_read_file('/etc/hostname'));
--select node_name, current_timestamp from bdr.local_node_summary;






-- Conflict reporting
SELECT nspname, relname
, date_trunc('day', local_time) :: date AS date
, count(*)
FROM bdr.conflict_history
WHERE local_time > date_trunc('day', current_timestamp)
GROUP BY 1,2,3
ORDER BY 1,2;
