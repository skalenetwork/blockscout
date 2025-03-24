#!/bin/bash

set -e

chown -R 2000:2000 /var/lib/postgresql/15/data /var/lib/postgresql/17/data

su - blockscout -c '/usr/lib/postgresql/17/bin/initdb -D /var/lib/postgresql/17/data'

cp /var/lib/postgresql/15/data/pg_hba.conf /var/lib/postgresql/17/data/pg_hba.conf
cp /var/lib/postgresql/15/data/postgresql.conf /var/lib/postgresql/17/data/postgresql.conf

su - blockscout -c '/usr/lib/postgresql/17/bin/pg_upgrade \
  --old-bindir=/usr/lib/postgresql/15/bin \
  --new-bindir=/usr/lib/postgresql/17/bin \
  --old-datadir=/var/lib/postgresql/15/data \
  --new-datadir=/var/lib/postgresql/17/data'

su - blockscout -c '/usr/lib/postgresql/17/bin/pg_ctl -D /var/lib/postgresql/17/data -l logfile start'
su - blockscout -c '/usr/lib/postgresql/17/bin/vacuumdb --all --analyze-in-stages'
su - blockscout -c '/usr/lib/postgresql/17/bin/pg_ctl -D /var/lib/postgresql/17/data stop'
