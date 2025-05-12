# Makefile

LOCALSTACK_URL=http://localhost:4566
PROFILE=localstack
BOOTSTRAP_TEMPLATE=file://templates/priority_queue/template.yaml

.PHONY: up bootstrap down logs shell clean

up:
	@echo "🚀 Starting LocalStack..."
	docker-compose -f localstack/docker-compose.yml up -d

bootstrap:
	@echo "☁️ Bootstrapping some resources..."
	aws --endpoint-url=$(LOCALSTACK_URL) cloudformation create-stack \
        --stack-name local-priority-stack \
        --template-body $(BOOTSTRAP_TEMPLATE) \
        --profile $(PROFILE)

down:
	@echo "🛑 Stopping LocalStack..."
	docker-compose -f localstack/docker-compose.yml down

logs:
	docker-compose -f localstack/docker-compose.yml logs -f

shell:
	@echo "🖥️  Entering LocalStack container shell..."
	docker exec -it localstack-localstack-1 /bin/bash

clean:
	@echo "🧹 Cleaning all LocalStack stacks..."
	aws --endpoint-url=$(LOCALSTACK_URL) --profile=$(PROFILE) cloudformation list-stacks \
		--query "StackSummaries[*].StackName" \
		--output text | xargs -n 1 -I {} \
		aws --endpoint-url=$(LOCALSTACK_URL) --profile=$(PROFILE) cloudformation delete-stack --stack-name {}
