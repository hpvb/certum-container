#!/bin/sh

# Simple wrapper to run forground processes in monit, redirecting output to monit's stdout

$@ 1>/proc/1/fd/1 2>/proc/1/fd/1 &
