#!/bin/bash

gen_key() {
	ssh-keygen -t ed25519 -b 4096 -f "$HOME/.ssh/${1}"
}

