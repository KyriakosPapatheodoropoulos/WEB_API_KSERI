<?php
require_once 'db.php';
header('Content-Type: application/json');

$token = $_POST['token'] ?? null;
$played_card = $_POST['card'] ?? null;

if (!$token || !$played_card) {
    echo json_encode(['error' => 'Token and Card are required']);
    exit;
}

//  Έλεγχος Παίκτη και Σειράς
$stmt = $pdo->prepare("
    SELECT p.id as p_id, g.id as g_id, g.turn_player_id 
    FROM players p 
    JOIN game_players gp ON p.id = gp.player_id 
    JOIN games g ON gp.game_id = g.id 
    WHERE p.token = ?
");
$stmt->execute([$token]);
$player = $stmt->fetch();

if (!$player || $player['turn_player_id'] != $player['p_id']) {
    echo json_encode(['error' => 'Not your turn or invalid token']);
    exit;
}

//  Λήψη State
$stmt = $pdo->prepare("SELECT state_json FROM game_state WHERE game_id = ?");
$stmt->execute([$player['g_id']]);
$state = json_decode($stmt->fetch()['state_json'], true);

$my_id = $player['p_id'];
$table = &$state['table'];
$hand = &$state['hands'][$my_id];

// Αφαίρεση κάρτας από το χέρι
$key = array_search($played_card, $hand);
if ($key === false) {
    echo json_encode(['error' => 'You dont have this card']); exit;
}
unset($hand[$key]);
$hand = array_values($hand);

$top_card = end($table);
$is_capture = false;

if ($top_card) {
    $val_played = explode('_', $played_card)[0];
    $val_top = explode('_', $top_card)[0];

    if ($val_played == $val_top || $val_played == 'J') {
        $is_capture = true;
        
        // Ενημέρωση last_capture_player_id στη βάση
        $stmt = $pdo->prepare("UPDATE games SET last_capture_player_id = ? WHERE id = ?");
        $stmt->execute([$my_id, $player['g_id']]);

        // Έλεγχος για Ξερή
        if (count($table) == 1) {
            $xera_points = ($val_played == 'J' && $val_top == 'J') ? 20 : 10;
            $state['xeres'][$my_id] += 1;
            $state['score'][$my_id] += $xera_points;
        }
        
        $state['captured'][$my_id] = array_merge($state['captured'][$my_id], $table, [$played_card]);
        $state['table'] = [];
    }
}

if (!$is_capture) {
    $state['table'][] = $played_card;
}

// ΕΛΕΓΧΟΣ ΓΙΑ REFILL Ή ΤΕΛΟΣ
$all_hands_empty = true;
foreach ($state['hands'] as $p_id => $p_hand) {
    if (count($p_hand) > 0) {
        $all_hands_empty = false;
        break;
    }
}

$game_finished = false;
if ($all_hands_empty) {
    if (count($state['deck']) > 0) {
        foreach ($state['hands'] as $p_id => &$p_hand_ref) {
            $p_hand_ref = array_splice($state['deck'], 0, 6);
        }
    } else {
        $game_finished = true;
        // Κανόνας τελευταίας μπάζας: Τα φύλλα που έμειναν στο τραπέζι πάνε στον τελευταίο που έκανε capture
        if (!empty($state['table'])) {
            $stmt = $pdo->prepare("SELECT last_capture_player_id FROM games WHERE id = ?");
            $stmt->execute([$player['g_id']]);
            $last_p = $stmt->fetchColumn();
            
            if ($last_p) {
                $state['captured'][$last_p] = array_merge($state['captured'][$last_p], $state['table']);
                $state['table'] = [];
            }
        }
    }
}

   //  ΑΠΟΘΗΚΕΥΣΗ ΚΙΝΗΣΗΣ ΣΤΟ ΙΣΤΟΡΙΚΟ δηλαδη στο πινακα moves
$move_log = json_encode([
    'card' => $played_card,
    'capture' => $is_capture,
    'table_after' => $state['table']
]);
$stmt = $pdo->prepare("INSERT INTO moves (game_id, player_id, move_json) VALUES (?, ?, ?)");
$stmt->execute([$player['g_id'], $my_id, $move_log]);

//  UPDATE της βασης
$stmt = $pdo->prepare("UPDATE game_state SET state_json = ? WHERE game_id = ?");
$stmt->execute([json_encode($state), $player['g_id']]);

$stmt = $pdo->prepare("SELECT player_id FROM game_players WHERE game_id = ? AND player_id != ?");
$stmt->execute([$player['g_id'], $my_id]);
$next_player = $stmt->fetch()['player_id'];

$new_status = $game_finished ? 'finished' : 'active';
$stmt = $pdo->prepare("UPDATE games SET turn_player_id = ?, status = ? WHERE id = ?");
$stmt->execute([$next_player, $new_status, $player['g_id']]);

//  RESPONSE
echo json_encode([
    'status' => 'success',
    'capture' => $is_capture,
    'game_status' => $new_status
]);