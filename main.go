package main

import (
	"errors"

	"github.com/aws/aws-lambda-go/lambda"
)

func fibonacci(n int) int {
	if n <= 1 {
		return n
	}
	return fibonacci(n-1) + fibonacci(n-2)
}

func handler(n int) (int, error) {
	if n < 0 {
		return -1, errors.New("Input must be a positive number")
	}
	return fibonacci(n), nil
}

func main() {
	lambda.Start(handler)
}
