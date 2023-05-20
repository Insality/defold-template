#!/bin/bash

bash ~/code/lua/emmylua-protoc-annotations/export.sh \
	~/code/defold/sea-battle-universe/resources/ \
	~/code/defold/sea-battle-universe/resources/server.proto > ~/code/defold/sea-battle-universe/annotations/annotations-game.lua
