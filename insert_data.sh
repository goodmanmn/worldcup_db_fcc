#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

TRUNCATE_TABLES=$($PSQL "TRUNCATE TABLE teams, games")
SEQUENCE_TEAMS=$($PSQL "ALTER SEQUENCE teams_team_id_seq RESTART")
SEQUENCE_GAMES=$($PSQL "ALTER SEQUENCE games_game_id_seq RESTART")
if [[ $TRUNCATE_TABLES == 'TRUNCATE TABLE' ]]
then
  echo "Truncating data from teams and games table"
fi

if [[ $SEQUENCE_TEAMS == 'ALTER SEQUENCE' ]]
then
  echo "Resetting teams primary key to 1"
fi

if [[ $SEQUENCE_GAMES == 'ALTER SEQUENCE' ]]
then
  echo "Resetting games primary key to 1"
fi

cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
if [[ $YEAR != 'year' ]]
then
# add winners and opponents to teams table
  TEAM_WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
  TEAM_OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")

  if [[ -z $TEAM_WINNER_ID ]]
  then
    WINNER_INSERT=$($PSQL "INSERT INTO teams(name) VALUES('$WINNER')")
  fi

  if [[ -z $TEAM_OPPONENT_ID ]]
  then
    OPPONENT_INSERT=$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT')")
  fi
  # add data to games table
  WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
  OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")

  GAMES_DATA_INSERT=$($PSQL "INSERT INTO games(year, round, winner_id, winner_goals, opponent_id, opponent_goals) VALUES($YEAR, '$ROUND', $WINNER_ID, $WINNER_GOALS, $OPPONENT_ID, $OPPONENT_GOALS)")
fi
done
echo "Team data inserted into teams table"
echo "Game data inserted into games table"
