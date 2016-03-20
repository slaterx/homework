#!/bin/bash
set -e

# Simple command to startup postgres
exec su postgres -c "/etc/init.d/postgresql start"


# End 
