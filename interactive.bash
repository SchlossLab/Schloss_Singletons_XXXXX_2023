#!/bin/bash

salloc --account=pschloss1 --partition=standard --time=05:00:00 --ntasks=1 --cpus-per-task=8 --nodes=1 --mem=46GB

