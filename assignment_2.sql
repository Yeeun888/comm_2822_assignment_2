--------------------------
-- OLD DATABASE CLEANUP --
--------------------------

-- Current SQL Version (https://stackoverflow.com/questions/65857333/query-to-get-oracle-db-version)
SELECT
    version
FROM
    product_component_version
WHERE
    product LIKE 'Oracle Database%';

-- DANGEROUS CODE BELOW. DROPS ALL TABLES 
-- DO NOT RUN WITH ASSIGNMENT CODE

-- BEGIN
--   FOR c IN (SELECT table_name 
--            FROM user_tables) LOOP
--      EXECUTE IMMEDIATE 'DROP TABLE ' || c.table_name || ' CASCADE CONSTRAINTS';
--   END LOOP;
-- END;

------------------------------
-- ORACLE DATABASE CREATION --
------------------------------

-- Creation order starts from attributes with no dependents to those it's dependents
-- based of team ERD in presentation appendix

-- All with logins users, rightholders, merchants
CREATE TABLE Users (
    user_id             VARCHAR2(36),
    username            VARCHAR2(256) NOT NULL UNIQUE,
    email               VARCHAR2(256) NOT NULL UNIQUE,
    password_hash       VARCHAR2(256) NOT NULL,
    first_name          VARCHAR2(256) NOT NULL,
    last_name           VARCHAR2(256) NOT NULL,
    profile_picture_url VARCHAR2(256),
    created_at          TIMESTAMP DEFAULT current_timestamp NOT NULL,
    last_login          TIMESTAMP,
    
    CONSTRAINT last_login_check CHECK (last_login >= created_at),
    PRIMARY KEY (user_id)
);

CREATE TABLE rightholders (
    rightholder_id     VARCHAR2(36),
    rightholder_signin VARCHAR(256) NOT NULL UNIQUE,
    password_hash      VARCHAR(256) NOT NULL,
    rightholder_name   VARCHAR2(256) NOT NULL,
    contact_name       VARCHAR2(256) NOT NULL,
    business_email     VARCHAR2(256) NOT NULL,
    billing_address    VARCHAR2(256),
    tax_id_number      NUMBER,
    
    PRIMARY KEY ( rightholder_id )
);

CREATE TABLE merchants (
    merchant_id     VARCHAR2(36),
    merchant_signin VARCHAR2(256) NOT NULL UNIQUE,
    password_hash   VARCHAR2(256) NOT NULL,
    business_name   VARCHAR2(256) NOT NULL,
    contact_name    VARCHAR2(256),
    business_email  VARCHAR2(256) NOT NULL,
    billing_address VARCHAR2(256),
    
    PRIMARY KEY ( merchant_id )
);

-------------------------------- ADS SYSTEM ------------------------------------
CREATE TABLE Ads (
    ad_id               VARCHAR2(36),
    merchant_id         VARCHAR2(36) NOT NULL,
    redirect_link       VARCHAR2(256) NOT NULL,
    ad_type             VARCHAR2(10) NOT NULL,
    content_url         VARCHAR2(256) NOT NULL,
    CONSTRAINT merchant_ads_fk FOREIGN KEY (merchant_id) REFERENCES Merchants (merchant_id),
    
    PRIMARY KEY ( ad_id )
);

CREATE TABLE Campaign (
    campaign_id VARCHAR2(36),
    user_id     VARCHAR2(36) NOT NULL,
    start_date  TIMESTAMP NOT NULL,
    end_date    TIMESTAMP NOT NULL,
    CONSTRAINT campaign_user_fk FOREIGN KEY ( user_id ) REFERENCES USERS ( user_id ),
    
    PRIMARY KEY ( campaign_id )
);

-- Composite entity for ads and campaign
CREATE TABLE CurrentAds (
    ad_id               VARCHAR2(36),
    campaign_id         VARCHAR2(36),
    
    CONSTRAINT ad_fk FOREIGN KEY (ad_id) REFERENCES Ads (ad_id),
    CONSTRAINT campaign_fk FOREIGN KEY (campaign_id) REFERENCES Campaign (campaign_id),
    
    PRIMARY KEY (ad_id, campaign_id)
);

CREATE TABLE Category (
    ad_category_id  VARCHAR2(36),
    description     VARCHAR2(256),
    
    PRIMARY KEY (ad_category_id)
);

CREATE TABLE AdCategory (
    ad_id           VARCHAR2(36),
    ad_category_id  VARCHAR2(36),
    
    CONSTRAINT adcategory_category_fk FOREIGN KEY (ad_category_id) 
        REFERENCES Category (ad_category_id),
    CONSTRAINT ac_ad_id_fk FOREIGN KEY (ad_id) 
        REFERENCES Ads (ad_id),

    PRIMARY KEY ( ad_id, ad_category_id )
);

CREATE TABLE Location (
    local_ad_group_id VARCHAR2(36),
    description        VARCHAR2(256),
    timezone           VARCHAR2(256),
    
    PRIMARY KEY ( local_ad_group_id )
);

CREATE TABLE AdLocation (
    ad_id             VARCHAR2(36),
    local_ad_group_id VARCHAR2(36),
    timezone          VARCHAR2(256),
    
    CONSTRAINT adlocation_location_fk FOREIGN KEY (local_ad_group_id) 
        REFERENCES Location (local_ad_group_id),
    CONSTRAINT al_ad_id_fk FOREIGN KEY (ad_id) 
        REFERENCES ads (ad_id),

        
    PRIMARY KEY (ad_id, local_ad_group_id)
);

CREATE TABLE AdStats (
    ad_stat_id           VARCHAR2(36),
    merchant_id          VARCHAR2(36) NOT NULL,
    ad_id                VARCHAR2(36) NOT NULL,
    start_time           TIMESTAMP NOT NULL,
    end_time             TIMESTAMP NOT NULL,
    impressions          NUMBER DEFAULT 0 NOT NULL,
    clicks               NUMBER DEFAULT 0 NOT NULL,
    cost_per_click       NUMBER DEFAULT 1 NOT NULL,
    cost_per_impression  NUMBER(10,5) DEFAULT '0.005' NOT NULL,
    
    CONSTRAINT adstats_merchant_fk FOREIGN KEY (merchant_id) 
        REFERENCES Merchants (merchant_id),
    CONSTRAINT adstats_ad_id_fk FOREIGN KEY (ad_id) 
        REFERENCES Ads (ad_id),
        
    PRIMARY KEY ( ad_stat_id )
);

------------------------------ MERCHANT SYSTEM ---------------------------------
CREATE TABLE MerchantInvoice (
    merchant_payment_id  NUMBER,
    ad_stat_id           VARCHAR2(36),
    payment_date         TIMESTAMP,
    payment_account      NUMBER,
    status               VARCHAR2(20) CHECK (status IN ('PENDING', 'COMPLETED', 'FAILED')),

    CONSTRAINT merchantinvoice_adstat_fk FOREIGN KEY (ad_stat_id)
        REFERENCES AdStats (ad_stat_id),
        
    PRIMARY KEY ( merchant_payment_id )
);

CREATE TABLE MerchantPayments (
    merchant_id          VARCHAR2(36),
    merchant_payment_id  NUMBER,

    CONSTRAINT merchantpayments_merchant_fk FOREIGN KEY (merchant_id)
        REFERENCES Merchants (merchant_id),
    CONSTRAINT merchantpayment_merchant_payment_fk FOREIGN KEY (merchant_payment_id)
        REFERENCES MerchantInvoice (merchant_payment_id),

    PRIMARY KEY (merchant_id, merchant_payment_id)
);

-------------------------------- USER SYSTEM -----------------------------------
CREATE TABLE UserPlaylist (
    playlist_id          VARCHAR2(36),
    user_id              VARCHAR2(36) NOT NULL,
    playlist_name        VARCHAR2(256) NOT NULL,
    playlist_description VARCHAR2(256),
    image_url            VARCHAR2(256) NOT NULL,
    created_at           TIMESTAMP,
    CONSTRAINT user_playlist_fk FOREIGN KEY (user_id) REFERENCES USERS (user_id),
    
    PRIMARY KEY ( playlist_id )
);

-------------------------------- SONG SYSTEM -----------------------------------
CREATE TABLE Genre (
    genre_id          VARCHAR2(36),
    genre_name        VARCHAR2(256) NOT NULL UNIQUE,
    genre_description VARCHAR2(256) NOT NULL,
    
    PRIMARY KEY ( genre_id )
);

CREATE TABLE Artists (
    artist_id   VARCHAR2(36),
    artist_name VARCHAR2(256) NOT NULL,
    picture_url VARCHAR2(256) NOT NULL,
    biography   VARCHAR2(256) NOT NULL,
    created_at  TIMESTAMP DEFAULT current_timestamp NOT NULL,
    updated_at  TIMESTAMP,
    
    PRIMARY KEY ( artist_id )
);

CREATE TABLE Albums (
    album_id           VARCHAR2(36) PRIMARY KEY,
    artist_id          VARCHAR2(36),
    genre_id           VARCHAR2(36),
    album_name         VARCHAR2(256) NOT NULL,
    album_duration     NUMBER CONSTRAINT duration_check CHECK (album_duration > 0),
    
    CONSTRAINT albums_artist_fk FOREIGN KEY (artist_id)
        REFERENCES Artists (artist_id),
    CONSTRAINT albums_genre_fk FOREIGN KEY (genre_id)
        REFERENCES Genre (genre_id)
);

CREATE TABLE ArtistCollaboration (
    artist_id          VARCHAR2(36),
    album_id           VARCHAR2(36),
        
    CONSTRAINT ac_artist_fk FOREIGN KEY (artist_id)
        REFERENCES Artists (artist_id),
    CONSTRAINT ac_album_fk FOREIGN KEY (album_id)
        REFERENCES Albums (album_id),
        
    PRIMARY KEY (artist_id, album_id)
);

CREATE TABLE Songs (
    song_id            VARCHAR2(36),
    genre_id           VARCHAR2(256),
    album_id           VARCHAR2(36),
    right_holder_id    VARCHAR2(36),
    song_title         VARCHAR2(256) NOT NULL,
    song_duration      NUMBER CONSTRAINT song_duration_check CHECK (song_duration > 0),
    release_date       VARCHAR2(36),
    
    CONSTRAINT songs_genre_fk FOREIGN KEY (genre_id)
        REFERENCES Genre (genre_id),
    CONSTRAINT songs_album_fk FOREIGN KEY (album_id)
        REFERENCES Albums (album_id),
    CONSTRAINT songs_rightholder_fk FOREIGN KEY (right_holder_id)
        REFERENCES RightHolders (rightholder_id),
        
    PRIMARY KEY ( song_id )
);

CREATE TABLE SongCollaborations (
    song_id            VARCHAR2(36),
    artists_id         VARCHAR2(36),
        
    CONSTRAINT sc_song_fk FOREIGN KEY (song_id)
        REFERENCES Songs (song_id),
    CONSTRAINT sc_artist_fk FOREIGN KEY (artists_id)
        REFERENCES Artists (artist_id),
        
    PRIMARY KEY (song_id, artists_id)
);

---------------------------- RIGHTHOLDERS SYSTEM -------------------------------
CREATE TABLE SongStats (
    songstat_id     VARCHAR2(36),
    rightholder_id  VARCHAR2(36),
    song_id         VARCHAR2(256),
    cost_per_play   NUMBER(10,5) NOT NULL,
    likes           NUMBER DEFAULT 0 CONSTRAINT likes_check CHECK (likes > 0),
    shares          NUMBER DEFAULT 0 NOT NULL,
    start_date      TIMESTAMP,
    end_date        TIMESTAMP,

    CONSTRAINT songstats_rightholder_fk FOREIGN KEY (rightholder_id)
        REFERENCES Rightholders (rightholder_id),
    CONSTRAINT songstat_song_id_fk FOREIGN KEY (song_id) 
        REFERENCES Songs (song_id),

    PRIMARY KEY (songstat_id)
);

CREATE TABLE RightholderInvoice (
    rightholder_payment_id VARCHAR2(36),
    songstat_id            VARCHAR2(36),
    payment_date           TIMESTAMP NOT NULL,
    payment_account        NUMBER NOT NULL,
    status                 VARCHAR2(20),

    CONSTRAINT rightholderinvoice_songstat_fk FOREIGN KEY (songstat_id)
        REFERENCES SongStats (songstat_id),

    CONSTRAINT rightholderinvoice_status_ck CHECK (status IN ('PENDING', 'PAID', 'FAILED')),
    
    PRIMARY KEY ( rightholder_payment_id )
);

CREATE TABLE RightholderPayment (
    rightholder_id         VARCHAR2(36),
    rightholder_payment_id VARCHAR2(256),

    CONSTRAINT rightholderpayment_rightholder_fk FOREIGN KEY (rightholder_id)
        REFERENCES Rightholders (rightholder_id),
    CONSTRAINT rightholderpayment_rightholder_payment_fk FOREIGN KEY (rightholder_payment_id)
        REFERENCES RightholderInvoice (rightholder_payment_id),

    PRIMARY KEY (rightholder_id, rightholder_payment_id)
);


------------------------- CROSS SYSTEM DEPENDENTS ------------------------------
CREATE TABLE PlaylistSongs (
    playlist_id VARCHAR2(36),
    song_id VARCHAR2(36),
    
    CONSTRAINT ps_playlist_id_fk FOREIGN KEY (playlist_id) 
        REFERENCES UserPlaylist (playlist_id),
    CONSTRAINT ps_song_id_fk FOREIGN KEY (song_id)
        REFERENCES Songs (song_id),
        
    PRIMARY KEY ( playlist_id, song_id )
);

-------------------------
-- MOCK DATA INSERTION --
-------------------------
-------------------- Mock Data for Users Table -----------------------------------
INSERT INTO Users (user_id, username, email, password_hash, first_name, last_name, profile_picture_url, created_at, last_login)
VALUES
('10001', 'BombardiloCrocodilo', 'bombardilocrocodilo@example.com', 'hashed_pw_01', 'Bombardilo', 'Crocodilo', 'http://example.com/pic1.jpg', TO_TIMESTAMP('2023-01-01 10:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2023-01-02 10:00:00', 'YYYY-MM-DD HH24:MI:SS')),
('10002', 'janedoe', 'janedoe@example.com', 'hashed_pw_02', 'Jane', 'Doe', 'http://example.com/pic2.jpg', TO_TIMESTAMP('2023-02-01 12:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2023-02-02 13:00:00', 'YYYY-MM-DD HH24:MI:SS')),
('10003', 'alexsmith', 'alexsmith@example.com', 'hashed_pw_03', 'Alex', 'Smith', 'http://example.com/pic3.jpg', TO_TIMESTAMP('2023-03-01 08:30:00', 'YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2023-03-01 10:00:00', 'YYYY-MM-DD HH24:MI:SS')),
('10004', 'maryjane', 'maryjane@example.com', 'hashed_pw_04', 'Mary', 'Jane', 'http://example.com/pic4.jpg', TO_TIMESTAMP('2023-03-10 11:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2023-03-11 12:00:00', 'YYYY-MM-DD HH24:MI:SS')),
('10005', 'dannyboy', 'dannyboy@example.com', 'hashed_pw_05', 'Danny', 'Boy', 'http://example.com/pic5.jpg', TO_TIMESTAMP('2023-04-01 09:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2023-04-01 10:00:00', 'YYYY-MM-DD HH24:MI:SS')),
('10006', 'lucaslee', 'lucaslee@example.com', 'hashed_pw_06', 'Lucas', 'Lee', 'http://example.com/pic6.jpg', TO_TIMESTAMP('2023-04-10 07:45:00', 'YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2023-04-10 08:00:00', 'YYYY-MM-DD HH24:MI:SS')),
('10007', 'bobbrown', 'bobbrown@example.com', 'hashed_pw_07', 'Bob', 'Brown', 'http://example.com/pic7.jpg', TO_TIMESTAMP('2023-05-01 06:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2023-05-01 06:30:00', 'YYYY-MM-DD HH24:MI:SS')),
('10008', 'sallyfield', 'sallyfield@example.com', 'hashed_pw_08', 'Sally', 'Field', 'http://example.com/pic8.jpg', TO_TIMESTAMP('2023-05-05 13:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2023-05-05 14:00:00', 'YYYY-MM-DD HH24:MI:SS')),
('10009', 'mattwhite', 'mattwhite@example.com', 'hashed_pw_09', 'Matt', 'White', 'http://example.com/pic9.jpg', TO_TIMESTAMP('2023-06-01 11:15:00', 'YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2023-06-01 12:00:00', 'YYYY-MM-DD HH24:MI:SS')),
('10010', 'emilygreen', 'emilygreen@example.com', 'hashed_pw_10', 'Emily', 'Green', 'http://example.com/pic10.jpg', TO_TIMESTAMP('2023-06-10 10:30:00', 'YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2023-06-10 11:00:00', 'YYYY-MM-DD HH24:MI:SS')),
('10011', 'michaelblue', 'michaelblue@example.com', 'hashed_pw_11', 'Michael', 'Blue', 'http://example.com/pic11.jpg', TO_TIMESTAMP('2023-07-01 09:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2023-07-02 09:30:00', 'YYYY-MM-DD HH24:MI:SS')),
('10012', 'rachelgray', 'rachelgray@example.com', 'hashed_pw_12', 'Rachel', 'Gray', 'http://example.com/pic12.jpg', TO_TIMESTAMP('2023-07-15 08:15:00', 'YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2023-07-15 09:00:00', 'YYYY-MM-DD HH24:MI:SS')),
('10013', 'nathanclark', 'nathanclark@example.com', 'hashed_pw_13', 'Nathan', 'Clark', 'http://example.com/pic13.jpg', TO_TIMESTAMP('2023-08-01 07:45:00', 'YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2023-08-01 08:30:00', 'YYYY-MM-DD HH24:MI:SS')),
('10014', 'lisajones', 'lisajones@example.com', 'hashed_pw_14', 'Lisa', 'Jones', 'http://example.com/pic14.jpg', TO_TIMESTAMP('2023-08-10 06:30:00', 'YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2023-08-10 07:00:00', 'YYYY-MM-DD HH24:MI:SS')),
('10015', 'kevinhall', 'kevinhall@example.com', 'hashed_pw_15', 'Kevin', 'Hall', 'http://example.com/pic15.jpg', TO_TIMESTAMP('2023-09-01 12:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2023-09-01 13:00:00', 'YYYY-MM-DD HH24:MI:SS')),
('10016', 'meganhill', 'meganhill@example.com', 'hashed_pw_16', 'Megan', 'Hill', 'http://example.com/pic16.jpg', TO_TIMESTAMP('2023-09-10 11:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2023-09-10 11:30:00', 'YYYY-MM-DD HH24:MI:SS')),
('10017', 'steveblack', 'steveblack@example.com', 'hashed_pw_17', 'Steve', 'Black', 'http://example.com/pic17.jpg', TO_TIMESTAMP('2023-10-01 14:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2023-10-01 15:00:00', 'YYYY-MM-DD HH24:MI:SS')),
('10018', 'oliviabrown', 'oliviabrown@example.com', 'hashed_pw_18', 'Olivia', 'Brown', 'http://example.com/pic18.jpg', TO_TIMESTAMP('2023-10-15 16:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2023-10-15 16:30:00', 'YYYY-MM-DD HH24:MI:SS')),
('10019', 'ethanwilliams', 'ethanwilliams@example.com', 'hashed_pw_19', 'Ethan', 'Williams', 'http://example.com/pic19.jpg', TO_TIMESTAMP('2023-11-01 09:30:00', 'YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2023-11-01 10:30:00', 'YYYY-MM-DD HH24:MI:SS')),
('10020', 'sophiamiller', 'sophiamiller@example.com', 'hashed_pw_20', 'Sophia', 'Miller', 'http://example.com/pic20.jpg', TO_TIMESTAMP('2023-11-15 10:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2023-11-15 11:00:00', 'YYYY-MM-DD HH24:MI:SS'));

---------------------- Mock Data for RightHolders Table --------------------------------
INSERT INTO rightholders (
    rightholder_id,
    rightholder_signin,
    password_hash,
    rightholder_name,
    contact_name,
    business_email,
    billing_address,
    tax_id_number
) VALUES (
    'RH-001',
    'sony.music@signin.com',
    'hashed_pw_1a2b3c4d',
    'Sony Music Entertainment',
    'Alice Tan',
    'contact@sonymusic.com',
    '25 Madison Ave, New York, NY',
    123456789
);

INSERT INTO rightholders (
    rightholder_id,
    rightholder_signin,
    password_hash,
    rightholder_name,
    contact_name,
    business_email,
    billing_address,
    tax_id_number
) VALUES (
    'RH-002',
    'universal.group@signin.com',
    'hashed_pw_2b3c4d5e',
    'Universal Music Group',
    'Brian Lee',
    'support@umusic.com',
    '2220 Colorado Ave, Santa Monica, CA',
    987654321
);

INSERT INTO rightholders (
    rightholder_id,
    rightholder_signin,
    password_hash,
    rightholder_name,
    contact_name,
    business_email,
    billing_address,
    tax_id_number
) VALUES (
    'RH-003',
    'electrobeats@signin.com',
    'hashed_pw_3c4d5e6f',
    'ElectroBeats Ltd.',
    'Sasha Ivanov',
    'info@electrobeats.com',
    '99 Synth Street, Berlin, Germany',
    837291045
);

---------------------- Mock Data for Merchants Table --------------------------------
INSERT INTO merchants (
    merchant_id,
    merchant_signin,
    password_hash,
    business_name,
    contact_name,
    business_email,
    billing_address
) VALUES
(
    'c1a2b3d4-e5f6-7890-abcd-1234567890aa',
    'urbanthreads_login',
    '5f4dcc3b5aa765d61d8327deb882cf99', -- mock MD5 for 'password'
    'Urban Threads Co.',
    'Ava Carter',
    'support@urbanthreads.com',
    '12 Fabric Lane, Garment District, Lalaland'
),
(
    'c2b3c4d5-e6f7-8901-bcda-2345678901bb',
    'linenloft_signin',
    'e99a18c428cb38d5f260853678922e03', -- mock MD5 for 'abc123'
    'Linen Loft Ltd.',
    'Ethan Walker',
    'contact@linenloft.la',
    '45 Stitch Ave, Weaveton, Lalaland'
),
(
    'c3c4d5e6-f7g8-9012-cdab-3456789012cc',
    'denimdock_login',
    'd8578edf8458ce06fbc5bb76a58c5ca4', -- mock MD5 for 'qwerty'
    'Denim Dock',
    'Olivia Nguyen',
    'info@denimdock.la',
    '89 Indigo Blvd, Threadsville, Lalaland'
),
(
    'c4d5e6f7-g8h9-0123-dabc-4567890123dd',
    'cottoncouture_store',
    '25f9e794323b453885f5181f1b624d0b', -- mock MD5 for '123456789'
    'Cotton Couture',
    'Jackson Patel',
    'admin@cottoncouture.co.la',
    '101 Cotton Row, Style City, Lalaland'
);

---------------------- Mock Data for Ads Table --------------------------------
INSERT INTO Ads (
    ad_id,
    merchant_id,
    redirect_link,
    ad_type,
    content_url
) VALUES
(
    'ad001a-b2c3-d4e5-f678-ads000000001',
    'c1a2b3d4-e5f6-7890-abcd-1234567890aa', -- Urban Threads Co.
    'https://urbanthreads.com/new-arrivals',
    'banner',
    'https://cdn.urbanthreads.com/ads/banner1.jpg'
),
(
    'ad002b-c3d4-e5f6-7890-ads000000002',
    'c2b3c4d5-e6f7-8901-bcda-2345678901bb', -- Linen Loft Ltd.
    'https://linenloft.la/summer-sale',
    'video',
    'https://cdn.linenloft.la/ads/summer2025.mp4'
),
(
    'ad003c-d4e5-f6g7-8901-ads000000003',
    'c3c4d5e6-f7g8-9012-cdab-3456789012cc', -- Denim Dock
    'https://denimdock.la/denim-collection',
    'popup',
    'https://cdn.denimdock.la/ads/popup-jeans.png'
),
(
    'ad004d-e5f6-g7h8-9012-ads000000004',
    'c4d5e6f7-g8h9-0123-dabc-4567890123dd', -- Cotton Couture
    'https://cottoncouture.co.la/luxury-linen',
    'banner',
    'https://media.cottoncouture.co.la/ads/banner2.jpg'
),
(
    'ad005e-f6g7-h8i9-0123-ads000000005',
    'c1a2b3d4-e5f6-7890-abcd-1234567890aa', -- Urban Threads Co.
    'https://urbanthreads.com/hoodies',
    'video',
    'https://cdn.urbanthreads.com/ads/hoodies-spot.mp4'
),
(
    'ad006f-g7h8-i9j0-1234-ads000000006',
    'c2b3c4d5-e6f7-8901-bcda-2345678901bb', -- Linen Loft Ltd.
    'https://linenloft.la/organic-collection',
    'popup',
    'https://cdn.linenloft.la/ads/organic-popup.png'
);

---------------------- Mock Data for Campaign Table --------------------------------
INSERT INTO Campaign (
    campaign_id,
    user_id,
    start_date,
    end_date
) VALUES
(
    'camp001a-b2c3-d4e5-f678-camp000001',
    '10009', -- Example user_id for marketing team
    TO_TIMESTAMP('2025-05-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'),
    TO_TIMESTAMP('2025-05-31 23:59:59', 'YYYY-MM-DD HH24:MI:SS')
),
(
    'camp002b-c3d4-e5f6-7890-camp000002',
    '10003', -- Example user_id for marketing team
    TO_TIMESTAMP('2025-06-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'),
    TO_TIMESTAMP('2025-06-30 23:59:59', 'YYYY-MM-DD HH24:MI:SS')
),
(
    'camp003c-d4e5-f6g7-8901-camp000003',
    '10011', -- Example user_id for marketing team
    TO_TIMESTAMP('2025-07-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'),
    TO_TIMESTAMP('2025-07-31 23:59:59', 'YYYY-MM-DD HH24:MI:SS')
);

---------------------- Mock Data for Current ads Table --------------------------------
INSERT INTO CurrentAds (
    ad_id,
    campaign_id
) VALUES
(
    'ad001a-b2c3-d4e5-f678-ads000000001', -- Ad for Urban Threads Co.
    'camp001a-b2c3-d4e5-f678-camp000001'  -- Campaign for May 2025
),
(
    'ad002b-c3d4-e5f6-7890-ads000000002', -- Ad for Linen Loft Ltd.
    'camp002b-c3d4-e5f6-7890-camp000002'  -- Campaign for June 2025
),
(
    'ad003c-d4e5-f6g7-8901-ads000000003', -- Ad for Denim Dock
    'camp003c-d4e5-f6g7-8901-camp000003'  -- Campaign for July 2025
),
(
    'ad004d-e5f6-g7h8-9012-ads000000004', -- Ad for Cotton Couture
    'camp001a-b2c3-d4e5-f678-camp000001'  -- Campaign for May 2025
),
(
    'ad005e-f6g7-h8i9-0123-ads000000005', -- Ad for Urban Threads Co.
    'camp002b-c3d4-e5f6-7890-camp000002'  -- Campaign for June 2025
),
(
    'ad006f-g7h8-i9j0-1234-ads000000006', -- Ad for Linen Loft Ltd.
    'camp003c-d4e5-f6g7-8901-camp000003'  -- Campaign for July 2025
);

---------------------- Mock Data for Category Table --------------------------------
INSERT INTO Category (
    ad_category_id,
    description
) VALUES
(
    'cat001a-b2c3-d4e5-f678-cat000001', -- Category for Urban Threads Co. Ad 1
    'Summer Collection - New Arrivals for the Season'
),
(
    'cat002b-c3d4-e5f6-7890-cat000002', -- Category for Linen Loft Ltd. Ad 2
    'Summer Sale - Discounts on Linen Apparel'
),
(
    'cat003c-d4e5-f6g7-8901-cat000003', -- Category for Denim Dock Ad 3
    'Denim Collection - Premium Denim for All Styles'
),
(
    'cat004d-e5f6-g7h8-9012-cat000004', -- Category for Cotton Couture Ad 4
    'Luxury Linen - High-End Linen Apparel Collection'
),
(
    'cat005e-f6g7-h8i9-0123-cat000005', -- Category for Urban Threads Co. Ad 5
    'Hoodies Collection - Cozy and Stylish Hoodies'
),
(
    'cat006f-g7h8-i9j0-1234-cat000006', -- Category for Linen Loft Ltd. Ad 6
    'Organic Collection - Sustainable and Eco-Friendly Linen'
);

---------------------- Mock Data for AdCategory Table --------------------------------
INSERT INTO AdCategory (
    ad_id,
    ad_category_id
) VALUES
(
    'ad001a-b2c3-d4e5-f678-ads000000001', -- Ad for Urban Threads Co.
    'cat001a-b2c3-d4e5-f678-cat000001'    -- Category: Summer Collection
),
(
    'ad002b-c3d4-e5f6-7890-ads000000002', -- Ad for Linen Loft Ltd.
    'cat002b-c3d4-e5f6-7890-cat000002'    -- Category: Summer Sale
),
(
    'ad003c-d4e5-f6g7-8901-ads000000003', -- Ad for Denim Dock
    'cat003c-d4e5-f6g7-8901-cat000003'    -- Category: Denim Collection
),
(
    'ad004d-e5f6-g7h8-9012-ads000000004', -- Ad for Cotton Couture
    'cat004d-e5f6-g7h8-9012-cat000004'    -- Category: Luxury Linen
),
(
    'ad005e-f6g7-h8i9-0123-ads000000005', -- Ad for Urban Threads Co.
    'cat005e-f6g7-h8i9-0123-cat000005'    -- Category: Hoodies Collection
),
(
    'ad006f-g7h8-i9j0-1234-ads000000006', -- Ad for Linen Loft Ltd.
    'cat006f-g7h8-i9j0-1234-cat000006'    -- Category: Organic Collection
);

---------------------- Mock Data for Location Table --------------------------------
INSERT INTO Location (
    local_ad_group_id,
    description,
    timezone
) VALUES
(
    'loc001a-b2c3-d4e5-f678-loc000001', -- Location for Urban Threads Co.
    'Urban Threads Ad Group - Lala City',
    'Asia/Kolkata'
),
(
    'loc002b-c3d4-e5f6-7890-loc000002', -- Location for Linen Loft Ltd.
    'Linen Loft Ad Group - Weaverton',
    'Asia/Kolkata'
),
(
    'loc003c-d4e5-f6g7-8901-loc000003', -- Location for Denim Dock
    'Denim Dock Ad Group - Threadsville',
    'Europe/Rome'
),
(
    'loc004d-e5f6-g7h8-9012-loc000004', -- Location for Cotton Couture
    'Cotton Couture Ad Group - Style Town',
    'Europe/Rome'
);

---------------------- Mock Data for AdLocation Table --------------------------------
INSERT INTO AdLocation (
    ad_id,
    local_ad_group_id,
    timezone
) VALUES
(
    'ad001a-b2c3-d4e5-f678-ads000000001', -- Urban Threads Co. Ad 1
    'loc001a-b2c3-d4e5-f678-loc000001',
    'Asia/Kolkata'
),
(
    'ad002b-c3d4-e5f6-7890-ads000000002', -- Linen Loft Ltd. Ad 2
    'loc002b-c3d4-e5f6-7890-loc000002',
    'Asia/Kolkata'
),
(
    'ad003c-d4e5-f6g7-8901-ads000000003', -- Denim Dock Ad 3
    'loc003c-d4e5-f6g7-8901-loc000003',
    'Europe/Rome'
),
(
    'ad004d-e5f6-g7h8-9012-ads000000004', -- Cotton Couture Ad 4
    'loc004d-e5f6-g7h8-9012-loc000004',
    'Europe/Rome'
),
(
    'ad005e-f6g7-h8i9-0123-ads000000005', -- Urban Threads Co. Ad 5
    'loc001a-b2c3-d4e5-f678-loc000001',
    'Asia/Kolkata'
),
(
    'ad006f-g7h8-i9j0-1234-ads000000006', -- Linen Loft Ltd. Ad 6
    'loc002b-c3d4-e5f6-7890-loc000002',
    'Asia/Kolkata'
);

---------------------- Mock Data for AdStats Table --------------------------------
INSERT INTO AdStats (
    ad_stat_id,
    merchant_id,
    ad_id,
    start_time,
    end_time,
    impressions,
    clicks,
    cost_per_click,
    cost_per_impression
) VALUES
(
    'stat001a-b2c3-d4e5-f678-stat000001', -- Urban Threads Co. Ad 1
    'm001-urban-threads-uuid',
    'ad001a-b2c3-d4e5-f678-ads000000001',
    TO_TIMESTAMP('2025-03-01 08:00:00', 'YYYY-MM-DD HH24:MI:SS'),
    TO_TIMESTAMP('2025-03-15 20:00:00', 'YYYY-MM-DD HH24:MI:SS'),
    100000,
    1500,
    1.20,
    0.005
),
(
    'stat002b-c3d4-e5f6-7890-stat000002', -- Linen Loft Ltd. Ad 2
    'm002-linen-loft-uuid',
    'ad002b-c3d4-e5f6-7890-ads000000002',
    TO_TIMESTAMP('2025-03-05 09:00:00', 'YYYY-MM-DD HH24:MI:SS'),
    TO_TIMESTAMP('2025-03-25 22:00:00', 'YYYY-MM-DD HH24:MI:SS'),
    80000,
    980,
    1.10,
    0.005
),
(
    'stat003c-d4e5-f6g7-8901-stat000003', -- Denim Dock Ad 3
    'm003-denim-dock-uuid',
    'ad003c-d4e5-f6g7-8901-ads000000003',
    TO_TIMESTAMP('2025-03-10 10:00:00', 'YYYY-MM-DD HH24:MI:SS'),
    TO_TIMESTAMP('2025-03-30 20:00:00', 'YYYY-MM-DD HH24:MI:SS'),
    120000,
    2100,
    1.50,
    0.006
),
(
    'stat004d-e5f6-g7h8-9012-stat000004', -- Cotton Couture Ad 4
    'm004-cotton-couture-uuid',
    'ad004d-e5f6-g7h8-9012-ads000000004',
    TO_TIMESTAMP('2025-03-15 07:30:00', 'YYYY-MM-DD HH24:MI:SS'),
    TO_TIMESTAMP('2025-04-05 18:00:00', 'YYYY-MM-DD HH24:MI:SS'),
    60000,
    750,
    1.30,
    0.005
),
(
    'stat005e-f6g7-h8i9-0123-stat000005', -- Urban Threads Co. Ad 5
    'm001-urban-threads-uuid',
    'ad005e-f6g7-h8i9-0123-ads000000005',
    TO_TIMESTAMP('2025-03-20 09:00:00', 'YYYY-MM-DD HH24:MI:SS'),
    TO_TIMESTAMP('2025-04-10 21:00:00', 'YYYY-MM-DD HH24:MI:SS'),
    95000,
    1700,
    1.15,
    0.0045
),
(
    'stat006f-g7h8-i9j0-1234-stat000006', -- Linen Loft Ltd. Ad 6
    'm002-linen-loft-uuid',
    'ad006f-g7h8-i9j0-1234-ads000000006',
    TO_TIMESTAMP('2025-03-25 08:00:00', 'YYYY-MM-DD HH24:MI:SS'),
    TO_TIMESTAMP('2025-04-15 20:00:00', 'YYYY-MM-DD HH24:MI:SS'),
    70000,
    1100,
    1.05,
    0.0048
);

---------------------- Mock Data for MerchantInvoice Table --------------------------------
INSERT INTO MerchantInvoice (
    merchant_payment_id,
    ad_stat_id,
    payment_date,
    payment_account,
    status
) VALUES
(
    1001,
    'stat001a-b2c3-d4e5-f678-stat000001', -- Urban Threads Co.
    TO_TIMESTAMP('2025-04-01 10:00:00', 'YYYY-MM-DD HH24:MI:SS'),
    50110001,
    'COMPLETED'
),
(
    1002,
    'stat002b-c3d4-e5f6-7890-stat000002', -- Linen Loft Ltd.
    TO_TIMESTAMP('2025-04-02 12:30:00', 'YYYY-MM-DD HH24:MI:SS'),
    50110002,
    'COMPLETED'
),
(
    1003,
    'stat003c-d4e5-f6g7-8901-stat000003', -- Denim Dock
    TO_TIMESTAMP('2025-04-03 15:45:00', 'YYYY-MM-DD HH24:MI:SS'),
    50110003,
    'PENDING'
),
(
    1004,
    'stat004d-e5f6-g7h8-9012-stat000004', -- Cotton Couture
    TO_TIMESTAMP('2025-04-04 09:00:00', 'YYYY-MM-DD HH24:MI:SS'),
    50110004,
    'COMPLETED'
),
(
    1005,
    'stat005e-f6g7-h8i9-0123-stat000005', -- Urban Threads Co. second ad
    TO_TIMESTAMP('2025-04-06 13:20:00', 'YYYY-MM-DD HH24:MI:SS'),
    50110001,
    'FAILED'
),
(
    1006,
    'stat006f-g7h8-i9j0-1234-stat000006', -- Linen Loft Ltd. second ad
    TO_TIMESTAMP('2025-04-07 17:40:00', 'YYYY-MM-DD HH24:MI:SS'),
    50110002,
    'COMPLETED'
);

---------------------- Mock Data for MerchantInvoice Table --------------------------------
INSERT INTO MerchantInvoice (
    merchant_payment_id,
    ad_stat_id,
    payment_date,
    payment_account,
    status
) VALUES
(
    1001,
    'stat001a-b2c3-d4e5-f678-stat000001', -- Urban Threads Co.
    TO_TIMESTAMP('2025-04-01 10:00:00', 'YYYY-MM-DD HH24:MI:SS'),
    30010001,
    'COMPLETED'
),
(
    1002,
    'stat002b-c3d4-e5f6-7890-stat000002', -- Linen Loft Ltd.
    TO_TIMESTAMP('2025-04-02 12:30:00', 'YYYY-MM-DD HH24:MI:SS'),
    30010002,
    'COMPLETED'
),
(
    1003,
    'stat003c-d4e5-f6g7-8901-stat000003', -- Denim Dock
    TO_TIMESTAMP('2025-04-03 15:45:00', 'YYYY-MM-DD HH24:MI:SS'),
    30010003,
    'PENDING'
),
(
    1004,
    'stat004d-e5f6-g7h8-9012-stat000004', -- Cotton Couture
    TO_TIMESTAMP('2025-04-04 09:00:00', 'YYYY-MM-DD HH24:MI:SS'),
    30010004,
    'COMPLETED'
),
(
    1005,
    'stat005e-f6g7-h8i9-0123-stat000005', -- Urban Threads Co. (2nd Ad)
    TO_TIMESTAMP('2025-04-06 13:20:00', 'YYYY-MM-DD HH24:MI:SS'),
    30010001,
    'FAILED'
),
(
    1006,
    'stat006f-g7h8-i9j0-1234-stat000006', -- Linen Loft Ltd. (2nd Ad)
    TO_TIMESTAMP('2025-04-07 17:40:00', 'YYYY-MM-DD HH24:MI:SS'),
    30010002,
    'COMPLETED'
);

---------------------- Mock Data for MerchantPayments Table --------------------------------
INSERT INTO MerchantPayments (
    merchant_id,
    merchant_payment_id
) VALUES
-- Urban Threads Co. (2 payments)
('c1a2b3d4-e5f6-7890-abcd-1234567890aa', 1001),
('c1a2b3d4-e5f6-7890-abcd-1234567890aa', 1005),

-- Linen Loft Ltd. (2 payments)
('c2b3c4d5-e6f7-8901-bcda-2345678901bb', 1002),
('c2b3c4d5-e6f7-8901-bcda-2345678901bb', 1006),

-- Denim Dock (1 payment)
('c3c4d5e6-f7g8-9012-cdab-3456789012cc', 1003),

-- Cotton Couture (1 payment)
('c4d5e6f7-g8h9-0123-dabc-4567890123dd', 1004);

---------------------- Mock Data for UserPlaylist Table --------------------------------
INSERT INTO UserPlaylist (
    playlist_id,
    user_id,
    playlist_name,
    playlist_description,
    image_url,
    created_at
) VALUES
-- Playlist for Bombardilo Crocodilo
('pl-10001-01', '10001', 'Lalaland Vibes', 'A relaxing mix of Lalaland’s finest instrumentals.', 'https://lalastream.la/cover/lalaland-vibes.jpg', TO_TIMESTAMP('2024-01-10 09:00:00', 'YYYY-MM-DD HH24:MI:SS')),

-- Playlist for Jane Doe
('pl-10002-01', '10002', 'Pop Picks', 'Top pop songs from Lalaland and beyond.', 'https://lalastream.la/cover/pop-picks.jpg', TO_TIMESTAMP('2024-02-20 14:00:00', 'YYYY-MM-DD HH24:MI:SS')),

-- Playlist for Alex Smith
('pl-10003-01', '10003', 'Morning Motivation', 'Start your day with energy and inspiration.', 'https://lalastream.la/cover/morning-motivation.jpg', TO_TIMESTAMP('2024-03-15 07:30:00', 'YYYY-MM-DD HH24:MI:SS')),

-- Playlist for Sally Field
('pl-10008-01', '10008', 'Throwback Classics', 'Old-school hits from every decade.', 'https://lalastream.la/cover/throwback-classics.jpg', TO_TIMESTAMP('2024-04-05 18:15:00', 'YYYY-MM-DD HH24:MI:SS')),

-- Playlist for Ethan Williams
('pl-10019-01', '10019', 'Gym Boosters', 'High tempo tracks for lifting and cardio.', 'https://lalastream.la/cover/gym-boosters.jpg', TO_TIMESTAMP('2024-05-01 06:45:00', 'YYYY-MM-DD HH24:MI:SS')),

-- Playlist for Sophia Miller
('pl-10020-01', '10020', 'Sleep Sounds', 'Gentle ambient tunes to help you drift off.', 'https://lalastream.la/cover/sleep-sounds.jpg', TO_TIMESTAMP('2024-05-10 22:00:00', 'YYYY-MM-DD HH24:MI:SS'));

---------------------- Mock Data for Genre Table --------------------------------
INSERT INTO Genre (genre_id, genre_name, genre_description) 
VALUES
('g001-pop-uuid', 'Pop', 'Popular music with catchy melodies and broad appeal'),
('g002-rock-uuid', 'Rock', 'Music characterized by a strong rhythm and often electric guitar'),
('g003-hiphop-uuid', 'Hip Hop', 'A genre featuring rhythmic and rhyming speech (rap)'),
('g004-jazz-uuid', 'Jazz', 'A genre known for improvisation, swing, and blue notes'),
('g005-classical-uuid', 'Classical', 'Orchestral music rooted in Western traditions'),
('g006-electronic-uuid', 'Electronic', 'Music produced using electronic instruments and technology'),
('g007-country-uuid', 'Country', 'Music often centered around storytelling and acoustic instruments'),
('g008-rnb-uuid', 'R&B', 'Rhythm and Blues, combining soulful vocals and strong backbeats'),
('g009-reggae-uuid', 'Reggae', 'A Jamaican genre known for its offbeat rhythms and themes of peace'),
('g010-metal-uuid', 'Metal', 'Heavy and aggressive genre with distorted guitars and powerful vocals');

---------------------- Mock Data for Artists Table --------------------------------
INSERT INTO Artists (artist_id, artist_name, picture_url, biography, created_at, updated_at) 
VALUES
-- Pop
('a001-taylorswift-uuid', 'Taylor Swift', 'http://example.com/artists/taylor.jpg', 'American pop and country singer-songwriter.', TO_TIMESTAMP('2023-01-01 10:00:00', 'YYYY-MM-DD HH24:MI:SS'), NULL),

-- Rock
('a002-coldplay-uuid', 'Coldplay', 'http://example.com/artists/coldplay.jpg', 'British rock band known for melodic anthems.', TO_TIMESTAMP('2023-01-02 11:30:00', 'YYYY-MM-DD HH24:MI:SS'), NULL),

-- Hip Hop
('a003-kendricklamar-uuid', 'Kendrick Lamar', 'http://example.com/artists/kendrick.jpg', 'Critically acclaimed rapper and songwriter from Compton.', TO_TIMESTAMP('2023-01-03 14:00:00', 'YYYY-MM-DD HH24:MI:SS'), NULL),

-- Jazz
('a004-norahjones-uuid', 'Norah Jones', 'http://example.com/artists/norah.jpg', 'American singer with jazz, pop, and soul influences.', TO_TIMESTAMP('2023-01-04 16:00:00', 'YYYY-MM-DD HH24:MI:SS'), NULL),

-- Classical
('a005-yo-yo-ma-uuid', 'Yo-Yo Ma', 'http://example.com/artists/yoyoma.jpg', 'World-renowned cellist known for classical and crossover work.', TO_TIMESTAMP('2023-01-05 09:00:00', 'YYYY-MM-DD HH24:MI:SS'), NULL),

-- Electronic
('a006-deadmaus-uuid', 'Deadmau5', 'http://example.com/artists/deadmau5.jpg', 'Canadian electronic music producer and performer.', TO_TIMESTAMP('2023-01-06 13:00:00', 'YYYY-MM-DD HH24:MI:SS'), NULL),

-- Country
('a007-lukebryan-uuid', 'Luke Bryan', 'http://example.com/artists/luke.jpg', 'Popular American country singer and songwriter.', TO_TIMESTAMP('2023-01-07 17:00:00', 'YYYY-MM-DD HH24:MI:SS'), NULL),

-- R&B
('a008-her-uuid', 'H.E.R.', 'http://example.com/artists/her.jpg', 'Grammy-winning artist known for soulful R&B sound.', TO_TIMESTAMP('2023-01-08 20:00:00', 'YYYY-MM-DD HH24:MI:SS'), NULL),

-- Reggae
('a009-bobmarley-uuid', 'Bob Marley', 'http://example.com/artists/bob.jpg', 'Legendary reggae musician and icon of peace and love.', TO_TIMESTAMP('2023-01-09 15:00:00', 'YYYY-MM-DD HH24:MI:SS'), NULL),

-- Metal
('a010-metallica-uuid', 'Metallica', 'http://example.com/artists/metallica.jpg', 'American heavy metal band known for powerful riffs and lyrics.', TO_TIMESTAMP('2023-01-10 18:00:00', 'YYYY-MM-DD HH24:MI:SS'), NULL);

---------------------- Mock Data for Albums Table --------------------------------
INSERT INTO Albums (album_id, artist_id, genre_id, album_name, album_duration) VALUES
-- Pop (Taylor Swift)
('al001-ts1989-uuid', 'a001-taylorswift-uuid', 'g001-pop-uuid', '1989', 48),

-- Rock (Coldplay)
('al002-cp-parachutes-uuid', 'a002-coldplay-uuid', 'g002-rock-uuid', 'Parachutes', 42),

-- Hip Hop (Kendrick Lamar)
('al003-kl-damn-uuid', 'a003-kendricklamar-uuid', 'g003-hiphop-uuid', 'DAMN.', 55),

-- Jazz (Norah Jones)
('al004-nj-comeaway-uuid', 'a004-norahjones-uuid', 'g004-jazz-uuid', 'Come Away With Me', 45),

-- Classical (Yo-Yo Ma)
('al005-yyma-silkroad-uuid', 'a005-yo-yo-ma-uuid', 'g005-classical-uuid', 'Silk Road Journeys', 60),

-- Electronic (Deadmau5)
('al006-dm-randomalbum-uuid', 'a006-deadmaus-uuid', 'g006-electronic-uuid', 'Random Album Title', 66),

-- Country (Luke Bryan)
('al007-lb-crasemy-uuid', 'a007-lukebryan-uuid', 'g007-country-uuid', 'Crash My Party', 52),

-- R&B (H.E.R.)
('al008-her-vol1-uuid', 'a008-her-uuid', 'g008-rnb-uuid', 'H.E.R., Vol. 1', 47),

-- Reggae (Bob Marley)
('al009-bm-legend-uuid', 'a009-bobmarley-uuid', 'g009-reggae-uuid', 'Legend', 58),

-- Metal (Metallica)
('al010-mt-black-uuid', 'a010-metallica-uuid', 'g010-metal-uuid', 'The Black Album', 62);


---------------------- Mock Data for ArtistCollaboration Table --------------------------------
INSERT INTO ArtistCollaboration (artist_id, album_id) VALUES
-- Single-artist albums
('a001-taylorswift-uuid', 'al001-ts1989-uuid'),
('a002-coldplay-uuid', 'al002-cp-parachutes-uuid'),
('a003-kendricklamar-uuid', 'al003-kl-damn-uuid'),
('a004-norahjones-uuid', 'al004-nj-comeaway-uuid'),
('a005-yo-yo-ma-uuid', 'al005-yyma-silkroad-uuid'),
('a006-deadmaus-uuid', 'al006-dm-randomalbum-uuid'),
('a007-lukebryan-uuid', 'al007-lb-crasemy-uuid'),
('a008-her-uuid', 'al008-her-vol1-uuid'),
('a009-bobmarley-uuid', 'al009-bm-legend-uuid'),
('a010-metallica-uuid', 'al010-mt-black-uuid'),

-- Sample collaborations (for demonstration purposes)
('a003-kendricklamar-uuid', 'al008-her-vol1-uuid'),     -- Kendrick Lamar featured on H.E.R.'s album
('a004-norahjones-uuid', 'al005-yyma-silkroad-uuid'),   -- Norah Jones and Yo-Yo Ma collaboration
('a002-coldplay-uuid', 'al006-dm-randomalbum-uuid');    -- Coldplay collaboration with Deadmau5

---------------------- Mock Data for Songs Table --------------------------------
INSERT INTO Songs (
    song_id,
    genre_id,
    album_id,
    right_holder_id,
    song_title,
    song_duration,
    release_date
) VALUES
-- Taylor Swift - 1989
('s001-ts-blankspace-uuid', 'g001-pop-uuid', 'al001-ts1989-uuid', 'rh001-universal-uuid', 'Blank Space', 231, '2014-10-27'),
('s002-ts-style-uuid', 'g001-pop-uuid', 'al001-ts1989-uuid', 'rh001-universal-uuid', 'Style', 231, '2014-10-27'),

-- Coldplay - Parachutes
('s003-cp-yellow-uuid', 'g002-rock-uuid', 'al002-cp-parachutes-uuid', 'rh002-sony-uuid', 'Yellow', 267, '2000-07-10'),

-- Kendrick Lamar - DAMN.
('s004-kl-humble-uuid', 'g003-hiphop-uuid', 'al003-kl-damn-uuid', 'rh003-warner-uuid', 'HUMBLE.', 177, '2017-04-14'),

-- Norah Jones - Come Away with Me
('s005-nj-dontknowwhy-uuid', 'g004-jazz-uuid', 'al004-nj-comeaway-uuid', 'rh004-emi-uuid', 'Don\'t Know Why', 207, '2002-02-26'),

-- Yo-Yo Ma - Silk Road
('s006-yyma-journey-uuid', 'g005-classical-uuid', 'al005-yyma-silkroad-uuid', 'rh001-universal-uuid', 'Journey to the West', 321, '2000-05-01'),

-- Deadmau5 - Random Album Title
('s007-dm-ghostsnstuff-uuid', 'g006-edm-uuid', 'al006-dm-randomalbum-uuid', 'rh002-sony-uuid', 'Ghosts \'n\' Stuff', 245, '2008-09-02'),

-- Luke Bryan - Crash My Party
('s008-lb-thatsmykind-uuid', 'g007-country-uuid', 'al007-lb-crasemy-uuid', 'rh003-warner-uuid', 'That\'s My Kind of Night', 211, '2013-08-13'),

-- H.E.R. - Vol. 1
('s009-her-focus-uuid', 'g008-rnb-uuid', 'al008-her-vol1-uuid', 'rh004-emi-uuid', 'Focus', 220, '2016-09-09'),

-- Bob Marley - Legend
('s010-bm-no-woman-uuid', 'g009-reggae-uuid', 'al009-bm-legend-uuid', 'rh001-universal-uuid', 'No Woman, No Cry', 256, '1984-05-08'),

-- Metallica - Black Album
('s011-mt-enter-sandman-uuid', 'g010-metal-uuid', 'al010-mt-black-uuid', 'rh002-sony-uuid', 'Enter Sandman', 331, '1991-08-12');


---------------------- Mock Data for SongsCollaboration Table --------------------------------
INSERT INTO SongCollaborations (
    song_id,
    artists_id
) VALUES
-- Taylor Swift - solo songs
('s001-ts-blankspace-uuid', 'a001-taylor-swift-uuid'),
('s002-ts-style-uuid', 'a001-taylor-swift-uuid'),

-- Coldplay - solo band entry
('s003-cp-yellow-uuid', 'a002-coldplay-uuid'),

-- Kendrick Lamar - solo song
('s004-kl-humble-uuid', 'a003-kendrick-lamar-uuid'),

-- Norah Jones - solo song
('s005-nj-dontknowwhy-uuid', 'a004-norah-jones-uuid'),

-- Yo-Yo Ma - solo classical track
('s006-yyma-journey-uuid', 'a005-yo-yo-ma-uuid'),

-- Deadmau5 - main artist + featuring Rob Swire (example of collab)
('s007-dm-ghostsnstuff-uuid', 'a006-deadmau5-uuid'),
('s007-dm-ghostsnstuff-uuid', 'a011-rob-swire-uuid'),

-- Luke Bryan - solo country track
('s008-lb-thatsmykind-uuid', 'a007-luke-bryan-uuid'),

-- H.E.R. - solo R&B track
('s009-her-focus-uuid', 'a008-her-uuid'),

-- Bob Marley - solo reggae track
('s010-bm-no-woman-uuid', 'a009-bob-marley-uuid'),

-- Metallica - band entry
('s011-mt-enter-sandman-uuid', 'a010-metallica-uuid');


---------------------- Mock Data for Songstats Table --------------------------------
INSERT INTO SongStats (
    songstat_id,
    rightholder_id,
    song_id,
    cost_per_play,
    likes,
    shares,
    start_date,
    end_date
) VALUES
-- Taylor Swift songs
('ss001-ts-blankspace-uuid', 'rh001-universal-uuid', 's001-ts-blankspace-uuid', 0.00500, 1500000, 200000, TO_TIMESTAMP('2024-01-01', 'YYYY-MM-DD'), TO_TIMESTAMP('2025-01-01', 'YYYY-MM-DD')),
('ss002-ts-style-uuid',       'rh001-universal-uuid', 's002-ts-style-uuid',      0.00520, 1200000, 180000, TO_TIMESTAMP('2024-01-01', 'YYYY-MM-DD'), TO_TIMESTAMP('2025-01-01', 'YYYY-MM-DD')),

-- Coldplay
('ss003-cp-yellow-uuid',      'rh002-sony-uuid',      's003-cp-yellow-uuid',     0.00480, 2000000, 250000, TO_TIMESTAMP('2023-06-01', 'YYYY-MM-DD'), TO_TIMESTAMP('2024-06-01', 'YYYY-MM-DD')),

-- Kendrick Lamar
('ss004-kl-humble-uuid',      'rh003-warner-uuid',    's004-kl-humble-uuid',     0.00600, 2500000, 350000, TO_TIMESTAMP('2022-08-01', 'YYYY-MM-DD'), TO_TIMESTAMP('2023-08-01', 'YYYY-MM-DD')),

-- Norah Jones
('ss005-nj-dontknowwhy-uuid', 'rh001-universal-uuid', 's005-nj-dontknowwhy-uuid',0.00450, 1100000, 140000, TO_TIMESTAMP('2022-01-01', 'YYYY-MM-DD'), TO_TIMESTAMP('2023-01-01', 'YYYY-MM-DD')),

-- Yo-Yo Ma
('ss006-yyma-journey-uuid',   'rh004-naxos-uuid',     's006-yyma-journey-uuid',  0.00350, 900000,  80000,  TO_TIMESTAMP('2021-01-01', 'YYYY-MM-DD'), TO_TIMESTAMP('2022-01-01', 'YYYY-MM-DD')),

-- Deadmau5 feat. Rob Swire
('ss007-dm-ghostsnstuff-uuid','rh005-mau5trap-uuid',  's007-dm-ghostsnstuff-uuid',0.00650, 1800000, 220000, TO_TIMESTAMP('2024-05-01', 'YYYY-MM-DD'), TO_TIMESTAMP('2025-05-01', 'YYYY-MM-DD')),

-- Luke Bryan
('ss008-lb-thatsmykind-uuid', 'rh001-universal-uuid', 's008-lb-thatsmykind-uuid', 0.00400, 1000000, 130000, TO_TIMESTAMP('2022-03-01', 'YYYY-MM-DD'), TO_TIMESTAMP('2023-03-01', 'YYYY-MM-DD')),

-- H.E.R.
('ss009-her-focus-uuid',      'rh001-universal-uuid', 's009-her-focus-uuid',      0.00530, 1600000, 170000, TO_TIMESTAMP('2023-09-01', 'YYYY-MM-DD'), TO_TIMESTAMP('2024-09-01', 'YYYY-MM-DD')),

-- Bob Marley
('ss010-bm-no-woman-uuid',    'rh006-islandrec-uuid', 's010-bm-no-woman-uuid',    0.00490, 3000000, 400000, TO_TIMESTAMP('2020-01-01', 'YYYY-MM-DD'), TO_TIMESTAMP('2021-01-01', 'YYYY-MM-DD')),

-- Metallica
('ss011-mt-enter-sandman-uuid','rh002-sony-uuid',     's011-mt-enter-sandman-uuid',0.00580, 2700000, 290000, TO_TIMESTAMP('2022-11-01', 'YYYY-MM-DD'), TO_TIMESTAMP('2023-11-01', 'YYYY-MM-DD'));

---------------------- Mock Data for Rightholderinvoice Table --------------------------------
INSERT INTO RightholderInvoice (
    rightholder_payment_id,
    songstat_id,
    payment_date,
    payment_account,
    status
) VALUES
('rp001-ts-blankspace-invoice',   'ss001-ts-blankspace-uuid',   TO_TIMESTAMP('2025-01-10', 'YYYY-MM-DD'), 7500, 'PAID'),
('rp002-ts-style-invoice',        'ss002-ts-style-uuid',        TO_TIMESTAMP('2025-01-15', 'YYYY-MM-DD'), 6240, 'PAID'),
('rp003-cp-yellow-invoice',       'ss003-cp-yellow-uuid',       TO_TIMESTAMP('2024-06-10', 'YYYY-MM-DD'), 9600, 'PAID'),
('rp004-kl-humble-invoice',       'ss004-kl-humble-uuid',       TO_TIMESTAMP('2023-08-12', 'YYYY-MM-DD'), 15000, 'PAID'),
('rp005-nj-dontknowwhy-invoice',  'ss005-nj-dontknowwhy-uuid',  TO_TIMESTAMP('2023-01-20', 'YYYY-MM-DD'), 4950, 'PAID'),
('rp006-yyma-journey-invoice',    'ss006-yyma-journey-uuid',    TO_TIMESTAMP('2022-01-30', 'YYYY-MM-DD'), 3150, 'PAID'),
('rp007-dm-ghostsnstuff-invoice', 'ss007-dm-ghostsnstuff-uuid', TO_TIMESTAMP('2025-05-01', 'YYYY-MM-DD'), 11700, 'PENDING'),
('rp008-lb-thatsmykind-invoice',  'ss008-lb-thatsmykind-uuid',  TO_TIMESTAMP('2023-03-15', 'YYYY-MM-DD'), 4000, 'PAID'),
('rp009-her-focus-invoice',       'ss009-her-focus-uuid',       TO_TIMESTAMP('2024-09-15', 'YYYY-MM-DD'), 8480, 'PENDING'),
('rp010-bm-nowoman-invoice',      'ss010-bm-no-woman-uuid',     TO_TIMESTAMP('2021-01-10', 'YYYY-MM-DD'), 14700, 'PAID'),
('rp011-mt-entsandman-invoice',   'ss011-mt-enter-sandman-uuid',TO_TIMESTAMP('2023-11-20', 'YYYY-MM-DD'), 15660, 'FAILED');


---------------------- Mock Data for Rightholderpayments Table --------------------------------
INSERT INTO RightholderPayment (
    rightholder_id,
    rightholder_payment_id
) VALUES
('rr001-ts-uuid',  'rp001-ts-blankspace-invoice'),
('rr001-ts-uuid',  'rp002-ts-style-invoice'),

('rr002-cp-uuid',  'rp003-cp-yellow-invoice'),

('rr003-kl-uuid',  'rp004-kl-humble-invoice'),

('rr004-nj-uuid',  'rp005-nj-dontknowwhy-invoice'),

('rr005-yyma-uuid','rp006-yyma-journey-invoice'),

('rr006-dm-uuid',  'rp007-dm-ghostsnstuff-invoice'),

('rr007-lb-uuid',  'rp008-lb-thatsmykind-invoice'),

('rr008-her-uuid', 'rp009-her-focus-invoice'),

('rr009-bm-uuid',  'rp010-bm-nowoman-invoice'),

('rr010-mt-uuid',  'rp011-mt-entsandman-invoice');


---------------------- Mock Data for SongPlaylist Table --------------------------------
INSERT INTO PlaylistSongs (
    playlist_id,
    song_id
) VALUES
-- Focus Vibes
('p001-focus-vibes-uuid', 's009-focus'),
('p001-focus-vibes-uuid', 's005-dontknowwhy'),
('p001-focus-vibes-uuid', 's003-yellow'),

-- Chill Sessions
('p002-chill-sessions-uuid', 's006-journey'),
('p002-chill-sessions-uuid', 's005-dontknowwhy'),
('p002-chill-sessions-uuid', 's009-focus'),

-- Workout Boost
('p003-workout-boost-uuid', 's004-humble'),
('p003-workout-boost-uuid', 's007-ghostsnstuff'),
('p003-workout-boost-uuid', 's011-entsandman'),

-- Throwback Gold
('p004-throwback-gold-uuid', 's001-blankspace'),
('p004-throwback-gold-uuid', 's002-style'),
('p004-throwback-gold-uuid', 's010-nowoman'),
('p004-throwback-gold-uuid', 's008-thatsmykind');


------------------------
-- ANALYTICAL QUERIES --
------------------------