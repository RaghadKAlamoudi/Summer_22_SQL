-- Part II: Create the DDL for your new schema

-- Drop tables if exists
DROP TABLE IF EXISTS "users_id";

DROP TABLE IF EXISTS "subjects";

DROP TABLE IF EXISTS "reports";

DROP TABLE IF EXISTS "statements";

DROP TABLE IF EXISTS "report_votes";

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

-- Index for finding a user by their login name.
-- another name for username is login_name
CREATE INDEX "find_users_by_their_login_name" ON "users" ("login_name");

-- subjects table
-- topic name another word for it is subjects name
CREATE TABLE "subjects"
  ("id" SERIAL PRIMARY KEY, "subjects_name"  VARCHAR(30) UNIQUE NOT NULL,
  "description" VARCHAR(500),"user_id" INTEGER, CONSTRAINT 
  "check_topics_length_not_zero" CHECK (Length(Trim("subjects_name")) > 0));

-- Indexes to list all statements that don’t have any reports.
CREATE INDEX "find_statements_ids_in_statements" ON "statements" ("id");

CREATE INDEX "find_statemenets_ids_in_report" ON "report" ("topic_id");

-- Index for finding a statements by its name.
CREATE INDEX "find_statements_name_in_statements" ON "statements" ("subjects_name");

-- reports table
-- ttontent stands for text content
-- ttemp stands for times_temp
CREATE TABLE "reports"
  (
     "id"             SERIAL PRIMARY KEY,
     "title"          VARCHAR(100) NOT NULL,
     "url"            TEXT,
     "tcontent"       TEXT,
     "users_id"       INTEGER,
     "subject_id"       INTEGER,
          CONSTRAINT "check_reports_length_not_zero" CHECK (Length(Trim("title"))
     > 0),
          CONSTRAINT "fk_user" FOREIGN KEY ("users_id") REFERENCES "users" ("id")
     ON
          DELETE SET NULL,
          CONSTRAINT "fk_subjects" FOREIGN KEY ("subjects_id") REFERENCES "subjects" (
     "users_id")
          ON DELETE CASCADE,
          CONSTRAINT "check_text_or_URL_isexist." CHECK ((("url") IS NULL AND (
          "tcontent") IS NOT NULL) OR (("url") IS NOT NULL AND (
     "tcontent")
          IS NULL)),
     "reports_ttamp" TIMESTAMP
  );

-- Indexes for a list all users who haven’t created any reports.
CREATE INDEX "find_user_ids_in_users" ON "users_id" ("id");

CREATE INDEX "find_user_ids_in_report" ON "reports" ("user_id");

-- Index for a list of latest reports for a given subject.
CREATE INDEX "find_reports_with_timestamp_and_topic" ON "reports" ("URL",
"text_content", "subjects_id", "reports_times_tamp");

-- Index for a list of latest reports for a given user.
CREATE INDEX "find_reports_with_timestamp_and_user" ON "reports" ("URL",
"tcontent", "user_id", "reports_ttamp");

-- Index to find reports with URL.
CREATE INDEX "find_reports_with_URL" ON "reports" ("URL");

-- Comments table
-- pstatements stands for parent_statements
CREATE TABLE "statements"
  (
     "id"                SERIAL PRIMARY KEY,
     "statements"           TEXT NOT NULL,
     "users_id"           INTEGER,
     "subjects_id"       INTEGER,
     "reports_id"           INTEGER,
     "pstatements_id" INTEGER DEFAULT NULL, -- Look here for the i, j queries
     CONSTRAINT "check_reports_length_not_zero" CHECK (Length(Trim("statements")) > 0
     ),
     CONSTRAINT "fk_user" FOREIGN KEY ("users_id") REFERENCES "users" ("id") ON
     DELETE SET NULL,
     CONSTRAINT "fk_subject" FOREIGN KEY ("subjects_id") REFERENCES "subject" ("id")
     ON DELETE CASCADE,
     CONSTRAINT "fk_report" FOREIGN KEY ("reports_id") REFERENCES "reports" ("id") ON
     DELETE CASCADE,
     CONSTRAINT "parent_child_statements_thread" FOREIGN KEY ("pstatements_id")
     REFERENCES "statements" ("users_id") ON DELETE CASCADE
  );

-- Index for all the top-level statements for a given reports.
-- pstatments stands for parent_statements
CREATE INDEX "find_top_level_statements_for_a_report" ON "statements" ("statments",
"post_id", "pstatements_id") WHERE "pstatements_id" = NULL;

-- Index for all the direct children of a parent statements.
-- pstatemenets stands for parent_statements
CREATE INDEX "find_all_the_direct_children_a_parent_statements" ON "statements" ( 
  "statements", "pcomment_id");

-- Index to list the latest statements made by a given user.
CREATE INDEX "find_latest_statements_by_user" ON "statements" ("statements", "users_id");

-- Votes on reports table
CREATE TABLE "post_votes"
  (
     "id"            SERIAL PRIMARY KEY,
     "reports_vote"     INTEGER NOT NULL,
     "voter_user_id" INTEGER,
     "reports_id"       INTEGER,
     CONSTRAINT "set_values_for_votes" CHECK ("reports_vote" = 1 OR "reports_vote" =
     -1),
     CONSTRAINT "fk_user" FOREIGN KEY ("voter_user_id") REFERENCES "users" ("id"
     ) ON DELETE SET NULL,
     CONSTRAINT "fk_post" FOREIGN KEY ("reports_id") REFERENCES "reports" ("id") ON
     DELETE CASCADE
  );

-- Index to find score of reports.
CREATE INDEX "find_score_of_repots" ON "reports_votes" ("reports_vote", "post_id"); 


-- Part III: Migrate the provided data

-- Insert all unique login_name from both initial tables.
INSERT INTO "users"  ("login_name")
WITH unique_usernames
     AS (SELECT login_name
         FROM   "bad_repots"
         UNION ALL
         SELECT login_name
         FROM   "bad_statements"),
     distinct_login_name
     AS (SELECT login_name
         FROM   unique_login_name)
SELECT DISTINCT login_name
FROM   distinct_login_name
ORDER  BY 1 ASC;

-- Insert distinct topics from "bad_reports"
INSERT INTO "subjects" ("subjects_name")
SELECT DISTINCT subjects
FROM   "bad_reports";

-- Insert fields from the "bad_reports", "users" and "reports".

-- usu stands for user
-- bad stands for bad reports
-- sub stands for subject
INSERT INTO "reports_votes"
INSERT INTO "reports"
            ("subjects","url", "text_content", "user_id", "_id")
SELECT bad.subjects, bad.url, bad.text_content,
       usu.id AS user_id,
       sub.id AS subjects_id
FROM   "bad_reports" bad
       join "users" usu
         ON bad.login_name = usu.login_name
       join "subjects" sub
         ON bad.subjects = sub.subjects_name
WHERE  Left(bad.title,100);

-- Insert statements and ids in "statements".

-- rep stands for reports
-- usu stands for user
-- bad stands for bad reports
-- bst stand for bad_statements
INSERT INTO "reports_votes"
INSERT INTO "statements"
            ("statements", "user_id", "subjects_id", "reports_id")
SELECT bst.text_content AS STATEMENT,
       rep.user_id,
       rep.subject_id,
       rep.id           AS post_id
FROM   "bad_reports" bad
       join "reports" rep
         ON bad.title = pos.title
       join "users_id" usu
         ON rep.user_id = usu.id
       join "bad_statements" bst
         ON usu.login_name = bst.login_name;

-- Insert upvotes & downvotes in "reports_votes".

-- rep stands for reports
-- usu stands for user
-- bad stands for bad reports
INSERT INTO "reports_votes"
            ("reports_vote", "voter_user_id", "reports_id")
WITH "bad_posts_upvotes"
     AS (SELECT title,
                Regexp_split_to_table(bad.upvotes, ',') AS login_name_upvotes
         FROM   "bad_reports" bad),
     "bad_reports_downvotes"
     AS (SELECT title,
                Regexp_split_to_table(bad.downvotes, ',') AS login_name_downvotes
         FROM   "bad_reports" bad) SELECT 1     AS reports_vote,
       usu.id AS voter_user_id,
       rep.id AS post_id
FROM   "bad_reports_upvotes" bpu
       join "reports" rep
         ON bpu.title = po.title
       join "users" usu
         ON bpu.login_name_upvotes = usu.login_name
UNION ALL
SELECT -1    AS reports_vote,
       usu.id AS voter_user_id,
       reports.id AS reports_id
FROM   "bad_reports_downvotes" bpd
       join "reports" rep
         ON bpd.title = rep.title
       join "users" usu
         ON bpd.login_name_downvotes = usu.login_name; 