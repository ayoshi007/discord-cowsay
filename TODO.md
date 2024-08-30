## Todo
- [x] setup ping-pong request
- [x] setup security signature verification
- [x] create AWS lambda and gateway for http endpoint
- [x] register endpoint with discord bot
- [ ] flush out register script
    - [ ] delete commands
    - [ ] add commands
    - [ ] modify commands (?)
- [ ] update layer to add cowsay
- [ ] create custom package to hold common data
    - [ ] enums for callback types
    - [ ] urls
    - [ ] basic functions for sending requests
- [ ] implement cowsay command


## Broader goals
- [ ] rewrite in Rust
    - [ ] rewrite register script to Rust
    - [ ] rewrite proxy and command Lambdas to Rust using AWS Linux runtime
        - [ ] rewrite custom packages as a Rust lib
