
### Building Notes
```sh
docker build --tag "tbk/tor-static" .
```

### Inspecting the Container
```sh
docker run --rm --entrypoint="/bin/bash" -it tbk/tor-static
```

### Run
```sh
docker run --rm --name=tbk-tor-static -it tbk/tor-static
```

#### Hostname
```sh
docker exec -it tbk-tor-static cat /var/lib/tor/hidden_service/hostname
```
