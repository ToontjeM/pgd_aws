### 02-Failover

- BR: 
  `CTRL-D` (become admin)

  `sudo su` (become root)

  `cd /var/lib/edb-as/scripts/02-failover`

  `./stop_postgres_node.sh`

  ```
    Tue Jan 23 15:57:15 UTC 2024
   connected_to
  --------------
   pgd1-useast2

   count
  -------
   12226

  INSERT 0 1
  Tue Jan 23 15:57:16 UTC 2024
  psql: error: connection to server at "pgd1-useast2" (10.33.1.93), port 6432 failed: SSL connection has been closed unexpectedly
  Tue Jan 23 15:57:16 UTC 2024
   connected_to
  --------------
   pgd2-useast2

   count
  -------
   12230
  ```

Show monitor. Show data.

- BL: `./start_postgres_node.sh`