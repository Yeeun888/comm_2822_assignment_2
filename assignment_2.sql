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

---------------------- Mock Data for  Table --------------------------------


------------------------
-- ANALYTICAL QUERIES --
------------------------