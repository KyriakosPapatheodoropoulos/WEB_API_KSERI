-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Εξυπηρετητής: 127.0.0.1
-- Χρόνος δημιουργίας: 30 Ιαν 2026 στις 04:49:50
-- Έκδοση διακομιστή: 10.4.32-MariaDB
-- Έκδοση PHP: 8.0.30

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Βάση δεδομένων: `kseri_db`
--

-- --------------------------------------------------------

--
-- Δομή πίνακα για τον πίνακα `games`
--

CREATE TABLE `games` (
  `id` int(11) NOT NULL,
  `status` enum('waiting','active','finished') NOT NULL DEFAULT 'waiting',
  `max_players` tinyint(4) NOT NULL DEFAULT 2,
  `created_by_player_id` int(11) NOT NULL,
  `turn_player_id` int(11) DEFAULT NULL,
  `winner_player_id` int(11) DEFAULT NULL,
  `last_capture_player_id` int(11) DEFAULT NULL,
  `end_reason` varchar(60) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `started_at` timestamp NULL DEFAULT NULL,
  `finished_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Άδειασμα δεδομένων του πίνακα `games`
--

INSERT INTO `games` (`id`, `status`, `max_players`, `created_by_player_id`, `turn_player_id`, `winner_player_id`, `last_capture_player_id`, `end_reason`, `created_at`, `started_at`, `finished_at`, `updated_at`) VALUES
(1, 'finished', 2, 1, 1, NULL, 1, NULL, '2026-01-30 00:04:18', '2026-01-30 00:04:18', NULL, '2026-01-30 02:14:19');

-- --------------------------------------------------------

--
-- Δομή πίνακα για τον πίνακα `game_players`
--

CREATE TABLE `game_players` (
  `game_id` int(11) NOT NULL,
  `player_id` int(11) NOT NULL,
  `seat` tinyint(4) NOT NULL,
  `joined_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Άδειασμα δεδομένων του πίνακα `game_players`
--

INSERT INTO `game_players` (`game_id`, `player_id`, `seat`, `joined_at`) VALUES
(1, 1, 1, '2026-01-30 00:04:18'),
(1, 2, 2, '2026-01-30 00:04:18');

-- --------------------------------------------------------

--
-- Δομή πίνακα για τον πίνακα `game_state`
--

CREATE TABLE `game_state` (
  `game_id` int(11) NOT NULL,
  `state_json` longtext NOT NULL,
  `version` int(11) NOT NULL DEFAULT 1,
  `last_move_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Άδειασμα δεδομένων του πίνακα `game_state`
--

INSERT INTO `game_state` (`game_id`, `state_json`, `version`, `last_move_at`) VALUES
(1, '{\"deck\":[],\"table\":[],\"hands\":{\"1\":[],\"2\":[]},\"captured\":{\"1\":[\"7_H\",\"Q_C\",\"5_H\",\"3_H\",\"3_D\",\"A_C\",\"2_S\",\"2_H\",\"3_S\",\"J_C\",\"10_S\",\"10_H\",\"Q_S\",\"J_D\",\"4_H\",\"7_C\",\"9_C\"],\"2\":[\"5_C\",\"4_D\",\"10_D\",\"9_H\",\"J_H\",\"K_S\",\"K_D\",\"8_S\",\"K_C\",\"6_H\",\"6_C\",\"8_D\",\"4_S\",\"A_D\",\"9_S\",\"2_D\",\"6_S\",\"A_S\",\"7_S\",\"2_C\",\"7_D\",\"Q_H\",\"Q_D\",\"8_H\",\"A_H\",\"K_H\",\"5_D\",\"6_D\",\"9_D\",\"4_C\",\"10_C\",\"8_C\",\"5_S\",\"3_C\",\"J_S\"]},\"score\":{\"1\":30,\"2\":10},\"xeres\":{\"1\":3,\"2\":1}}', 2, NULL);

-- --------------------------------------------------------

--
-- Δομή πίνακα για τον πίνακα `moves`
--

CREATE TABLE `moves` (
  `id` bigint(20) NOT NULL,
  `game_id` int(11) NOT NULL,
  `player_id` int(11) NOT NULL,
  `move_json` text NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Άδειασμα δεδομένων του πίνακα `moves`
--

INSERT INTO `moves` (`id`, `game_id`, `player_id`, `move_json`, `created_at`) VALUES
(1, 1, 1, '{\"card\":\"3_D\",\"capture\":true,\"table_after\":[]}', '2026-01-30 00:58:04'),
(2, 1, 2, '{\"card\":\"5_C\",\"capture\":false,\"table_after\":[\"5_C\"]}', '2026-01-30 01:18:28'),
(3, 1, 1, '{\"card\":\"4_D\",\"capture\":false,\"table_after\":[\"5_C\",\"4_D\"]}', '2026-01-30 01:21:35'),
(4, 1, 2, '{\"card\":\"10_D\",\"capture\":false,\"table_after\":[\"5_C\",\"4_D\",\"10_D\"]}', '2026-01-30 01:23:00'),
(5, 1, 1, '{\"card\":\"9_H\",\"capture\":false,\"table_after\":[\"5_C\",\"4_D\",\"10_D\",\"9_H\"]}', '2026-01-30 01:28:10'),
(6, 1, 2, '{\"card\":\"J_H\",\"capture\":true,\"table_after\":[]}', '2026-01-30 01:29:04'),
(7, 1, 1, '{\"card\":\"K_S\",\"capture\":false,\"table_after\":[\"K_S\"]}', '2026-01-30 01:44:30'),
(8, 1, 2, '{\"card\":\"K_D\",\"capture\":true,\"table_after\":[]}', '2026-01-30 01:45:13'),
(9, 1, 1, '{\"card\":\"8_S\",\"capture\":false,\"table_after\":[\"8_S\"]}', '2026-01-30 01:45:51'),
(10, 1, 2, '{\"card\":\"K_C\",\"capture\":false,\"table_after\":[\"8_S\",\"K_C\"]}', '2026-01-30 01:46:32'),
(11, 1, 1, '{\"card\":\"6_H\",\"capture\":false,\"table_after\":[\"8_S\",\"K_C\",\"6_H\"]}', '2026-01-30 01:47:21'),
(12, 1, 2, '{\"card\":\"6_C\",\"capture\":true,\"table_after\":[]}', '2026-01-30 01:48:02'),
(13, 1, 1, '{\"card\":\"8_D\",\"capture\":false,\"table_after\":[\"8_D\"]}', '2026-01-30 01:51:41'),
(14, 1, 2, '{\"card\":\"4_S\",\"capture\":false,\"table_after\":[\"8_D\",\"4_S\"]}', '2026-01-30 01:52:10'),
(15, 1, 1, '{\"card\":\"A_D\",\"capture\":false,\"table_after\":[\"8_D\",\"4_S\",\"A_D\"]}', '2026-01-30 01:52:40'),
(16, 1, 2, '{\"card\":\"9_S\",\"capture\":false,\"table_after\":[\"8_D\",\"4_S\",\"A_D\",\"9_S\"]}', '2026-01-30 01:53:04'),
(17, 1, 1, '{\"card\":\"2_D\",\"capture\":false,\"table_after\":[\"8_D\",\"4_S\",\"A_D\",\"9_S\",\"2_D\"]}', '2026-01-30 01:55:39'),
(18, 1, 2, '{\"card\":\"6_S\",\"capture\":false,\"table_after\":[\"8_D\",\"4_S\",\"A_D\",\"9_S\",\"2_D\",\"6_S\"]}', '2026-01-30 01:56:16'),
(19, 1, 1, '{\"card\":\"A_S\",\"capture\":false,\"table_after\":[\"8_D\",\"4_S\",\"A_D\",\"9_S\",\"2_D\",\"6_S\",\"A_S\"]}', '2026-01-30 01:56:55'),
(20, 1, 2, '{\"card\":\"7_S\",\"capture\":false,\"table_after\":[\"8_D\",\"4_S\",\"A_D\",\"9_S\",\"2_D\",\"6_S\",\"A_S\",\"7_S\"]}', '2026-01-30 01:57:26'),
(21, 1, 1, '{\"card\":\"2_C\",\"capture\":false,\"table_after\":[\"8_D\",\"4_S\",\"A_D\",\"9_S\",\"2_D\",\"6_S\",\"A_S\",\"7_S\",\"2_C\"]}', '2026-01-30 01:57:58'),
(22, 1, 2, '{\"card\":\"7_D\",\"capture\":false,\"table_after\":[\"8_D\",\"4_S\",\"A_D\",\"9_S\",\"2_D\",\"6_S\",\"A_S\",\"7_S\",\"2_C\",\"7_D\"]}', '2026-01-30 01:58:20'),
(23, 1, 1, '{\"card\":\"Q_H\",\"capture\":false,\"table_after\":[\"8_D\",\"4_S\",\"A_D\",\"9_S\",\"2_D\",\"6_S\",\"A_S\",\"7_S\",\"2_C\",\"7_D\",\"Q_H\"]}', '2026-01-30 01:58:56'),
(24, 1, 2, '{\"card\":\"Q_D\",\"capture\":true,\"table_after\":[]}', '2026-01-30 01:59:17'),
(25, 1, 1, '{\"card\":\"8_H\",\"capture\":false,\"table_after\":[\"8_H\"]}', '2026-01-30 02:01:52'),
(26, 1, 2, '{\"card\":\"A_H\",\"capture\":false,\"table_after\":[\"8_H\",\"A_H\"]}', '2026-01-30 02:02:46'),
(27, 1, 1, '{\"card\":\"K_H\",\"capture\":false,\"table_after\":[\"8_H\",\"A_H\",\"K_H\"]}', '2026-01-30 02:03:20'),
(28, 1, 2, '{\"card\":\"5_D\",\"capture\":false,\"table_after\":[\"8_H\",\"A_H\",\"K_H\",\"5_D\"]}', '2026-01-30 02:03:49'),
(29, 1, 1, '{\"card\":\"6_D\",\"capture\":false,\"table_after\":[\"8_H\",\"A_H\",\"K_H\",\"5_D\",\"6_D\"]}', '2026-01-30 02:04:24'),
(30, 1, 2, '{\"card\":\"9_D\",\"capture\":false,\"table_after\":[\"8_H\",\"A_H\",\"K_H\",\"5_D\",\"6_D\",\"9_D\"]}', '2026-01-30 02:04:50'),
(31, 1, 1, '{\"card\":\"4_C\",\"capture\":false,\"table_after\":[\"8_H\",\"A_H\",\"K_H\",\"5_D\",\"6_D\",\"9_D\",\"4_C\"]}', '2026-01-30 02:05:15'),
(32, 1, 2, '{\"card\":\"10_C\",\"capture\":false,\"table_after\":[\"8_H\",\"A_H\",\"K_H\",\"5_D\",\"6_D\",\"9_D\",\"4_C\",\"10_C\"]}', '2026-01-30 02:05:44'),
(33, 1, 1, '{\"card\":\"8_C\",\"capture\":false,\"table_after\":[\"8_H\",\"A_H\",\"K_H\",\"5_D\",\"6_D\",\"9_D\",\"4_C\",\"10_C\",\"8_C\"]}', '2026-01-30 02:06:08'),
(34, 1, 2, '{\"card\":\"5_S\",\"capture\":false,\"table_after\":[\"8_H\",\"A_H\",\"K_H\",\"5_D\",\"6_D\",\"9_D\",\"4_C\",\"10_C\",\"8_C\",\"5_S\"]}', '2026-01-30 02:06:35'),
(35, 1, 1, '{\"card\":\"3_C\",\"capture\":false,\"table_after\":[\"8_H\",\"A_H\",\"K_H\",\"5_D\",\"6_D\",\"9_D\",\"4_C\",\"10_C\",\"8_C\",\"5_S\",\"3_C\"]}', '2026-01-30 02:06:59'),
(36, 1, 2, '{\"card\":\"J_S\",\"capture\":true,\"table_after\":[]}', '2026-01-30 02:07:17'),
(37, 1, 1, '{\"card\":\"A_C\",\"capture\":false,\"table_after\":[\"A_C\"]}', '2026-01-30 02:08:07'),
(38, 1, 2, '{\"card\":\"2_S\",\"capture\":false,\"table_after\":[\"A_C\",\"2_S\"]}', '2026-01-30 02:08:45'),
(39, 1, 1, '{\"card\":\"2_H\",\"capture\":true,\"table_after\":[]}', '2026-01-30 02:09:11'),
(40, 1, 2, '{\"card\":\"3_S\",\"capture\":false,\"table_after\":[\"3_S\"]}', '2026-01-30 02:09:38'),
(41, 1, 1, '{\"card\":\"J_C\",\"capture\":true,\"table_after\":[]}', '2026-01-30 02:10:56'),
(42, 1, 2, '{\"card\":\"10_S\",\"capture\":false,\"table_after\":[\"10_S\"]}', '2026-01-30 02:11:24'),
(43, 1, 1, '{\"card\":\"10_H\",\"capture\":true,\"table_after\":[]}', '2026-01-30 02:11:55'),
(44, 1, 2, '{\"card\":\"Q_S\",\"capture\":false,\"table_after\":[\"Q_S\"]}', '2026-01-30 02:12:26'),
(45, 1, 1, '{\"card\":\"J_D\",\"capture\":true,\"table_after\":[]}', '2026-01-30 02:12:52'),
(46, 1, 2, '{\"card\":\"4_H\",\"capture\":false,\"table_after\":[\"4_H\"]}', '2026-01-30 02:13:30'),
(47, 1, 1, '{\"card\":\"7_C\",\"capture\":false,\"table_after\":[\"4_H\",\"7_C\"]}', '2026-01-30 02:13:51'),
(48, 1, 2, '{\"card\":\"9_C\",\"capture\":false,\"table_after\":[]}', '2026-01-30 02:14:19');

-- --------------------------------------------------------

--
-- Δομή πίνακα για τον πίνακα `players`
--

CREATE TABLE `players` (
  `id` int(11) NOT NULL,
  `name` varchar(80) NOT NULL,
  `token` char(64) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Άδειασμα δεδομένων του πίνακα `players`
--

INSERT INTO `players` (`id`, `name`, `token`, `created_at`) VALUES
(1, 'Nikos', '46a0bc0409b4b6f577350d1e03dfb1eb', '2026-01-30 00:04:18'),
(2, 'Maria', '6e5730863ea13032692abcacb9033b2b', '2026-01-30 00:04:18');

--
-- Ευρετήρια για άχρηστους πίνακες
--

--
-- Ευρετήρια για πίνακα `games`
--
ALTER TABLE `games`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_games_creator` (`created_by_player_id`),
  ADD KEY `fk_games_turn` (`turn_player_id`),
  ADD KEY `fk_games_winner` (`winner_player_id`),
  ADD KEY `fk_games_last_cap` (`last_capture_player_id`);

--
-- Ευρετήρια για πίνακα `game_players`
--
ALTER TABLE `game_players`
  ADD PRIMARY KEY (`game_id`,`player_id`),
  ADD UNIQUE KEY `game_id` (`game_id`,`seat`),
  ADD KEY `fk_gp_player` (`player_id`);

--
-- Ευρετήρια για πίνακα `game_state`
--
ALTER TABLE `game_state`
  ADD PRIMARY KEY (`game_id`);

--
-- Ευρετήρια για πίνακα `moves`
--
ALTER TABLE `moves`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_moves_game` (`game_id`),
  ADD KEY `fk_moves_player` (`player_id`);

--
-- Ευρετήρια για πίνακα `players`
--
ALTER TABLE `players`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `token` (`token`);

--
-- AUTO_INCREMENT για άχρηστους πίνακες
--

--
-- AUTO_INCREMENT για πίνακα `games`
--
ALTER TABLE `games`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT για πίνακα `moves`
--
ALTER TABLE `moves`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=49;

--
-- AUTO_INCREMENT για πίνακα `players`
--
ALTER TABLE `players`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- Περιορισμοί για άχρηστους πίνακες
--

--
-- Περιορισμοί για πίνακα `games`
--
ALTER TABLE `games`
  ADD CONSTRAINT `fk_games_creator` FOREIGN KEY (`created_by_player_id`) REFERENCES `players` (`id`),
  ADD CONSTRAINT `fk_games_last_cap` FOREIGN KEY (`last_capture_player_id`) REFERENCES `players` (`id`),
  ADD CONSTRAINT `fk_games_turn` FOREIGN KEY (`turn_player_id`) REFERENCES `players` (`id`),
  ADD CONSTRAINT `fk_games_winner` FOREIGN KEY (`winner_player_id`) REFERENCES `players` (`id`);

--
-- Περιορισμοί για πίνακα `game_players`
--
ALTER TABLE `game_players`
  ADD CONSTRAINT `fk_gp_game` FOREIGN KEY (`game_id`) REFERENCES `games` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_gp_player` FOREIGN KEY (`player_id`) REFERENCES `players` (`id`) ON DELETE CASCADE;

--
-- Περιορισμοί για πίνακα `game_state`
--
ALTER TABLE `game_state`
  ADD CONSTRAINT `fk_state_game` FOREIGN KEY (`game_id`) REFERENCES `games` (`id`) ON DELETE CASCADE;

--
-- Περιορισμοί για πίνακα `moves`
--
ALTER TABLE `moves`
  ADD CONSTRAINT `fk_moves_game` FOREIGN KEY (`game_id`) REFERENCES `games` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_moves_player` FOREIGN KEY (`player_id`) REFERENCES `players` (`id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
