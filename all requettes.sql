SET search_path TO app, public;

-- Q1 : Top 10 artistes par écoutes ce mois-ci

SELECT
    RANK() OVER (ORDER BY COUNT(l.listen_id) DESC) AS rank,
    a.artist_name,
    COUNT(l.listen_id) AS total_listens
FROM listens l
JOIN tracks t         ON l.track_id   = t.track_id
JOIN track_artists ta ON t.track_id   = ta.track_id
JOIN artists a        ON ta.artist_id = a.artist_id
WHERE DATE_TRUNC('month', l.listened_at) = DATE_TRUNC('month', NOW())
GROUP BY a.artist_id, a.artist_name
ORDER BY total_listens DESC
LIMIT 10;

------------------------------------------------------------
-- Q2 : Taux de rétention des abonnés par mois d'inscription
------------------------------------------------------------
WITH cohortes AS (
    SELECT
        DATE_TRUNC('month', s.started_at) AS cohort_month,
        COUNT(DISTINCT s.user_id)          AS total_users
    FROM subscriptions s
    GROUP BY cohort_month
),
actifs AS (
    SELECT
        DATE_TRUNC('month', s.started_at) AS cohort_month,
        COUNT(DISTINCT s.user_id)          AS active_users
    FROM subscriptions s
    WHERE s.ended_at IS NULL
    GROUP BY cohort_month
)
SELECT
    c.cohort_month,
    c.total_users,
    COALESCE(a.active_users, 0)                                        AS active_users,
    ROUND(COALESCE(a.active_users, 0) * 100.0 / c.total_users, 2)     AS retention_rate
FROM cohortes c
LEFT JOIN actifs a ON c.cohort_month = a.cohort_month
ORDER BY c.cohort_month;


-- Q3 : Tracks écoutées par au moins 80% des utilisateurs actifs (30 derniers jours)
SELECT
    t.track_id,
    t.title,
    COUNT(DISTINCT l.user_id) AS unique_listeners,
    (
        SELECT COUNT(DISTINCT user_id)
        FROM listens
        WHERE listened_at >= NOW() - INTERVAL '30 days'
    ) AS active_user_count
FROM listens l
JOIN tracks t ON l.track_id = t.track_id
WHERE l.listened_at >= NOW() - INTERVAL '30 days'
GROUP BY t.track_id, t.title
HAVING COUNT(DISTINCT l.user_id) >= 0.8 * (
    SELECT COUNT(DISTINCT user_id)
    FROM listens
    WHERE listened_at >= NOW() - INTERVAL '30 days'
)
ORDER BY unique_listeners DESC;



-- Q4 : Écoutes semaine N vs N-1 par genre avec LAG()
WITH weekly AS (
    SELECT
        DATE_TRUNC('week', l.listened_at) AS week,
        t.genre,
        COUNT(l.listen_id) AS listens_this_week
    FROM listens l
    JOIN tracks t ON l.track_id = t.track_id
    GROUP BY week, t.genre
)
SELECT
    week,
    genre,
    listens_this_week,
    LAG(listens_this_week) OVER (PARTITION BY genre ORDER BY week) AS listens_prev_week,
    ROUND(
        (listens_this_week - LAG(listens_this_week) OVER (PARTITION BY genre ORDER BY week))
        * 100.0
        / NULLIF(LAG(listens_this_week) OVER (PARTITION BY genre ORDER BY week), 0),
    2) AS evolution_pct
FROM weekly
ORDER BY genre, week;



-- Q5 : Top 3 tracks par genre ce mois-ci
WITH ranked AS (
    SELECT
        t.genre,
        t.title,
        COUNT(l.listen_id) AS total_listens,
        RANK() OVER (PARTITION BY t.genre ORDER BY COUNT(l.listen_id) DESC) AS rank
    FROM listens l
    JOIN tracks t ON l.track_id = t.track_id
    WHERE DATE_TRUNC('month', l.listened_at) = DATE_TRUNC('month', NOW())
    GROUP BY t.genre, t.track_id, t.title
)
SELECT
    genre,
    rank,
    title,
    total_listens
FROM ranked
WHERE rank <= 3
ORDER BY genre, rank;