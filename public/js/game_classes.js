// Generated by CoffeeScript 1.6.3
(function() {
  var Bishop, King, Knight, Pawn, Piece, Queen, Rook, Square, _ref, _ref1, _ref2, _ref3, _ref4, _ref5,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  window.Game = window.Game || {};

  window.Square = Square = (function() {
    function Square(name, row, col, piece) {
      this.name = name;
      this.row = row;
      this.col = col;
      this.piece = piece;
    }

    Square.prototype.movePiece = function(otherSquare) {
      if (this.piece == null) {
        return false;
      }
      if (this.piece.validMove(otherSquare) && squareIsValid(othersquare)) {
        return console.log('foo');
      }
    };

    return Square;

  })();

  window.Piece = Piece = (function() {
    function Piece(color, text) {
      this.color = color;
      this.text = text;
      this.graphic = "img/" + text + "_" + color + ".png";
    }

    Piece.prototype.move = function(startSquare, endSquare, cb) {
      if (this.validMove(startSquare, endSquare)) {
        console.log("valid move");
        /*
        endSquare.piece.graphic.remove() if endSquare.piece?
        @square = endSquare
        endSquare.piece = startSquare.piece
        startSquare.piece = undefined
        */

        return cb(true);
      }
      return cb(false);
    };

    Piece.prototype.validMove = function(startSquare, endSquare) {
      if ((endSquare.piece != null) && endSquare.piece.color === this.color) {
        return false;
      }
      return true;
    };

    Piece.prototype.toString = function() {
      return "" + this.color + " " + this.text;
    };

    return Piece;

  })();

  window.Pawn = Pawn = (function(_super) {
    __extends(Pawn, _super);

    function Pawn() {
      _ref = Pawn.__super__.constructor.apply(this, arguments);
      return _ref;
    }

    Pawn.prototype.validMove = function(startSquare, endSquare) {
      var dir, homeRow;
      if (!Pawn.__super__.validMove.call(this, startSquare, endSquare)) {
        return false;
      }
      dir = 1;
      if (this.color === "black") {
        dir = -1;
      }
      if (Math.abs(endSquare.x - startSquare.x) === 1 && (endSquare.piece != null) && endSquare.piece.color !== this.color) {
        return true;
      }
      if (dir * (endSquare.row - startSquare.row) === 1 && endSquare.col === startSquare.col && (endSquare.piece == null)) {
        return true;
      }
      homeRow = 2;
      if (this.color === "black") {
        homeRow = 7;
      }
      if (startSquare.row === homeRow && dir * (endSquare.row - startSquare.row) === 2 && endSquare.col === startSquare.col && (endSquare.piece == null)) {
        return true;
      }
      return false;
    };

    return Pawn;

  })(Piece);

  window.Rook = Rook = (function(_super) {
    __extends(Rook, _super);

    function Rook() {
      _ref1 = Rook.__super__.constructor.apply(this, arguments);
      return _ref1;
    }

    Rook.prototype.validMove = function(startSquare, endSquare) {
      if (!Rook.__super__.validMove.call(this, startSquare, endSquare)) {
        return false;
      }
      if (endSquare.x !== startSquare.x && endSquare.y !== startSquare.y) {
        /*
        console.log "invalid rook move"
        console.log startSquare
        console.log endSquare
        */

        return false;
      }
      return true;
    };

    return Rook;

  })(Piece);

  window.Knight = Knight = (function(_super) {
    __extends(Knight, _super);

    function Knight() {
      _ref2 = Knight.__super__.constructor.apply(this, arguments);
      return _ref2;
    }

    return Knight;

  })(Piece);

  window.Bishop = Bishop = (function(_super) {
    __extends(Bishop, _super);

    function Bishop() {
      _ref3 = Bishop.__super__.constructor.apply(this, arguments);
      return _ref3;
    }

    Bishop.prototype.validMove = function(startSquare, endSquare) {
      var slope, xDist, yDist;
      if (!Bishop.__super__.validMove.call(this, startSquare, endSquare)) {
        return false;
      }
      xDist = endSquare.x - startSquare.x;
      yDist = endSquare.y - startSquare.y;
      slope = xDist / yDist;
      return Math.abs(slope);
    };

    return Bishop;

  })(Piece);

  window.King = King = (function(_super) {
    __extends(King, _super);

    function King() {
      _ref4 = King.__super__.constructor.apply(this, arguments);
      return _ref4;
    }

    return King;

  })(Piece);

  window.Queen = Queen = (function(_super) {
    __extends(Queen, _super);

    function Queen() {
      _ref5 = Queen.__super__.constructor.apply(this, arguments);
      return _ref5;
    }

    return Queen;

  })(Piece);

}).call(this);
