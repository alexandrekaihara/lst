#!/bin/bash

# Load all environment variables
. .env

envsubst < experiment.json > aux.json
