.PHONY: build

build:
	docker pull python:3-stretch
	docker build -t jeffrey04/blockornot-neo --force-rm .

push:
	docker push jeffrey04/blockornot-neo

demo:
	cd blockornot && \
		docker run -d -p 1181:1181 -e APP_PORT=1181 -e APP_DB=/var/lib/blockornot/database.db -v /home/jeffrey04/Projects/blockornot-neo/blockornot/db:/var/lib/blockornot jeffrey04/blockornot-neo