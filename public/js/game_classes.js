// Generated by CoffeeScript 1.6.3
(function() {
  var Bishop, King, Knight, Pawn, Piece, Queen, Rook, Square, _ref, _ref1, _ref2, _ref3, _ref4, _ref5,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  window.Game = window.Game || {};

  window.Square = Square = (function() {
    function Square(name, piece) {
      this.name = name;
      this.piece = piece;
    }

    return Square;

  })();

  window.Piece = Piece = (function() {
    function Piece(color, text) {
      this.color = color;
      this.text = text;
    }

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

    return Pawn;

  })(Piece);

  window.Rook = Rook = (function(_super) {
    __extends(Rook, _super);

    function Rook() {
      _ref1 = Rook.__super__.constructor.apply(this, arguments);
      return _ref1;
    }

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
