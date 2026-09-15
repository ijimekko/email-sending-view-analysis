-- Create view
CREATE VIEW Students.v_Bobko_Aggregation
AS

WITH
  raw AS (
    SELECT
      es.id_account,
      es.id_message,
      DATE(DATE_ADD(ses.date, INTERVAL es.sent_date DAY)) AS sent_day,
      DATE_TRUNC(DATE(DATE_ADD(ses.date, INTERVAL es.sent_date DAY)), MONTH)
        AS sent_month
    FROM `DA.email_sent` es
    JOIN `DA.account_session` acs
      ON es.id_account = acs.account_id
    JOIN `DA.session` ses
      ON acs.ga_session_id = ses.ga_session_id
  ),
  monthly_counts AS (
    SELECT
      sent_month,
      id_account,
      COUNT(*) account_msgs,
      MIN(sent_day) first_sent_date,
      MAX(sent_day) last_sent_date
    FROM raw
    GROUP BY sent_month, id_account
  ),
  month_totals AS (
    SELECT
      sent_month,
      COUNT(*) total_msgs
    FROM raw
    GROUP BY sent_month
  )
SELECT
  FORMAT_DATE('%Y-%m', mc.sent_month) AS sent_month,
  mc.id_account,
  ROUND(account_msgs / total_msgs * 100, 2) sent_msg_percent_from_this_month,
  first_sent_date,
  last_sent_date
FROM monthly_counts mc
JOIN month_totals mt
  USING (sent_month);


-- Query the created view
SELECT
  *
FROM Students.v_Bobko_Aggregation
LIMIT 50;
