SET search_path TO app, public;

-------------------------------------------------------------------------
-----------------------Top 10 artistes par écoutes-----------------------
-------------------------------------------------------------------------

SELECT a.artist_id , a.artist_name, COUNT(l.listen_id) as Total_ecoute
FROM listens l
JOIN tracks t ON l.track_id = t.track_id
JOIN albums al ON t.album_id = al.album_id
JOIN artists a ON al.artiste_id = a.artist_id
GROUP BY a.artist_id, a.artist_name
ORDER BY Total_ecoute DESC
LIMIT 10
;

-------------------------------------------------------------------------
--------------   Taux de rétention des abonnés par cohorte   ------------
-------------------------------------------------------------------------

WITH cohorte_par_mois AS (
	SELECT cohort_month, nb_tota_users, nb_users_actif
	FROM(
	SELECT COUNT(user_id) as nb_tota_users, DATE_TRUNC('month', started_at) as cohort_month
	FROM subscriptions
	GROUP BY cohort_month
	ORDER BY cohort_month
	) JOIN (
	SELECT COUNT(user_id) as nb_users_actif, DATE_TRUNC('month', started_at) as cohort_month
	FROM subscriptions
	WHERE ended_at IS NULL
	GROUP BY cohort_month
	ORDER BY cohort_month
	) USING (cohort_month)
) SELECT cohort_month, nb_tota_users, nb_users_actif, (nb_users_actif * 100 / nb_tota_users) AS retention_rate
FROM cohorte_par_mois


-------------------------------------------------------------------------
----------   Tracks écoutées par 80%+ des utilisateurs actifs   ---------
-------------------------------------------------------------------------

SELECT user_id
FROM subscriptions
WHERE ended_at IS NULL;

SELECT t.track_id , title , COUNT (DISTINCT l.user_id) as nbr_user_unique
FROM listens l  JOIN tracks t ON t.track_id = l.track_id
GROUP BY t.track_id , title
ORDER BY nbr_user_unique DESC




-- Q3 : Tracks écoutées par au moins 80% des utilisateurs actifs (30 derniers jours)

SELECT
    t.track_id,
    t.title,
    COUNT(DISTINCT l.user_id)  AS unique_listeners,
    (
        SELECT COUNT(DISTINCT user_id)
        FROM listens
        WHERE listened_at >= NOW() - INTERVAL '30 days'
    ) AS active_user_count
FROM listens l
JOIN tracks t ON l.track_id = t.track_id
WHERE l.listened_at >= NOW() - INTERVAL '30 days'
GROUP BY t.track_id, t.title
HAVING COUNT(DISTINCT l.user_id) >= 0.1 * (
    SELECT COUNT(DISTINCT user_id)
    FROM listens
    WHERE listened_at >= NOW() - INTERVAL '30 days'
)
ORDER BY unique_listeners DESC;










