# Uptime

## Develop

### Run

To start your Phoenix server:

- Copy the environment config
- Run `mix setup` to install and setup dependencies
- Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

### Orchestrate

To run the docker compose orchestration with Traefik reverse proxy with DNS for the services:

First, install `dnsmasq` (`brew install dnsmasq`) and edit `dnsmasq.conf`.

```sh
sudo vim $(brew --prefix)/etc/dnsmasq.conf
```

```conf
address=/uptime.arpa/127.0.0.1
resolv-file=/etc/resolver/arpa
port=53
```

Then, add the resolver:

```sh
mkdir -v /etc/resolver
sudo vim /etc/resolver/arpa
```

```
nameserver 127.0.0.1
```

```sh
sudo brew services start dnsmasq
```

See also: https://gist.github.com/ogrrd/5831371

<!-- automatic setup? https://github.com/kevinburke/hostsfile
https://github.com/costela/docker-etchosts -->
