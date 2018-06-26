IMAGES=nginx papi posda quince

.PHONY: $(IMAGES)

default: $(IMAGES)

$(IMAGES):
	$(MAKE) -C $@

dev-up:
	docker-compose -f docker-compose.dev.yaml up

dev-down:
	docker-compose -f docker-compose.dev.yaml down



push:
	docker image push quasarj/posda_nginx
	docker image push quasarj/quince
	docker image push quasarj/posda2
	docker image push quasarj/k-base
	docker image push quasarj/kaleidoscope
	docker image push quasarj/posda-api
