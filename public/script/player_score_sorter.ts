/// <reference path="jquery.d.ts" />
/// <reference path="jquery.numberformatter.d.ts" />

module Refixative
{
  interface Score
  {
    achieve: number;
    achieve_diff: number;
    miss: number;
    miss_diff: number;
    rank: string;
  }

  interface Tune
  {
    lv: number;
    score: Score;
  }

  interface Song
  {
    id: number;
    basic: Tune;
    medium: Tune;
    hard: Tune;
    name: string;
  }

  class Order
  {
    static Ascending = new Order('asc');
    static Descending = new Order('desc');

    private classStr: string;

    constructor(cls: string)
    {
      this.classStr = cls;
    }

    toString()
    {
      return this.classStr;
    }
  }

  class Difficulty
  {
    static Basic = new Difficulty('basic');
    static Medium = new Difficulty('medium');
    static Hard = new Difficulty('hard');

    constructor(private s: string)
    {
    }

    toString()
    {
      return this.s;
    }
  }

  class SortPreference
  {
    constructor(
      public difficulty: Difficulty,
      public target: string,
      public order: Order)
    {
    }
  }

  enum SortMode
  {
    Default,
    Name,
    Level,
    Score
  }

  class PlayerScore
  {
    constructor(
      private score_data = [],
      private target_table:JQuery = null,
      private sort_mode = SortMode.Default,
      public sort_pref = new SortPreference(Difficulty.Basic, 'lv', Order.Ascending))
    {
      this.refreshSort();
    }

    /***** building table *****/
    private buildRow(item: Song) {
      var ps_row = $('<tr />').addClass('player_score');
      var av_row = $('<tr />').addClass('ave_diff');
      ps_row.append($('<td />').attr('rowspan', 2).append(
        $('<a />').attr('href', location.pathname + '/history/' + item['id']).text(item['name'])
      ));
      ['basic', 'medium', 'hard'].forEach(diff => {
        // Level
        ps_row.append(
          $('<td />').attr('rowspan', 2).text(item[diff]['lv'] == 11 ? '10+' : item[diff]['lv'])
        );
        if (item[diff]['score']) {
          var s = item[diff].score;
          // Player Score
          ps_row.append(
            // AR column
            $('<td />').text($.formatNumber(s.achieve, {format: '0.0'}) + '%'),
            // Miss column
            $('<td />').text(s.miss == 0 ? 'FC' : s.miss).addClass(s.miss == 0 ? 'fullcombo'
              : (s.miss == 1 ? 'miss1'
                : (s.miss == 2 ? 'miss2' : ''))),
            // Rank column
            $('<td />').attr('rowspan', 2).text(s.rank));
          // vs. Average
          av_row.append(
            // achievement
            $('<td />').text(s.achieve_diff == null ? 'N/A' : ($.formatNumber(s.achieve_diff, {format: '-0.0'}) + '%'))
            .addClass(s.achieve_diff == null ? 'vs_unavailable'
                : s.achieve_diff == 0.0 ? 'vs_ave_draw'
                : s.achieve_diff < 0 ? 'vs_ave_lose'
                : 'vs_ave_win'),
            // miss
            $('<td />').text(s.miss_diff == null ? 'N/A' : String($.formatNumber(s.miss_diff, {format: '-0'})))
              .addClass(s.miss_diff == null ? 'vs_unavailable'
                : s.miss_diff == 0.0 ? 'vs_ave_draw'
                : s.miss_diff < 0 ? 'vs_ave_win'
                : 'vs_ave_lose'));
        } else {
          // No score
          ps_row.append(
            $('<td />')
              .attr('rowspan', 2)
              .attr('colspan', 3)
              .addClass('noplay')
              .text('NO PLAY')
          );
        }
      });
      return {score: ps_row, vs_ave: av_row};
    }

    private buildTable(scores) {
      this.target_table.empty();
      $.each(scores, (index, value) => {
        var rows = this.buildRow(value);
        this.target_table.append(rows['score']);
        this.target_table.append(rows['vs_ave']);
      });
    }

    /***** UI *****/

    /***** score *****/
    private reverseOrder(order: Order) {
      switch (order) {
        case Order.Ascending:
          return Order.Descending;
        case Order.Descending:
          return Order.Ascending;
        default:
          console.log('[reverseOrder] Invalid Order: ' + order);
      }
    }

    private sort_by(order?: Order = Order.Ascending, selector?: (value: any) => any) {
      var rev = (order == Order.Ascending) ? -1 : 1;
      return (a, b) => {
        var x, y;
        if (typeof selector === 'undefined') {
          x = a;
          y = b;
        } else {
          x = selector(a);
          y = selector(b);
        }
        if (x > y) return rev * -1;
        if (x < y) return rev * 1;
        return 0;
      }
    }

    private scoreSort() {
      switch (this.sort_mode) {
        case SortMode.Name:
          return this.sort_by(this.sort_pref.order, x => x.name);
        case SortMode.Level:
          return this.sort_by(this.sort_pref.order, x => x[this.sort_pref.difficulty.toString()].lv);
        case SortMode.Score:
          return this.sort_by(this.sort_pref.order, x => x[this.sort_pref.difficulty.toString()].score[this.sort_pref.target]);
      }
    }

    refreshSort() {
      var scores = this.score_data.slice(0);
      var sort_func = this.scoreSort();
      if (this.sort_mode != SortMode.Default) {
        if (this.sort_mode == SortMode.Score) {
          var score_avail = scores.filter((val, index) =>
            !(typeof(val[this.sort_pref.difficulty.toString()].score) == 'undefined')
          );
          var score_not_avail = scores.filter((val, index) =>
            typeof(val[this.sort_pref.difficulty.toString()].score) == 'undefined'
          );
          score_avail.sort(sort_func);
          scores = score_avail.concat(score_not_avail);
        } else {
          scores.sort(sort_func);
        }
      }
      this.buildTable(scores);
    }

    changeMode(target_col, difficulty) {
      switch (this.sort_mode) {
        case SortMode.Default:
          switch (target_col) {
            case 'name':
              this.sort_mode = SortMode.Name;
              this.sort_pref.order = Order.Ascending;
              break;
            case 'lv':
              this.sort_mode = SortMode.Level;
              this.sort_pref.difficulty = difficulty;
              this.sort_pref.order = Order.Ascending;
              break;
            default:
              this.sort_mode = SortMode.Score;
              this.sort_pref.difficulty = difficulty;
              this.sort_pref.target = target_col;
              this.sort_pref.order = Order.Ascending;
              break;
          }
          break;
        case SortMode.Level:
          switch (target_col) {
            case 'name':
              this.sort_mode = SortMode.Name;
              this.sort_pref.order = Order.Ascending;
              break;
            case 'lv':
              if (this.sort_pref.difficulty == difficulty) {
                this.sort_pref.order = this.reverseOrder(this.sort_pref.order);
              } else {
                this.sort_pref.order = Order.Ascending;
                this.sort_pref.difficulty = difficulty;
              }
              break;
            default:
              this.sort_mode = SortMode.Score;
              this.sort_pref.difficulty = difficulty;
              this.sort_pref.target = target_col;
              this.sort_pref.order = Order.Ascending;
              break;
          }
          break;
        case SortMode.Name:
          switch (target_col) {
            case 'name':
              this.sort_pref.order = this.reverseOrder(this.sort_pref.order);
              break;
            case 'lv':
              this.sort_mode = SortMode.Level;
              this.sort_pref.difficulty = difficulty;
              this.sort_pref.order = Order.Ascending;
              break;
            default:
              this.sort_mode = SortMode.Score;
              this.sort_pref.difficulty = difficulty;
              this.sort_pref.target = target_col;
              this.sort_pref.order = Order.Ascending;
          }
          break;
        case SortMode.Score:
          switch (target_col) {
            case 'name':
              this.sort_mode = SortMode.Name;
              this.sort_pref.order = Order.Ascending;
              break;
            case 'lv':
              this.sort_mode = SortMode.Level;
              this.sort_pref.difficulty = difficulty;
              this.sort_pref.order = Order.Ascending;
              break;
            default:
              if (this.sort_pref.difficulty == difficulty && this.sort_pref.target == target_col) {
                this.sort_pref.order = this.reverseOrder(this.sort_pref.order);
              } else {
                this.sort_pref.difficulty = difficulty;
                this.sort_pref.target = target_col;
                this.sort_pref.order = Order.Ascending;
              }
              break;
          }
          break;
      }
    }
  }


  var player_score: PlayerScore;
  /***** events *****/
  $(document).ready(() => {
    // http://jquery-howto.blogspot.jp/2009/09/get-url-parameters-values-with-jquery.html
    var query = [], hash;
    var hashes = window.location.href.slice(window.location.href.indexOf('?') + 1).split('&');
    for(var i = 0; i < hashes.length; i++)
    {
        hash = hashes[i].split('=');
        query.push(hash[0]);
        query[hash[0]] = hash[1];
    }
    /* get player data */
    $.getJSON('/player/' + $("#player_id").val() + '.json' + (query['compare_with'] ? '?compare_with=' + query['compare_with'] : ''),
      json => player_score = new PlayerScore(json['scores'], $('table#score_data tbody')));
    $('.sort_header').click(e => {
      var $target = $(e.target);
      player_score.changeMode($target.data('colname'), $target.data('difficulty'));
      $('#sort_target').removeAttr('id').removeClass('asc desc');
      $target.attr('id', 'sort_target')
             .addClass(player_score.sort_pref.order.toString());
      player_score.refreshSort();
    });
  });
}
