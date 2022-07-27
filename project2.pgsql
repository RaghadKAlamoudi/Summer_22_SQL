-- Part II: Create the DDL for your new schema

-- Drop tables if exists
DROP TABLE IF EXISTS "users";

DROP TABLE IF EXISTS "topics";

DROP TABLE IF EXISTS "posts";

DROP TABLE IF EXISTS "comments";

DROP TABLE IF EXISTS "post_votes";

-- Users table
-- another name for username is login_name
-- ttemp stands for times_temp
CREATE TABLE "users"
  ("users_id" SERIAL PRIMARY KEY, "login_name"  VARCHAR(50) UNIQUE NOT NULL,
    CONSTRAINT "check_users_length_not_zero" CHECK (Length(Trim("login_name")) > 0),
     "login_ttamp" TIMESTAMP);

-- Index for a list of all users who haven’t logged in in the last year.
-- another name for username is login_name
-- ttemp stands for times_temp
CREATE INDEX "find_users_not_logged_in_last_year" ON "users" ("login_name",
"login_ttamp");

-- Index for finding a user by their username.
-- another name for username is login_name
CREATE INDEX "find_users_by_their_username" ON "users" ("login_name");

-- Topics table
-- topic name another word for it is subjects name
CREATE TABLE "topics"
  ("id" SERIAL PRIMARY KEY, "subjects_name"  VARCHAR(30) UNIQUE NOT NULL,
  "description" VARCHAR(500),"user_id" INTEGER, CONSTRAINT 
  "check_topics_length_not_zero" CHECK (Length(Trim("subjects_name")) > 0));

-- Indexes to list all topics that don’t have any posts.
CREATE INDEX "find_topic_ids_in_topics" ON "topics" ("id");

CREATE INDEX "find_topic_ids_in_posts" ON "posts" ("topic_id");

-- Index for finding a topic by its name.
CREATE INDEX "find_topic_name_in_topics" ON "topics" ("subjects_name");

-- Posts table
-- ttontent stands for text content
-- ttemp stands for times_temp
CREATE TABLE "posts"
  (
     "id"             SERIAL PRIMARY KEY,
     "title"          VARCHAR(100) NOT NULL,
     "url"            TEXT,
     "tcontent"       TEXT,
     "users_id"       INTEGER,
     "topic_id"       INTEGER,
          CONSTRAINT "check_posts_length_not_zero" CHECK (Length(Trim("title"))
     > 0),
          CONSTRAINT "fk_user" FOREIGN KEY ("users_id") REFERENCES "users" ("id")
     ON
          DELETE SET NULL,
          CONSTRAINT "fk_topic" FOREIGN KEY ("topic_id") REFERENCES "topics" (
     "id")
          ON DELETE CASCADE,
          CONSTRAINT "check_text_or_URL_isexist." CHECK ((("url") IS NULL AND (
          "tcontent") IS NOT NULL) OR (("url") IS NOT NULL AND (
     "tcontent")
          IS NULL)),
     "post_ttamp" TIMESTAMP
  );

-- Indexes for a list all users who haven’t created any post.
CREATE INDEX "find_user_ids_in_users" ON "users" ("id");

CREATE INDEX "find_user_ids_in_posts" ON "posts" ("user_id");

-- Index for a list of latest posts for a given topic.
CREATE INDEX "find_posts_with_timestamp_and_topic" ON "posts" ("URL",
"text_content", "topic_id", "post_times_tamp");

-- Index for a list of latest posts for a given user.
CREATE INDEX "find_posts_with_timestamp_and_user" ON "posts" ("URL",
"tcontent", "user_id", "post_ttamp");

-- Index to find posts with URL.
CREATE INDEX "find_posts_with_URL" ON "posts" ("URL");

-- Comments table
-- pcomments stands for parent_comment
CREATE TABLE "comments"
  (
     "id"                SERIAL PRIMARY KEY,
     "comment"           TEXT NOT NULL,
     "users_id"           INTEGER,
     "subjects_id"       INTEGER,
     "post_id"           INTEGER,
     "pcomment_id" INTEGER DEFAULT NULL, -- Look here for the i, j queries
     CONSTRAINT "check_posts_length_not_zero" CHECK (Length(Trim("comment")) > 0
     ),
     CONSTRAINT "fk_user" FOREIGN KEY ("users_id") REFERENCES "users" ("id") ON
     DELETE SET NULL,
     CONSTRAINT "fk_topic" FOREIGN KEY ("subjects_id") REFERENCES "topics" ("id")
     ON DELETE CASCADE,
     CONSTRAINT "fk_post" FOREIGN KEY ("post_id") REFERENCES "posts" ("id") ON
     DELETE CASCADE,
     CONSTRAINT "parent_child_comment_thread" FOREIGN KEY ("pcomment_id")
     REFERENCES "comments" ("id") ON DELETE CASCADE
  );

-- Index for all the top-level comments for a given post.
-- pcomments stands for parent_comment
CREATE INDEX "find_top_level_comments_for_a_post" ON "comments" ("comment",
"post_id", "pcomment_id") WHERE "pcomment_id" = NULL;

-- Index for all the direct children of a parent comment.
-- pcomments stands for parent_comment
CREATE INDEX "find_all_the_direct_children_a_parent_comment" ON "comments" ( 
  "comment", "pcomment_id");

-- Index to list the latest comments made by a given user.
CREATE INDEX "find_latest_comments_by_user" ON "comments" ("comment", "users_id");

-- Votes on posts table
CREATE TABLE "post_votes"
  (
     "id"            SERIAL PRIMARY KEY,
     "post_vote"     INTEGER NOT NULL,
     "voter_user_id" INTEGER,
     "post_id"       INTEGER,
     CONSTRAINT "set_values_for_votes" CHECK ("post_vote" = 1 OR "post_vote" =
     -1),
     CONSTRAINT "fk_user" FOREIGN KEY ("voter_user_id") REFERENCES "users" ("id"
     ) ON DELETE SET NULL,
     CONSTRAINT "fk_post" FOREIGN KEY ("post_id") REFERENCES "posts" ("id") ON
     DELETE CASCADE
  );

-- Index to find score of post.
CREATE INDEX "find_score_of_post" ON "post_votes" ("post_vote", "post_id"); 


-- Part III: Migrate the provided data

-- Insert all unique login_name from both initial tables.
INSERT INTO "users"  ("login_name")
WITH unique_usernames
     AS (SELECT login_name
         FROM   "bad_posts"
         UNION ALL
         SELECT login_name
         FROM   "bad_comments"),
     distinct_login_name
     AS (SELECT login_name
         FROM   unique_login_name)
SELECT DISTINCT login_name
FROM   distinct_login_name
ORDER  BY 1 ASC;

-- Insert distinct topics from "bad_posts"
INSERT INTO "topics" ("topic_name")
SELECT DISTINCT topic
FROM   "bad_posts";

-- Insert fields from the "bad_posts", "users" and "topics".

-- pos stands for posts
-- usu stands for user
-- bad stands for bad posts
-- top stands for topics
INSERT INTO "post_votes"
INSERT INTO "posts"
            ("title","url", "text_content", "user_id", "topic_id")
SELECT bad.title, bad.url, bad.text_content,
       usu.id AS user_id,
       top.id AS topic_id
FROM   "bad_posts" bad
       join "users" usu
         ON bad.login_name = usu.login_name
       join "topics" top
         ON bad.topic = top.topic_name
WHERE  Left(bad.title,100);

-- Insert comments and ids in "comments".

-- pos stands for posts
-- usu stands for user
-- bad stands for bad posts
-- bco stand for bad_comments
INSERT INTO "post_votes"
INSERT INTO "comments"
            ("comment", "user_id", "topic_id", "post_id")
SELECT bco.text_content AS COMMENT,
       pos.user_id,
       pos.topic_id,
       pos.id           AS post_id
FROM   "bad_posts" bad
       join "posts" pos
         ON bad.title = pos.title
       join "users" usu
         ON po.user_id = usu.id
       join "bad_comments" bco
         ON usu.login_name = bco.login_name;

-- Insert upvotes & downvotes in "post_votes".

-- pos stands for posts
-- usu stands for user
-- bad stands for bad posts
INSERT INTO "post_votes"
            ("post_vote", "voter_user_id", "post_id")
WITH "bad_posts_upvotes"
     AS (SELECT title,
                Regexp_split_to_table(bad.upvotes, ',') AS login_name_upvotes
         FROM   "bad_posts" bad),
     "bad_posts_downvotes"
     AS (SELECT title,
                Regexp_split_to_table(bad.downvotes, ',') AS login_name_downvotes
         FROM   "bad_posts" bad) SELECT 1     AS post_vote,
       usu.id AS voter_user_id,
       pos.id AS post_id
FROM   "bad_posts_upvotes" bpu
       join "posts" pos
         ON bpu.title = po.title
       join "users" usu
         ON bpu.login_name_upvotes = usu.login_name
UNION ALL
SELECT -1    AS post_vote,
       usu.id AS voter_user_id,
       pos.id AS post_id
FROM   "bad_posts_downvotes" bpd
       join "posts" pos
         ON bpd.title = pos.title
       join "users" usu
         ON bpd.login_name_downvotes = usu.login_name; 