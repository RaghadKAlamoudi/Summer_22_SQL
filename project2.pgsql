-- Part II: Create the DDL for your new schema

-- Drop tables if exists
DROP TABLE IF EXISTS "users";

DROP TABLE IF EXISTS "topics";

DROP TABLE IF EXISTS "posts";

DROP TABLE IF EXISTS "comments";

DROP TABLE IF EXISTS "post_votes";

-- Users table
CREATE TABLE "users"
  ("id" SERIAL PRIMARY KEY, "username"  VARCHAR(50) UNIQUE NOT NULL,
    CONSTRAINT "check_users_length_not_zero" CHECK (Length(Trim("username")) > 0),
     "login_timestamp" TIMESTAMP);

-- Index for a list of all users who haven’t logged in in the last year.
CREATE INDEX "find_users_not_logged_in_last_year" ON "users" ("username",
"login_timestamp");

-- Index for finding a user by their username.
CREATE INDEX "find_users_by_their_username" ON "users" ("username");