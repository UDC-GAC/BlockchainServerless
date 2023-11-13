#!/usr/bin/env bash

    ./build/tsdb mkmetric user.accounting.coins
    ./build/tsdb mkmetric user.accounting.min_balance
    ./build/tsdb mkmetric user.accounting.max_debt


  ./build/tsdb mkmetric bucket.tasks.input
  ./build/tsdb mkmetric bucket.tasks.processing