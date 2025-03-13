// SPDX-License-Identifier: CC0


/*
 /$$$$$$$$ /$$$$$$$  /$$$$$$$$ /$$$$$$$$        /$$$$$$   /$$$$$$
| $$_____/| $$__  $$| $$_____/| $$_____/       /$$__  $$ /$$__  $$
| $$      | $$  \ $$| $$      | $$            |__/  \ $$|__/  \ $$
| $$$$$   | $$$$$$$/| $$$$$   | $$$$$            /$$$$$/   /$$$$$/
| $$__/   | $$__  $$| $$__/   | $$__/           |___  $$  |___  $$
| $$      | $$  \ $$| $$      | $$             /$$  \ $$ /$$  \ $$
| $$      | $$  | $$| $$$$$$$$| $$$$$$$$      |  $$$$$$/|  $$$$$$/
|__/      |__/  |__/|________/|________/       \______/  \______/



 /$$
| $$
| $$$$$$$  /$$   /$$
| $$__  $$| $$  | $$
| $$  \ $$| $$  | $$
| $$  | $$| $$  | $$
| $$$$$$$/|  $$$$$$$
|_______/  \____  $$
           /$$  | $$
          |  $$$$$$/
           \______/
  /$$$$$$  /$$$$$$$$ /$$$$$$$$ /$$    /$$ /$$$$$$ /$$$$$$$$ /$$$$$$$
 /$$__  $$|__  $$__/| $$_____/| $$   | $$|_  $$_/| $$_____/| $$__  $$
| $$  \__/   | $$   | $$      | $$   | $$  | $$  | $$      | $$  \ $$
|  $$$$$$    | $$   | $$$$$   |  $$ / $$/  | $$  | $$$$$   | $$$$$$$/
 \____  $$   | $$   | $$__/    \  $$ $$/   | $$  | $$__/   | $$____/
 /$$  \ $$   | $$   | $$        \  $$$/    | $$  | $$      | $$
|  $$$$$$/   | $$   | $$$$$$$$   \  $/    /$$$$$$| $$$$$$$$| $$
 \______/    |__/   |________/    \_/    |______/|________/|__/


CC0 2023
*/


pragma solidity ^0.8.23;


import "./FreeChecker.sol";
import "./ThreeBallsGrid.sol";

interface GrailsV {
  function ownerOf(uint256 tokenId) external returns (address owner);
}


contract Free33 is FreeChecker {
  ThreeBallsGrid public threeBallsGrid;
  GrailsV public grailsV = GrailsV(0x92A50Fe6eDE411BD26e171B97472e24D245349B8);
  mapping(uint256 => bool) public THREE_BALLS;

  mapping(uint256 => uint256) public ballX;
  mapping(uint256 => uint256) public ballY;

  constructor() {
    THREE_BALLS[12] = true;
    THREE_BALLS[30] = true;
    THREE_BALLS[36] = true;
    THREE_BALLS[37] = true;
    THREE_BALLS[38] = true;
    THREE_BALLS[39] = true;
    THREE_BALLS[40] = true;
    THREE_BALLS[42] = true;
    THREE_BALLS[46] = true;
    THREE_BALLS[52] = true;
    THREE_BALLS[54] = true;
    THREE_BALLS[56] = true;
    THREE_BALLS[57] = true;
    THREE_BALLS[58] = true;
    THREE_BALLS[59] = true;
    THREE_BALLS[60] = true;
    THREE_BALLS[64] = true;
    THREE_BALLS[65] = true;
    THREE_BALLS[66] = true;
    THREE_BALLS[69] = true;
    THREE_BALLS[70] = true;
    THREE_BALLS[72] = true;
    THREE_BALLS[77] = true;
    THREE_BALLS[79] = true;
    THREE_BALLS[80] = true;
    THREE_BALLS[81] = true;
    THREE_BALLS[86] = true;
    THREE_BALLS[87] = true;
    THREE_BALLS[90] = true;
    THREE_BALLS[91] = true;
    THREE_BALLS[94] = true;
    THREE_BALLS[95] = true;
    THREE_BALLS[98] = true;
    THREE_BALLS[99] = true;
    THREE_BALLS[101] = true;
    THREE_BALLS[102] = true;

    threeBallsGrid = new ThreeBallsGrid(msg.sender);
  }

  function ballCoords(uint256 tokenId) external view returns (uint256 x, uint256 y) {
    return (ballX[tokenId], ballY[tokenId]);
  }

  function throwBall(uint256 grailsVTokenId) external {
    require(grailsV.ownerOf(grailsVTokenId) == msg.sender, 'Only owner can throw');
    require(THREE_BALLS[grailsVTokenId], 'Can only throw a ball');

    uint256 hash = uint256(keccak256(abi.encodePacked(
      block.prevrandao, block.gaslimit, grailsVTokenId
    )));

    ballX[grailsVTokenId] = 1 + hash % 6;
    ballY[grailsVTokenId] = 1 + (hash / 100000) % 6;
    threeBallsGrid.update();
  }

  function isLine(
    int[2] memory ball_a,
    int[2] memory ball_b,
    int[2] memory ball_c
  ) public pure returns (bool) {
    return _isLine(ball_a, ball_b, ball_c) && _isLine(ball_b, ball_c, ball_a);
  }

  function isOutOfBounds(int[2] memory ball) external pure returns (bool) {
    return _outOfBounds(ball[0]) || _outOfBounds(ball[1]);
  }

  function _outOfBounds(int n) internal pure returns (bool) {
    return 1 > n || n > 6;
  }

  function _isLine(
    int[2] memory ball_a,
    int[2] memory ball_b,
    int[2] memory ball_c
  ) internal pure returns (bool) {
    int ax = ball_a[0];
    int ay = ball_a[1];

    int bx = ball_b[0];
    int by = ball_b[1];

    int cx = ball_c[0];
    int cy = ball_c[1];

    if (
      _outOfBounds(ax) ||
      _outOfBounds(ay) ||
      _outOfBounds(bx) ||
      _outOfBounds(by) ||
      _outOfBounds(cx) ||
      _outOfBounds(cy)
    ) return false;


    int a_b_YDiff = by - ay;
    int a_c_YDiff = cy - ay;

    int a_b_XDiff = bx - ax;
    int a_c_XDiff = cx - ax;

    if (a_b_YDiff == 0 && a_c_YDiff == 0) return true;
    if (a_b_YDiff == 0) return a_b_XDiff == 0;
    if (a_c_YDiff == 0) return a_c_XDiff == 0;

    return (
      (a_b_XDiff * 60) / a_b_YDiff
      ==
      (a_c_XDiff * 60) / a_c_YDiff
    );
  }

  function claim(
    uint256 free0TokenId,
    uint256 ownedBallTokenId,
    uint256 supportingBallTokenId1,
    uint256 supportingBallTokenId2
  ) external {
    preCheck(free0TokenId, '33');

    require(grailsV.ownerOf(ownedBallTokenId) == msg.sender, 'Not owner of ball');
    require(
      ownedBallTokenId != supportingBallTokenId1 &&
      ownedBallTokenId != supportingBallTokenId2 &&
      supportingBallTokenId1 != supportingBallTokenId2,
      'Invalid supporting balls'
    );

    require(isLine(
        [int(ballX[ownedBallTokenId]), int(ballY[ownedBallTokenId])],
        [int(ballX[supportingBallTokenId1]), int(ballY[supportingBallTokenId1])],
        [int(ballX[supportingBallTokenId2]), int(ballY[supportingBallTokenId2])]
      ),
      'Balls not thrown in a straight line'
    );

    ballX[ownedBallTokenId] = 0;
    ballY[ownedBallTokenId] = 0;

    postCheck(free0TokenId, 33, '33');
  }
}