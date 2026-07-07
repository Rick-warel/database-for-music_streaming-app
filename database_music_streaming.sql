SET search_path TO app, public;

CREATE TYPE genre_type AS ENUM ('rock', 'pop', 'hip-hop', 'jazz', 'electronic', 'other');

-- Le Bloc Utilisateurs et Abonnements


CREATE TABLE IF NOT EXISTS artists (
	artist_id SERIAL PRIMARY KEY,
	artist_name VARCHAR (255) NOT NULL,
	biographie TEXT,
	country VARCHAR (255),
	genre VARCHAR(255),
	created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE albums (
	album_id SERIAL PRIMARY KEY,
	title VARCHAR (255) NOT NULL,
	artiste_id INTEGER REFERENCES artists(artist_id) ON DELETE CASCADE,
	released_at DATE
);

CREATE TABLE tracks (
	track_id SERIAL PRIMARY KEY,
	title VARCHAR(255) NOT NULL,
	album_id INTEGER NOT NULL REFERENCES albums(album_id) ON DELETE CASCADE,
	duration_ms INTEGER CHECK  (duration_ms > 0),
	genre genre_type NOT NULL,
	is_explicit BOOLEAN DEFAULT (FALSE),
	created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE track_artists (
	PRIMARY KEY (track_id, artist_id),
	track_id INTEGER NOT NULL REFERENCES tracks(track_id) ON DELETE CASCADE,
	artist_id INTEGER NOT NULL REFERENCES artists(artist_id) ON DELETE CASCADE,
	role VARCHAR (255) DEFAULT 'MAIN'
);

CREATE INDEX idx_albums_artist_id ON albums(artiste_id);
CREATE INDEX idx_tracks_album_id ON tracks(album_id);
CREATE INDEX idx_tracks_genre ON tracks(genre);
CREATE INDEX idx_track_artists_track ON track_artists(track_id);

--------------------------------------------------------------

CREATE TYPE subscription_type AS ENUM ('free', 'premium', 'family');

CREATE TABLE users (
	user_id SERIAL PRIMARY KEY,
	username VARCHAR(100) NOT NULL UNIQUE,
	email VARCHAR(100) NOT NULL UNIQUE,
	country VARCHAR(100),
	create_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE subscriptions (
	subscription_id SERIAL PRIMARY KEY,
	user_id INTEGER NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
	type subscription_type NOT NULL DEFAULT 'free',
	started_at TIMESTAMP NOT NULL DEFAULT NOW(),
	ended_at TIMESTAMP
);

CREATE TABLE listens (
	listen_id SERIAL PRIMARY KEY,
	user_id INTEGER NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
	track_id INTEGER NOT NULL REFERENCES tracks(track_id),
	listened_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_listens_user_id ON listens(user_id);
CREATE INDEX idx_listens_track_id ON listens(track_id);
CREATE INDEX idx_listens_listened_at ON listens(listened_at);

CREATE TABLE playlists (
	playlist_id SERIAL PRIMARY KEY,
	user_id INTEGER NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
	name VARCHAR(255) NOT NULL,
	create_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE playlist_tracks (
	playlist_id INTEGER NOT NULL REFERENCES playlists(playlist_id),
	user_id INTEGER NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
	name VARCHAR(255) NOT NULL,
	create_at TIMESTAMP NOT NULL DEFAULT NOW()
);


-- ============================================================================
-- 1. REMPLISSAGE DE LA TABLE: artists (10 lignes, genres variés)
-- ============================================================================
INSERT INTO artists (artist_name, biographie, country, genre) VALUES
('Youssou N''Dour', 'Icône de la musique sénégalaise et du Mbalax.', 'Sénégal', 'Mbalax'),
('Daft Punk', 'Pionniers français de la musique électronique mondiale.', 'France', 'Electronic'),
('Eminem', 'Légende du hip-hop américain originaire de Détroit.', 'USA', 'Hip-Hop'),
('Coldplay', 'Groupe de rock alternatif britannique formé à Londres.', 'UK', 'Rock'),
('Billie Eilish', 'Auteure-compositrice-interprète pop américaine.', 'USA', 'Pop'),
('Miles Davis', 'Compositeur et trompettiste de jazz de génie.', 'USA', 'Jazz'),
('Burna Boy', 'Géant de l''Afrobeats nigérian moderne.', 'Nigeria', 'Afrobeats'),
('Michael Jackson', 'Le Roi de la Pop.', 'USA', 'Pop'),
('Hans Zimmer', 'Compositeur légendaire de musiques de films.', 'Allemagne', 'Classical/Other'),
('Wizkid', 'Star internationale de la pop africaine.', 'Nigeria', 'Afrobeats');

-- ============================================================================
-- 2. REMPLISSAGE DE LA TABLE: albums (20 lignes, plusieurs par artiste)
-- ============================================================================
INSERT INTO albums (title, artiste_id, released_at) VALUES
-- Youssou N'Dour (ID 1)
('Egypt', 1, '2004-06-01'), ('History', 1, '2023-11-10'),
-- Daft Punk (ID 2)
('Discovery', 2, '2001-03-12'), ('Random Access Memories', 2, '2013-05-17'),
-- Eminem (ID 3)
('The Marshall Mathers LP', 3, '2000-05-23'), ('The Eminem Show', 3, '2002-05-26'),
-- Coldplay (ID 4)
('Parachutes', 4, '2000-07-10'), ('A Rush of Blood to the Head', 4, '2002-08-26'),
-- Billie Eilish (ID 5)
('When We All Fall Asleep...', 5, '2019-03-29'), ('Hit Me Hard and Soft', 5, '2024-05-17'),
-- Miles Davis (ID 6)
('Kind of Blue', 6, '1959-08-17'), ('Bitches Brew', 6, '1970-03-30'),
-- Burna Boy (ID 7)
('African Giant', 7, '2019-07-26'), ('Love, Damini', 7, '2022-07-08'),
-- Michael Jackson (ID 8)
('Thriller', 8, '1982-11-30'), ('Bad', 8, '1987-08-31'),
-- Hans Zimmer (ID 9)
('Inception OST', 9, '2010-07-13'), ('Interstellar OST', 9, '2014-11-17'),
-- Wizkid (ID 10)
('Made in Lagos', 10, '2020-10-30'), ('More Love, Less Ego', 10, '2022-11-11');

-- ============================================================================
-- 3. REMPLISSAGE DE LA TABLE: tracks (52 lignes, duration_ms > 0, ENUM respecté)
-- ============================================================================
INSERT INTO tracks (title, album_id, duration_ms, genre, is_explicit) VALUES
-- Album 1
('Egypt Intro', 1, 180000, 'other', FALSE), ('Bamba', 1, 245000, 'other', FALSE),
-- Album 2
('Birima', 2, 210000, 'other', FALSE), ('Sama Dom', 2, 230000, 'other', FALSE),
-- Album 3 (Discovery)
('One More Time', 3, 320000, 'electronic', FALSE), ('Aerodynamic', 3, 212000, 'electronic', FALSE), ('Harder, Better, Faster, Stronger', 3, 224000, 'electronic', FALSE),
-- Album 4 (RAM)
('Get Lucky', 4, 369000, 'electronic', FALSE), ('Instant Crush', 4, 337000, 'electronic', FALSE),
-- Album 5
('Stan', 5, 404000, 'hip-hop', TRUE), ('The Real Slim Shady', 5, 284000, 'hip-hop', TRUE),
-- Album 6
('Without Me', 6, 290000, 'hip-hop', TRUE), ('Sing for the Moment', 6, 340000, 'hip-hop', FALSE),
-- Album 7
('Yellow', 7, 269000, 'rock', FALSE), ('Trouble', 7, 270000, 'rock', FALSE),
-- Album 8
('Clocks', 8, 307000, 'rock', FALSE), ('The Scientist', 8, 309000, 'rock', FALSE),
-- Album 9
('Bad Guy', 9, 194000, 'pop', FALSE), ('Bury a Friend', 9, 193000, 'pop', FALSE),
-- Album 10
('Lunch', 10, 180000, 'pop', TRUE), ('Chihiro', 10, 303000, 'pop', FALSE),
-- Album 11
('So What', 11, 562000, 'jazz', FALSE), ('Freddie Freeloader', 11, 586000, 'jazz', FALSE),
-- Album 12
('Pharaoh''s Dance', 12, 1204000, 'jazz', FALSE), ('Miles Runs the Voodoo Down', 12, 843000, 'jazz', FALSE),
-- Album 13
('On the Low', 13, 185000, 'other', FALSE), ('Anybody', 13, 189000, 'other', FALSE),
-- Album 14
('Last Last', 14, 172000, 'other', TRUE), ('Kilometre', 14, 153000, 'other', FALSE),
-- Album 15
('Wanna Be Startin'' Somethin''', 15, 363000, 'pop', FALSE), ('Thriller Single', 15, 357000, 'pop', FALSE), ('Beat It', 15, 258000, 'pop', FALSE),
-- Album 16
('Bad Track', 16, 247000, 'pop', FALSE), ('Smooth Criminal', 16, 257000, 'pop', FALSE),
-- Album 17
('Time', 17, 275000, 'other', FALSE), ('Dream Is Collapsing', 17, 143000, 'other', FALSE),
-- Album 18
('Stay', 18, 412000, 'other', FALSE), ('No Time for Caution', 18, 242000, 'other', FALSE),
-- Album 19
('Ginger', 19, 196000, 'pop', FALSE), ('Essence', 19, 248000, 'pop', FALSE),
-- Album 20
('Bad To Me', 20, 172000, 'pop', FALSE), ('2 Framed', 20, 191000, 'pop', FALSE);

-- Compléments pour atteindre les 50+ morceaux (Tracks 43 à 52)
INSERT INTO tracks (title, album_id, duration_ms, genre) VALUES
('Something About Us', 3, 231000, 'electronic'),
('Lose Yourself', 5, 326000, 'hip-hop'),
('In My Place', 8, 228000, 'rock'),
('Billie Jean', 15, 294000, 'pop'),
('Mami Wata', 1, 215000, 'other'),
('Digital Love', 3, 298000, 'electronic'),
('Mockingbird', 6, 251000, 'hip-hop'),
('Fix You', 8, 295000, 'rock'),
('Ocean Eyes', 9, 200000, 'pop'),
('Blue in Green', 11, 337000, 'jazz');

-- ============================================================================
-- 4. REMPLISSAGE DE LA TABLE: users (20 lignes, emails uniques)
-- ============================================================================
INSERT INTO users (username, email, country) VALUES
('moussa_dev', 'moussa@gmail.com', 'Sénégal'),
('fatou_codes', 'fatou@yahoo.fr', 'Sénégal'),
('amadou_z', 'amadou@outlook.com', 'Sénégal'),
('khady_music', 'khady@gmail.com', 'Mali'),
('john_doe', 'john.doe@gmail.com', 'USA'),
('alice_b', 'alice@orange.sn', 'Sénégal'),
('omar_peintre', 'omar@gmail.com', 'Sénégal'),
('ainsi_soit_il', 'asi@gmail.com', 'France'),
('ibrahima_dj', 'ibra@hotmail.com', 'Sénégal'),
('amina_pop', 'amina@gmail.com', 'Côte d''Ivoire'),
('cheikh_tech', 'cheikh@gmail.com', 'Sénégal'),
('penda_art', 'penda@gmail.com', 'Sénégal'),
('sam_rock', 'sam@gmail.com', 'UK'),
('dj_boub''s', 'boubs@gmail.com', 'Sénégal'),
('awa_ux', 'awa@gmail.com', 'Sénégal'),
('modou_gl', 'modou@gmail.com', 'Sénégal'),
('coumba_voice', 'coumba@gmail.com', 'Sénégal'),
('alioune_b', 'alioune@gmail.com', 'Sénégal'),
('saliou_m', 'saliou@gmail.com', 'Sénégal'),
('diarra_rap', 'diarra@gmail.com', 'Mali');

-- ============================================================================
-- 5. REMPLISSAGE DE LA TABLE: subscriptions (20 lignes, étalées sur 3+ mois)
-- ============================================================================
INSERT INTO subscriptions (user_id, type, started_at, ended_at) VALUES
(1, 'premium', '2026-01-01 10:00:00', NULL),
(2, 'family', '2026-01-15 14:30:00', NULL),
(3, 'free', '2026-01-20 09:00:00', '2026-02-20 09:00:00'),
(4, 'premium', '2026-02-01 08:15:00', NULL),
(5, 'premium', '2026-02-14 18:00:00', NULL),
(6, 'family', '2026-02-28 11:00:00', NULL),
(7, 'free', '2026-03-01 12:00:00', NULL),
(8, 'premium', '2026-03-10 19:45:00', NULL),
(9, 'premium', '2026-03-22 15:30:00', NULL),
(10, 'family', '2026-04-01 07:00:00', NULL),
(11, 'free', '2026-04-05 14:20:00', '2026-05-05 14:20:00'),
(12, 'premium', '2026-04-18 21:10:00', NULL),
(13, 'premium', '2026-05-01 10:00:00', NULL),
(14, 'family', '2026-05-12 16:40:00', NULL),
(15, 'free', '2026-05-25 11:15:00', NULL),
(16, 'premium', '2026-06-01 09:00:00', NULL),
(17, 'premium', '2026-06-14 13:00:00', NULL),
(18, 'family', '2026-06-20 17:45:00', NULL),
(19, 'free', '2026-06-28 18:30:00', NULL),
(20, 'premium', '2026-07-01 11:20:00', NULL);

-- ============================================================================
-- 6. REMPLISSAGE DE LA TABLE: listens (200 lignes, étalées sur 4 semaines)
-- Semaine 1 : 2026-06-01 à 2026-06-07 (50 écoutes)
-- Semaine 2 : 2026-06-08 à 2026-06-14 (50 écoutes)
-- Semaine 3 : 2026-06-15 à 2026-06-21 (50 écoutes)
-- Semaine 4 : 2026-06-22 à 2026-06-28 (50 écoutes)
-- ============================================================================
DO $$
DECLARE
    u_id INT;
    t_id INT;
    base_date TIMESTAMP;
    i INT;
BEGIN
    -- Génération Semaine 1
    base_date := '2026-06-01 08:00:00';
    FOR i IN 1..50 LOOP
        u_id := (i % 20) + 1;
        t_id := (i % 52) + 1;
        INSERT INTO listens (user_id, track_id, listened_at) 
        VALUES (u_id, t_id, base_date + (i * INTERVAL '3 hours'));
    END LOOP;

    -- Génération Semaine 2
    base_date := '2026-06-08 08:00:00';
    FOR i IN 1..50 LOOP
        u_id := ((i+3) % 20) + 1;
        t_id := ((i+7) % 52) + 1;
        INSERT INTO listens (user_id, track_id, listened_at) 
        VALUES (u_id, t_id, base_date + (i * INTERVAL '3 hours'));
    END LOOP;

    -- Génération Semaine 3
    base_date := '2026-06-15 08:00:00';
    FOR i IN 1..50 LOOP
        u_id := ((i+5) % 20) + 1;
        t_id := ((i+11) % 52) + 1;
        INSERT INTO listens (user_id, track_id, listened_at) 
        VALUES (u_id, t_id, base_date + (i * INTERVAL '3 hours'));
    END LOOP;

    -- Génération Semaine 4
    base_date := '2026-06-22 08:00:00';
    FOR i IN 1..50 LOOP
        u_id := ((i+9) % 20) + 1;
        t_id := ((i+13) % 52) + 1;
        INSERT INTO listens (user_id, track_id, listened_at) 
        VALUES (u_id, t_id, base_date + (i * INTERVAL '3 hours'));
    END LOOP;
END $$;