<?php
include('db.php');

// Παράμετροι από το αίτημα
$player1_name = $_POST['player1_name'];
$player2_name = $_POST['player2_name'];

// Δημιουργία νέου παιχνιδιού στη βάση δεδομένων
$sql = "INSERT INTO games (created_by_player_id, status) VALUES (1, 'waiting')";
if ($conn->query($sql) === TRUE) {
    $game_id = $conn->insert_id;

    // Εισαγωγή των παικτών στο παιχνίδι
    $sql_player1 = "INSERT INTO game_players (game_id, player_id, seat) VALUES ($game_id, (SELECT id FROM players WHERE name = '$player1_name'), 1)";
    $sql_player2 = "INSERT INTO game_players (game_id, player_id, seat) VALUES ($game_id, (SELECT id FROM players WHERE name = '$player2_name'), 2)";
    $conn->query($sql_player1);
    $conn->query($sql_player2);

    echo json_encode(["game_id" => $game_id, "status" => "Game created successfully."]);
} else {
    echo json_encode(["error" => "Error creating game: " . $conn->error]);
}
$conn->close();
?>
