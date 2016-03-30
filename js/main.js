// Generated by CoffeeScript 1.10.0
(function() {
  var AILEVEL, Awale, ID, ref,
    indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  ref = [0, 1], ID = ref[0], AILEVEL = ref[1];

  Awale = (function() {
    function Awale() {
      var i, j, ref1, ref2;
      ref1 = [ID++, 0, 1, 1, 1], this.id = ref1[0], this.player = ref1[1], this.adversaire = ref1[2], this.pointeur = ref1[3], this.graphique = ref1[4];
      ref2 = [
        {}, {
          0: [1, 2, 3, 4, 5, 6],
          1: [7, 8, 9, 10, 11, 12]
        }, {
          0: 0,
          1: 0
        }
      ], this.trous = ref2[0], this.camps = ref2[1], this.score = ref2[2];
      for (i = j = 1; j <= 12; i = ++j) {
        this.trous[i] = 0;
      }
      this.depose_une_graine = function() {
        var rand;
        this.trous[this.pointeur] += 1;
        if (this.graphique) {
          $("#awale_" + this.id + " #" + this.pointeur).append("<div class='graine'></div>");
          rand = function() {
            return 15 + Math.floor(Math.random() * 35);
          };
          return $("#awale_" + this.id + " #" + this.pointeur + " .graine").last().css({
            transform: "rotate(" + (99 * rand()) + "deg)",
            top: (rand()) + "%",
            left: (rand()) + "%"
          });
        }
      };
      this.initialiser = function() {
        var k, results;
        results = [];
        for (i = k = 1; k <= 12; i = ++k) {
          if (this.graphique) {
            $("#awale_" + this.id + " #camp" + (i < 7 ? 0 : 1)).append("<div id='" + i + "' class='trou'>");
          }
          this.pointeur = i;
          results.push((function() {
            var l, results1;
            results1 = [];
            for (l = 1; l <= 4; l++) {
              results1.push(this.depose_une_graine());
            }
            return results1;
          }).call(this));
        }
        return results;
      };
      this.joueur_suivant = function() {
        var ref3;
        ref3 = [this.adversaire, this.player], this.player = ref3[0], this.adversaire = ref3[1];
        if (this.graphique) {
          return $("#awale_" + this.id + " .camp").toggleClass("selected");
        }
      };
      this.trou_suivant = function() {
        return this.pointeur = this.pointeur % 12 + 1;
      };
      this.trou_precedent = function() {
        return this.pointeur = this.pointeur === 1 ? 12 : this.pointeur - 1;
      };
      this.total_graines = function(joueur) {
        var g, k, len, ref3;
        g = 0;
        ref3 = this.camps[joueur];
        for (k = 0, len = ref3.length; k < len; k++) {
          i = ref3[k];
          g += this.trous[i];
        }
        return g;
      };
      this.prendre_les_graines = function() {
        var main, ref3;
        ref3 = [this.trous[this.pointeur], 0], main = ref3[0], this.trous[this.pointeur] = ref3[1];
        if (this.graphique) {
          $("#awale_" + this.id + " #" + this.pointeur).empty();
        }
        return main;
      };
      this.prenable = function() {
        var gain, origine, ref3, ref4, ref5;
        ref3 = [0, this.pointeur], gain = ref3[0], origine = ref3[1];
        while (((ref4 = this.trous[this.pointeur]) === 2 || ref4 === 3) && (ref5 = this.pointeur, indexOf.call(this.camps[this.adversaire], ref5) >= 0)) {
          gain += this.trous[this.pointeur];
          this.trou_precedent();
        }
        this.pointeur = origine;
        return (gain > 0) && (gain !== this.total_graines(this.adversaire));
      };
      this.prendre = function() {
        var main, ref3, ref4;
        while (((ref3 = this.trous[this.pointeur]) === 2 || ref3 === 3) && (ref4 = this.pointeur, indexOf.call(this.camps[this.adversaire], ref4) >= 0)) {
          main = this.prendre_les_graines();
          this.score[this.player] += main;
          this.trou_precedent();
        }
        if (this.graphique) {
          return $("#awale_" + this.id + " #score" + this.player).html(this.score[this.player]);
        }
      };
      this.reprendre_ses_graines = function() {
        var k, l, len, len1, player, ref3, ref4, results, trou;
        ref3 = [0, 1];
        results = [];
        for (k = 0, len = ref3.length; k < len; k++) {
          player = ref3[k];
          ref4 = this.camps[player];
          for (l = 0, len1 = ref4.length; l < len1; l++) {
            trou = ref4[l];
            this.pointeur = trou;
            this.score[player] += this.trous[this.pointeur];
            this.prendre_les_graines();
          }
          if (this.graphique) {
            results.push($("#score" + player).html(this.score[player]));
          } else {
            results.push(void 0);
          }
        }
        return results;
      };
      this.fin_de_jeu = function() {
        var config1, config2, ga, gp, k, len, ref3, ref4, ref5, t1, t2, t7, t8, the_end, trou;
        the_end = true;
        ref3 = [this.total_graines(this.player), this.total_graines(this.adversaire)], gp = ref3[0], ga = ref3[1];
        ref4 = [this.trous[1], this.trous[2], this.trous[7], this.trous[8]], t1 = ref4[0], t2 = ref4[1], t7 = ref4[2], t8 = ref4[3];
        config1 = (((gp === ga && ga === t1) && t1 === t7) && t7 === 1);
        config2 = ((gp === ga && ga === 2)) && ((((t1 === t2 && t2 === t7) && t7 === t8) && t8 === 1));
        if (config1 || config2) {
          return the_end;
        } else {
          ref5 = this.camps[this.player];
          for (k = 0, len = ref5.length; k < len; k++) {
            trou = ref5[k];
            if (this.jouable(trou)) {
              the_end = !the_end;
            }
            if (!the_end) {
              break;
            }
          }
        }
        return the_end;
      };
      this.nourrirAdversaire = function() {
        return (this.pointeur + this.trous[this.pointeur]) > (6 * this.player + 6);
      };
      this.jouable = function(pointeur) {
        var ref3;
        this.pointeur = pointeur;
        if ((ref3 = this.pointeur, indexOf.call(this.camps[this.player], ref3) >= 0) && (this.trous[this.pointeur] > 0)) {
          if (this.total_graines(this.adversaire) === 0) {
            return this.nourrirAdversaire();
          } else {
            return true;
          }
        } else {
          return false;
        }
      };
      this.jouer = function(pointeur) {
        var main, origine;
        this.pointeur = pointeur;
        origine = this.pointeur;
        main = this.prendre_les_graines();
        while (main > 0) {
          this.trou_suivant();
          if (this.pointeur !== origine) {
            this.depose_une_graine();
            main -= 1;
          }
        }
        if (this.prenable()) {
          this.prendre();
        }
        this.joueur_suivant();
        if (this.fin_de_jeu()) {
          if (this.graphique) {
            alert("jeu terminé !");
          }
          return this.reprendre_ses_graines();
        }
      };
      this.essayer = function(pointeur) {
        this.pointeur = pointeur;
        if (this.jouable(this.pointeur)) {
          return this.jouer(this.pointeur);
        } else {
          return $("#" + this.pointeur).append($("#info").html(":(").show());
        }
      };
    }

    return Awale;

  })();

  $(function() {
    var awale, first_shot, on_first_shot;
    awale = new Awale();
    awale.initialiser();
    $(".trou").on("click", function() {
      var t;
      t = parseInt($(this).attr("id"));
      $(".trou").removeClass("selected");
      return $(this).addClass("selected").append($("#info").html(awale.trous[t]).show());
    });
    first_shot = true;
    on_first_shot = function(trou) {
      var ref1;
      if (trou == null) {
        trou = Math.floor(Math.random() * 12) + 1;
      }
      ref1 = indexOf.call([1, 2, 3, 4, 5, 6], trou) >= 0 ? [0, 1] : [1, 0], awale.player = ref1[0], awale.adversaire = ref1[1];
      $("#awale_" + awale.id + " #camp" + awale.player).addClass("selected");
      return first_shot = false;
    };
    $(".trou").on("dblclick", function() {
      var t;
      $("#awale_" + awale.id).append($("#info").hide());
      t = parseInt($(this).attr("id"));
      if (first_shot) {
        on_first_shot(t);
      }
      return awale.essayer(t);
    });
    $("input[name=AIlevel]").on("click", function() {
      return AILEVEL = parseInt($(this).val());
    });
    return $("#ordi").on("click", function() {
      var a, adversaire, ai, best, j, len, level, max, ref1, ref2, virtual_shot;
      $("#awale_" + awale.id).append($("#info").hide());
      if (first_shot) {
        on_first_shot();
      }
      ref1 = [awale.player, awale.adversaire, 0, -49, 0], ai = ref1[0], adversaire = ref1[1], level = ref1[2], max = ref1[3], best = ref1[4];
      ref2 = awale.camps[awale.player];
      for (j = 0, len = ref2.length; j < len; j++) {
        best = ref2[j];
        if (awale.jouable(best)) {
          break;
        }
      }
      virtual_shot = function(awales) {
        var clone, delta, game, i, index, k, key, len1, new_awales, ref3, ref4, ref5, sa, sj;
        clone = function(obj) {
          var key, newInstance;
          if ((obj == null) || typeof obj !== 'object') {
            return obj;
          }
          newInstance = new obj.constructor();
          for (key in obj) {
            newInstance[key] = clone(obj[key]);
          }
          return newInstance;
        };
        new_awales = {};
        for (key in awales) {
          game = awales[key];
          ref3 = game.camps[game.player];
          for (k = 0, len1 = ref3.length; k < len1; k++) {
            i = ref3[k];
            if (game.jouable(i)) {
              new_awales[index = "" + key + i + "."] = clone(game);
              new_awales[index].graphique = false;
              new_awales[index].jouer(i);
              ref4 = [new_awales[index].score[ai], new_awales[index].score[adversaire]], sj = ref4[0], sa = ref4[1];
              if ((delta = sj - sa) > max) {
                ref5 = [delta, parseInt(index.slice(0, 2))], max = ref5[0], best = ref5[1];
                console.log("L" + level + ":" + sj + "-" + sa + " -> " + best + " [" + index + "]");
              }
            }
          }
        }
        return new_awales;
      };
      a = {
        "": awale
      };
      while (level++ < AILEVEL) {
        a = virtual_shot(a);
      }
      console.log("Je vais t'éclater en jouant le trou " + best);
      return awale.jouer(best);
    });
  });

}).call(this);
