#!/bin/bash

# Load all environment variables
. .env

envsubst < experiment_script.json > experiment.json
