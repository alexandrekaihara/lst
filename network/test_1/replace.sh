#!/bin/bash

# Load all environment variables
. env

REPOSITORY=$REPOSITORY envsubst < experiment.json