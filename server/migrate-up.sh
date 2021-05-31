#!/bin/bash

GREEN='\033[0;32m'

echo -e "${GREEN}Step 2: Migrating database"
  yarn prisma migrate up --experimental
  yarn prisma generate

