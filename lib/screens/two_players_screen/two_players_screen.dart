import 'package:flutter/material.dart';

class TwoPlayersScreen extends StatefulWidget {
  const TwoPlayersScreen({super.key});

  @override
  State<TwoPlayersScreen> createState() => _TwoPlayersScreenState();
}

class _TwoPlayersScreenState extends State<TwoPlayersScreen> {
  static const int boardSize = 3;
  List<List<String>>? _board;
  String? _currentPlayer;
  String? _winner;
  List<List<int>>? _winningLine;

  @override
  void initState() {
    super.initState();
    _initializeGame();
  }

  void _initializeGame() {
    _board = List.generate(
      boardSize,
      (_) => List.generate(
        boardSize,
        (_) => '',
      ),
    );
    _currentPlayer = 'X';
    _winner = null;
    _winningLine = [];
  }

  void _resetGame() {
    setState(
      () {
        _initializeGame();
      },
    );
  }

  void _handleTap(int row, int col) {
    if (_board![row][col] != '' || _winner != null) {
      return;
    }

    setState(
      () {
        _board![row][col] = _currentPlayer!;
        if (_checkWinner(row, col)) {
          _winner = _currentPlayer;
        } else if (_isBoardFull()) {
          _winner = 'Draw';
        } else {
          _currentPlayer = _currentPlayer == 'X' ? 'O' : 'X';
        }
      },
    );
  }

  bool _checkWinner(int row, int col) {
    // Check the row
    if (_board![row].every((cell) => cell == _currentPlayer)) {
      _winningLine = List.generate(
        boardSize,
        (i) => [row, i],
      );
      return true;
    }
    // Check the column
    if (_board!.every((r) => r[col] == _currentPlayer)) {
      _winningLine = List.generate(
        boardSize,
        (i) => [i, col],
      );
      return true;
    }
    // Check the diagonals
    if (row == col &&
        _board!.every((r) => r[_board!.indexOf(r)] == _currentPlayer)) {
      _winningLine = List.generate(
        boardSize,
        (i) => [i, i],
      );
      return true;
    }
    if (row + col == boardSize - 1 &&
        _board!.every(
          (r) => r[boardSize - 1 - _board!.indexOf(r)] == _currentPlayer,
        )) {
      _winningLine = List.generate(
        boardSize,
        (i) => [i, boardSize - 1 - i],
      );
      return true;
    }
    return false;
  }

  bool _isBoardFull() {
    return _board!.every(
      (row) => row.every(
        (cell) => cell != '',
      ),
    );
  }

  Widget _buildCell(int row, int col) {
    bool isWinningCell = _winningLine!.any(
      (position) => position[0] == row && position[1] == col,
    );
    return GestureDetector(
      onTap: () => _handleTap(row, col),
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          border: Border.all(),
          color: isWinningCell ? Colors.green : Colors.white,
        ),
        child: Center(
          child: Text(
            _board![row][col],
            style: const TextStyle(fontSize: 32),
          ),
        ),
      ),
    );
  }

  Widget _buildBoard() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        boardSize,
        (row) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              boardSize,
              (col) {
                return _buildCell(row, col);
              },
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Two Players'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildBoard(),
            const SizedBox(height: 20),
            if (_winner != null)
              Text(
                _winner == 'Draw' ? 'It\'s a Draw!' : 'Player $_winner Wins!',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _resetGame,
              child: const Text('Reset Game'),
            ),
          ],
        ),
      ),
    );
  }
}
