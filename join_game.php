<?php
require_once 'db.php';
header('Content-Type: application/json');

$name = $_POST['name'] ?? null;
if (!$name) {
    echo json_encode(['error' => 'Player name is required']);
    exit;
}

//  ΠΙΝΑΚΑΣ players: Δημιουργία παίκτη και Token
$token = bin2hex(random_bytes(16));
$stmt = $pdo->prepare("INSERT INTO players (name, token) VALUES (?, ?)");
$stmt->execute([$name, $token]);
$player_id = $pdo->lastInsertId();

//  Έλεγχουμε αν υπάρχει διαθέσιμο παιχνίδι που περιμένει (waiting)
$stmt = $pdo->prepare("SELECT id, max_players FROM games WHERE status = 'waiting' LIMIT 1");
$stmt->execute();
$game = $stmt->fetch();

if (!$game) {
    //  ΑΡΧΙΚΟΠΟΙΗΣΗ ΝΕΟΥ ΠΑΙΧΝΙΔΙΟΥ (για τον 1ο παίκτη)
    // Εδώ χρησιμοποιούμε το max_players (2) και το created_by_player_id
    $stmt = $pdo->prepare("INSERT INTO games (status, max_players, created_by_player_id, turn_player_id) VALUES ('waiting', 2, ?, ?)");
    $stmt->execute([$player_id, $player_id]);
    $game_id = $pdo->lastInsertId();

    // Δημιουργία τράπουλας
    $suits = ['C', 'D', 'H', 'S']; 
    $values = ['A', '2', '3', '4', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K'];
    $deck = [];
    foreach ($suits as $s) {
        foreach ($values as $v) {
            $deck[] = $v . '_' . $s;
        }
    }
    shuffle($deck);

    // Μοίρασμα: 4 στο τραπέζι, 6 στον πρώτο παίκτη
    $table = array_splice($deck, 0, 4);
    $p1_hand = array_splice($deck, 0, 6);

    $initial_state = [
        'deck' => $deck,
        'table' => $table,
        'hands' => [
            $player_id => $p1_hand
        ],
        'captured' => [
            $player_id => []
        ],
        'score' => [
            $player_id => 0
        ],
        'xeres' => [
            $player_id => 0
        ]
    ];

    // ΑΞΙΟΠΟΙΗΣΗ ΠΙΝΑΚΑ game_state
    $stmt = $pdo->prepare("INSERT INTO game_state (game_id, state_json, version) VALUES (?, ?, 1)");
    $stmt->execute([$game_id, json_encode($initial_state)]);

} else {
    $game_id = $game['id'];
    $max_players = $game['max_players'];

    //  Έλεγχος αν το παιχνίδι γέμισε
    $stmt = $pdo->prepare("SELECT COUNT(*) FROM game_players WHERE game_id = ?");
    $stmt->execute([$game_id]);
    $current_count = $stmt->fetchColumn();

    if ($current_count >= $max_players) {
        echo json_encode(['error' => 'Game is full!']);
        exit;
    }

    // Λήψη state για τον 2ο παίκτη
    $stmt = $pdo->prepare("SELECT state_json FROM game_state WHERE game_id = ?");
    $stmt->execute([$game_id]);
    $row = $stmt->fetch();
    $state = json_decode($row['state_json'], true);

    // Μοίρασμα 6 φύλλων στον 2ο παίκτη
    $p2_hand = array_splice($state['deck'], 0, 6);
    $state['hands'][$player_id] = $p2_hand;
    $state['captured'][$player_id] = [];
    $state['score'][$player_id] = 0;
    $state['xeres'][$player_id] = 0;

    // Ενημέρωση state και version 
    $stmt = $pdo->prepare("UPDATE game_state SET state_json = ?, version = version + 1 WHERE game_id = ?");
    $stmt->execute([json_encode($state), $game_id]);

    // Το παιχνίδι ξεκινάει 
    $stmt = $pdo->prepare("UPDATE games SET status = 'active', started_at = CURRENT_TIMESTAMP WHERE id = ?");
    $stmt->execute([$game_id]);
}

   //ΠΙΝΑΚΑΣ game_players εδω κανουμε σύνδεση παίκτη-παιχνιδιού με seat
$seat = $game ? 2 : 1;
$stmt = $pdo->prepare("INSERT INTO game_players (game_id, player_id, seat) VALUES (?, ?, ?)");
$stmt->execute([$game_id, $player_id, $seat]);

// JSON Response
echo json_encode([
    'status' => 'success',
    'token' => $token,
    'player_id' => $player_id,
    'game_id' => $game_id,
    'seat' => $seat,
    'message' => $game ? 'Joined game as Player 2' : 'Created game as Player 1'
]);