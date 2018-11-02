package main

import (
	"errors"
	"testing"

	"github.com/stretchr/testify/assert"
)

func TestFibonnaciInputLessOrEqualToOne(t *testing.T) {
	assert.Equal(t, 1, fibonacci(1))
}

func TestFibonnaciInputGreatherThanOne(t *testing.T) {
	assert.Equal(t, 13, fibonacci(7))
}

func TestHandlerNegativeNumber(t *testing.T) {
	responseNumber, responseError := handler(-1)
	assert.Equal(t, -1, responseNumber)
	assert.Equal(t, errors.New("Input must be a positive number"), responseError)
}

func TestHandlerPositiveNumber(t *testing.T) {
	responseNumber, responseError := handler(5)
	assert.Equal(t, 5, responseNumber)
	assert.Nil(t, responseError)
}
