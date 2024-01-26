# Failed node replacement

- Create pgd3 in us-ease2 using `tpaexec` with config file `scripts/07-failed-node/MRLR4DN-config.new.node.yml`
- Drop a node from the cluster using  `./drop node`
- Re-create the node running step 1 again.