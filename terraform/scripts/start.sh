#! /usr/bin/env bash

pkill swift
cd .build/release
./Generator-Swiftserver-Projects
cd -
