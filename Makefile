GOCMD=go
GOBUILD=$(GOCMD) build
GOCLEAN=$(GOCMD) clean
GOTEST=$(GOCMD) test
GOGET=$(GOCMD) get
BINARY_NAME=main

all: test build
build:
	$(GOBUILD) -o $(BINARY_NAME) -v
test:
	$(GOTEST) -v ./...
clean:
	$(GOCLEAN)
	rm -f $(BINARY_NAME)

deps:
	$(GOGET) github.com/aws/aws-sdk-go
	$(GOGET) github.com/labstack/echo
	$(GOGET) github.com/aws/aws-lambda-go
	$(GOGET) github.com/awslabs/aws-lambda-go-api-proxy

# Cross compilation
build-linux:
	CGO_ENABLED=0 GOOS=linux GOARCH=amd64 $(GOBUILD) -o $(BINARY_NAME) -v

# Package
package: build-linux
	zip lambda.zip main
