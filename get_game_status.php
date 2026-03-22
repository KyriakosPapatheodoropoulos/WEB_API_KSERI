<?php
require_once 'db.php';
header('Content-Type: application/json');

$token = $_GET['token'] ?? null;

if (!$token) {
    echo json_encode(['error' => 'Token is required']);
    exit;
}

// Βρες τον παίκτη και το παιχνίδι του
$stmt = $pdo->prepare("
    SELECT p.id as player_id, p.name, gp.game_id, g.status, g.turn_player_id 
    FROM players p
    JOIN game_players gp ON p.id = gp.player_id
    JOIN games g ON gp.game_id = g.id
    WHERE p.token = ?
");
$stmt->execute([$token]);
$player_data = $stmt->fetch();

if (!$player_data) {
    echo json_encode(['error' => 'Invalid token or player not in game']);
    exit;
}

// Πάρε το state του παιχνιδιού
$stmt = $pdo->prepare("SELECT state_json FROM game_state WHERE game_id = ?");
$stmt->execute([$player_data['game_id']]);
$state_row = $stmt->fetch();
$state = json_decode($state_row['state_json'], true);

$my_id = $player_data['player_id'];
$is_my_turn = ($player_data['turn_player_id'] == $my_id);

//Εδω γινεται η εμφάνιση Board (Βασικό GUI) 
$response = [
    'game_status' => $player_data['status'],
    'turn' => $is_my_turn ? "YOUR TURN" : "WAITING FOR OPPONENT",
    'table_top_card' => empty($state['table']) ? "EMPTY" : end($state['table']),
    'all_table_cards' => $state['table'], // <--- Τώρα φαίνονται όλα τα φύλλα κάτω
    'cards_on_table_count' => count($state['table']),
    'your_hand' => $state['hands'][$my_id],
    'your_captured_count' => count($state['captured'][$my_id] ?? []),
    'your_xeres' => $state['xeres'][$my_id] ?? 0,
    'your_current_score' => $state['score'][$my_id] ?? 0 // Πόντοι από Ξερές
];

echo json_encode($response, JSON_PRETTY_PRINT);