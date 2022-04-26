#!/bin/bash

NODE_NAME=$(sudo docker info --format '{{ .Name }}')

sudo docker node update --availability drain $NODE_NAME
