IMAGES=nginx papi posda quince

.PHONY: $(IMAGES)

default: $(IMAGES)

$(IMAGES):
	$(MAKE) -C $@

dev-up:
	docker-compose -f docker-compose.dev.yaml up

dev-down:
	docker-compose -f docker-compose.dev.yaml down
