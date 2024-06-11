import 'dart:math';

import 'package:flutter/material.dart';

class MediumLevelScreen extends StatefulWidget {
  const MediumLevelScreen({super.key});

  @override
  State<MediumLevelScreen> createState() => _MediumLevelScreenState();
}

class _MediumLevelScreenState extends State<MediumLevelScreen> {
  static const int boardSize = 3;
  late List<List<String>> _board;
  late String _currentPlayer;
  String? _winner;
  List<List<int>> _winningLine = [];
  final Random _random = Random();

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
    setState(() {
      _initializeGame();
    });
  }

  void _handleTap(int row, int col) {
    if (_board[row][col] != '' || _winner != null) {
      return;
    }

    setState(() {
      _board[row][col] = _currentPlayer;
      if (_checkWinner(row, col)) {
        _winner = _currentPlayer;
      } else if (_isBoardFull()) {
        _winner = 'Draw';
      } else {
        _currentPlayer = _currentPlayer == 'X' ? 'O' : 'X';
        if (_currentPlayer == 'O') {
          _makeComputerMove();
        }
      }
    });
  }

  void _makeComputerMove() {
    if (_random.nextDouble() < .6) {
      _makeBestMove();
    } else {
      _makeRandomMove();
    }
  }

  void _makeBestMove() {
    int bestScore = -1000;
    List<int>? bestMove;

    for (int row = 0; row < boardSize; row++) {
      for (int col = 0; col < boardSize; col++) {
        if (_board[row][col] == '') {
          _board[row][col] = 'O';
          int score = _minimax(_board, 0, false);
          _board[row][col] = '';
          if (score > bestScore) {
            bestScore = score;
            bestMove = [row, col];
          }
        }
      }
    }

    if (bestMove != null) {
      _handleTap(bestMove[0], bestMove[1]);
    }
  }

  void _makeRandomMove() {
    List<List<int>> emptyCells = [];
    for (int row = 0; row < boardSize; row++) {
      for (int col = 0; col < boardSize; col++) {
        if (_board[row][col] == '') {
          emptyCells.add([row, col]);
        }
      }
    }

    if (emptyCells.isNotEmpty) {
      List<int> move = emptyCells[_random.nextInt(emptyCells.length)];
      _handleTap(move[0], move[1]);
    }
  }

  int _minimax(List<List<String>> board, int depth, bool isMaximizing) {
    String? result = _checkWinnerForMinimax(board);
    if (result != null) {
      if (result == 'O') {
        return 10 - depth;
      } else if (result == 'X') {
        return depth - 10;
      } else if (result == 'Draw') {
        return 0;
      }
    }

    if (isMaximizing) {
      int bestScore = -1000;
      for (int row = 0; row < boardSize; row++) {
        for (int col = 0; col < boardSize; col++) {
          if (board[row][col] == '') {
            board[row][col] = 'O';
            int score = _minimax(board, depth + 1, false);
            board[row][col] = '';
            bestScore = max(score, bestScore);
          }
        }
      }
      return bestScore;
    } else {
      int bestScore = 1000;
      for (int row = 0; row < boardSize; row++) {
        for (int col = 0; col < boardSize; col++) {
          if (board[row][col] == '') {
            board[row][col] = 'X';
            int score = _minimax(board, depth + 1, true);
            board[row][col] = '';
            bestScore = min(score, bestScore);
          }
        }
      }
      return bestScore;
    }
  }

  String? _checkWinnerForMinimax(List<List<String>> board) {
    // Check rows
    for (int row = 0; row < boardSize; row++) {
      if (board[row][0] != '' &&
          board[row][0] == board[row][1] &&
          board[row][1] == board[row][2]) {
        return board[row][0];
      }
    }
    // Check columns
    for (int col = 0; col < boardSize; col++) {
      if (board[0][col] != '' &&
          board[0][col] == board[1][col] &&
          board[1][col] == board[2][col]) {
        return board[0][col];
      }
    }
    // Check diagonals
    if (board[0][0] != '' &&
        board[0][0] == board[1][1] &&
        board[1][1] == board[2][2]) {
      return board[0][0];
    }
    if (board[0][2] != '' &&
        board[0][2] == board[1][1] &&
        board[1][1] == board[2][0]) {
      return board[0][2];
    }
    // Check for draw
    if (_isBoardFull()) {
      return 'Draw';
    }
    return null;
  }

  bool _checkWinner(int row, int col) {
    // Check the row
    if (_board[row].every((cell) => cell == _currentPlayer)) {
      _winningLine = List.generate(boardSize, (i) => [row, i]);
      return true;
    }
    // Check the column
    if (_board.every((r) => r[col] == _currentPlayer)) {
      _winningLine = List.generate(boardSize, (i) => [i, col]);
      return true;
    }
    // Check the diagonals
    if (row == col &&
        _board.every((r) => r[_board.indexOf(r)] == _currentPlayer)) {
      _winningLine = List.generate(boardSize, (i) => [i, i]);
      return true;
    }
    if (row + col == boardSize - 1 &&
        _board.every(
            (r) => r[boardSize - 1 - _board.indexOf(r)] == _currentPlayer)) {
      _winningLine = List.generate(boardSize, (i) => [i, boardSize - 1 - i]);
      return true;
    }
    return false;
  }

  bool _isBoardFull() {
    return _board.every((row) => row.every((cell) => cell != ''));
  }

  Widget _buildCell(int row, int col) {
    bool isWinningCell = _winningLine
        .any((position) => position[0] == row && position[1] == col);
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
            _board[row][col],
            style: const TextStyle(fontSize: 32),
          ),
        ),
      ),
    );
  }

  Widget _buildBoard() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(boardSize, (row) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(boardSize, (col) {
            return _buildCell(row, col);
          }),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medium Level'),
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
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
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