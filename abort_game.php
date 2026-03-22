<?php
require_once 'db.php';
header('Content-Type: application/json');

$token = $_GET['token'] ?? null;

// Βρiσκουμε το παιχνίδι από το token του παίκτη
$stmt = $pdo->prepare("
    SELECT g.id FROM games g 
    JOIN game_players gp ON g.id = gp.game_id 
    JOIN players p ON gp.player_id = p.id 
    WHERE p.token = ?
");
$stmt->execute([$token]);
$game = $stmt->fetch();

if ($game) {
    // Θέτουμε το status σε 'finished' ή 'aborted'
    $update = $pdo->prepare("UPDATE games SET status = 'finished' WHERE id = ?");
    $update->execute([$game['id']]);
    echo json_encode(["status" => "success", "message" => "Game terminated by player"]);
} else {
    echo json_encode(["status" => "error", "message" => "Game not found"]);
}