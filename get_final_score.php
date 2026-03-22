<?php
require_once 'db.php';
header('Content-Type: application/json');

$token = $_GET['token'] ?? null;

//  Βρισκουμε το παιχνίδι και τους παίκτες
$stmt = $pdo->prepare("
    SELECT g.id as game_id, p.id as p_id, p.name 
    FROM players p 
    JOIN game_players gp ON p.id = gp.player_id 
    JOIN games g ON gp.game_id = g.id 
    WHERE p.token = ?
");
$stmt->execute([$token]);
$current_player = $stmt->fetch();

if (!$current_player) {
    echo json_encode(['error' => 'Invalid token']);
    exit;
}

$game_id = $current_player['game_id'];

//  Παιρνουμε όλα τα δεδομένα του παιχνιδιού
$stmt = $pdo->prepare("SELECT state_json FROM game_state WHERE game_id = ?");
$stmt->execute([$game_id]);
$state = json_decode($stmt->fetch()['state_json'], true);

$stmt = $pdo->prepare("
    SELECT p.id, p.name 
    FROM players p 
    JOIN game_players gp ON p.id = gp.player_id 
    WHERE gp.game_id = ?
");
$stmt->execute([$game_id]);
$players = $stmt->fetchAll();

$results = [];
$max_cards = -1;
$winner_by_cards = null;

//  Υπολογιζουμε τους πόντους για κάθε παίκτη
foreach ($players as $p) {
    $pid = $p['id'];
    $name = $p['name'];
    $captured = $state['captured'][$pid] ?? [];
    $count_cards = count($captured);
    
    // Πόντοι από Ξερές (που ήδη υπάρχουν στο state)
    $points = $state['score'][$pid] ?? 0;
    
    // Πόντοι από συγκεκριμένα φύλλα
    foreach ($captured as $card) {
        $parts = explode('_', $card);
        $val = $parts[0];
        $suit = $parts[1];

        if ($val == 'A') $points += 1; // Άσσος
        if ($val == '10' && $suit == 'D') $points += 2; // 10 Καρό
        if ($val == '2' && $suit == 'C') $points += 1;  // 2 Σπαθί
        if ($val == 'J' || $val == 'Q' || $val == 'K' || ($val == '10' && $suit != 'D')) {
            $points += 1; // Φιγούρες και τα υπόλοιπα 10άρια
        }
    }

    $results[$pid] = [
        'name' => $name,
        'cards_count' => $count_cards,
        'points' => $points
    ];

    if ($count_cards > $max_cards) {
        $max_cards = $count_cards;
        $winner_by_cards = $pid;
    }
}

//  +3 πόντοι σε όποιον έχει τα περισσότερα φύλλα
if ($winner_by_cards !== null) {
    $results[$winner_by_cards]['points'] += 3;
}

// Σύγκριση για το τελικό μήνυμα δηλαδη ποιος παικτης κερδισε
$p_ids = array_keys($results);
$p1_id = $p_ids[0];
$p2_id = $p_ids[1];

$p1 = $results[$p1_id];
$p2 = $results[$p2_id];

if ($p1['points'] > $p2['points']) {
    $msg = "Ο νικητής είναι ο {$p1['name']} με σκορ {$p1['points']} > {$p2['points']}!";
} elseif ($p2['points'] > $p1['points']) {
    $msg = "Ο νικητής είναι ο {$p2['name']} με σκορ {$p2['points']} > {$p1['points']}!";
} else {
    $msg = "Ισοπαλία με σκορ {$p1['points']} - {$p2['points']}!";
}

echo json_encode([
    'results' => $results,
    'message' => $msg
], JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);