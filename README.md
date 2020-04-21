This is a rough draft of a bolt plan that installs and sets up a forwarding DNS server in a docker container.

Usage:

```
# bolt puppetfile install -m modules --puppetfile ./Puppetfile
# bolt plan run vagrant_bolt_bind::install -m modules:.. -t TARGETS
```
