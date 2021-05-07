#!/bin/bash

GREEN='\033[0;32m'

echo -e "${GREEN}Step 2: Migrating database"
  yarn prisma migrate up --experimental
  yarn prisma generate

echo -e "${GREEN}Step 3: Seeding database"
  node ./prisma/seeders/index.js

yarn nodemon src/index.js
