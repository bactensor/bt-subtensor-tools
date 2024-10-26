# What is this

This repository contains tools for setting up a reliable (private) bittensor subtensor and a subtensor proxy that 
works as a drop in replacement for regular subtensors, consumes minimal resources (therefore can and should be 
run on each node requiring subtensor access) and supports failovers to public subtensors (subvortex and finney)
in case of private subtensor downtime. The private subtensor deployed using this repo's tools automatically detects 
being out of sync and disables traffic to it in such a case. If synchronisation is not achieved after a period of time,
the subtensor will be purged and started anew.

# Usage

## Deploying private subtensor

After setting up a Linode account (together with a payment method) and obtaining a Linode API key run 
`bash deploy_linode_subtensor.sh`. You will be prompted for the API key and some other deployment details (like an ssh 
key for the newly created virtual machines). Once the process is done, proceed to your Linode account, go to 
the `NodeBalancers` tab and copy the address of the newly created NodeBalancer.

## Starting subtensor proxy

While the subtensor mentioned above is ready to use as is, it might fail (as all subtensors might) so for enhanced 
stability we suggest using a subtensor proxy, deploying it on each node utilizing a subtensor. In case of private
subtensor failure, the proxy will direct traffic to subvortex and finney, without any changes in  client code (miner,
validator, btcli etc.). Simply run

```
docker run --env SUBTENSOR_NODE_ADDRESS=... -p 9944:9944 ghcr.io/bactensor/bt-subtensor-tools/subtensor-proxy
```

(as value for `SUBTENSOR_NODE_ADDRESS` use the load balancer address as displayed in Linode console, for example
`105.200.223.24`)

To use the proxy just type `localhost:9944` as your subtensor address, for example when using btcli: 

```
btcli s metagraph --netuid 1 --subtensor.network localhost:9944
```

## If your subtensor client (miner, validator) is running in docker

Using `localhost:9944` as subtensor address won't work, due to how docker hahndles networking. The best way is to put 
the ghcr.io/bactensor/bt-subtensor-tools/subtensor-proxy in the same 
docker-compose.yml as your miner/validator. For example if you use `subtensor-proxy` as the service name in 
docker-compose.yml add `subtensor-proxy` in `links` section of your subtensor client (miner or validator) service  
configuration and use `subtensor-proxy:9944` as the subtensor address.

If you're not using docker-compose you need to find the address of your host machine in docker network (it often is
`172.17.0.1`). You can do that by listing network interfaces along with addresses, for example using `ip a` and looking
for sth like `docker0`. After you find that address, pass it as your subtensor address to your subtensor client (miner, 
validator), for example `172.17.0.1:9944`.