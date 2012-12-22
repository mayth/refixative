"use strict";
var score_data = [];
var sort_mode = 'default'
var sort_pref = {'difficulty': 'basic', 'target': 'lv', 'order': 'asc'}

/***** building table *****/
function buildRow(item) {
  var ps_row = $('<tr />').addClass('player_score');
  var av_row = $('<tr />').addClass('ave_diff');
  ps_row.append($('<td />').attr('rowspan', 2).text(item['name']));
  ['basic', 'medium', 'hard'].forEach(function(diff) {
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
        $('<td />').text($.formatNumber(s.achieve_diff, {format:'-0.00'}) + '%')
          .addClass(s.achieve_diff == 0.0 ? 'vs_ave_draw'
            : (s.achieve_diff < 0 ? 'vs_ave_lose' : 'vs_ave_win')),
        // miss
        $('<td />').text($.formatNumber(s.miss_diff, {format: '-0.0'}))
          .addClass(s.miss_diff == 0.0 ? 'vs_ave_draw'
            : (s.miss_diff < 0 ? 'vs_ave_win' : 'vs_ave_lose')));
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
  return [ps_row, av_row];
}

function buildTable(scores) {
  var table = $('table#score_data tbody');
  table.empty();
  $.each(scores, function(index, value) {
    var rows = buildRow(value);
    table.append(rows[0]);
    table.append(rows[1]);
  });
}

/***** UI *****/

/***** score *****/
function reverseOrder(order) {
  switch (order) {
    case 'asc':
      return 'desc';
    case 'desc':
      return 'asc';
    default:
      console.log('[reverseOrder] Invalid Order: ' + order);
  }
}

function refreshSort() {
  var scores = score_data.slice(0);
  var sort_func = scoreSort();
  if (sort_mode != 'default') {
    if (sort_mode == 'score') {
      var score_avail = scores.filter(function(val, index) {
        return !(typeof val[sort_pref.difficulty].score === 'undefined');
      });
      var score_not_avail = scores.filter(function(val, index) {
        return typeof val[sort_pref.difficulty].score === 'undefined';
      });
      score_avail.sort(sort_func);
      scores = score_avail.concat(score_not_avail);
    } else {
      scores.sort(sort_func);
    }
  }
  buildTable(scores);
}

function scoreSort() {
  switch (sort_mode) {
    case 'name':
      if (sort_pref.order == 'desc') {
        return function(a, b) {
          if (a.name < b.name) return 1;
          if (a.name > b.name) return -1;
          return 0
        }
      } else {
        return function(a, b) {
          if (a.name < b.name) return -1;
          if (a.name > b.name) return 1;
          return 0
        }
      }
      break;
    case 'lv':
      if (sort_pref.order == 'desc') {
        return function(a,b) {
          var a_val = a[sort_pref.difficulty].lv;
          var b_val = b[sort_pref.difficulty].lv;
          if (a_val < b_val) return 1;
          if (a_val > b_val) return -1;
          return 0;
        }
      } else {
        return function(a,b) {
          var a_val = a[sort_pref.difficulty].lv;
          var b_val = b[sort_pref.difficulty].lv;
          if (a_val < b_val) return -1;
          if (a_val > b_val) return 1;
          return 0;
        }
      }
      break;
    case 'score':
      if (sort_pref.order == 'desc') {
        return function(a,b) {
          var a_val = a[sort_pref.difficulty].score[sort_pref.target];
          var b_val = b[sort_pref.difficulty].score[sort_pref.target];
          if (typeof a_val === 'undefined') return 1;
          if (typeof b_val === 'undefined') return -1;
          if (a_val < b_val) return 1;
          if (a_val > b_val) return -1;
          return 0;
        }
      } else {
        return function(a,b) {
          var a_val = a[sort_pref.difficulty].score[sort_pref.target];
          var b_val = b[sort_pref.difficulty].score[sort_pref.target];
          if (typeof a_val === 'undefined' && typeof b_val === 'undefined') return 0;
          if (typeof a_val === 'undefined') return -1;
          if (typeof b_val === 'undefined') return 1;
          if (a_val < b_val) return -1;
          if (a_val > b_val) return 1;
          return 0;
        }
      }
  }
}

function changeMode(target_col, difficulty) {
  switch (sort_mode) {
    case 'default':
      switch (target_col) {
        case 'name':
          sort_mode = 'name';
          sort_pref.order = 'asc';
          break;
        case 'lv':
          sort_mode = 'lv';
          sort_pref.order = 'asc';
          break;
        default:
          sort_mode = 'score';
          sort_pref.difficulty = difficulty;
          sort_pref.target = target_col;
          sort_pref.order = 'asc';
          break;
      }
      break;
    case 'lv':
      switch (target_col) {
        case 'name':
          sort_mode = 'name';
          sort_pref.order = 'asc';
          break;
        case 'lv':
          if (sort_pref.difficulty == difficulty) {
            sort_pref.order = reverseOrder(sort_pref.order);
          } else {
            sort_pref.order = 'asc';
            sort_pref.difficulty = difficulty;
          }
          break;
        default:
          sort_mode = 'score';
          sort_pref.difficulty = difficulty;
          sort_pref.target = target_col;
          sort_pref.order = 'asc';
          break;
      }
      break;
    case 'name':
      switch (target_col) {
        case 'name':
          sort_pref.order = reverseOrder(sort_pref.order);
          break;
        case 'lv':
          sort_mode = 'lv';
          sort_pref.difficulty = difficulty;
          sort_pref.order = 'asc';
          break;
        default:
          sort_mode = 'score';
          sort_pref.difficulty = difficulty;
          sort_pref.target = target_col;
          sort_pref.order = 'asc';
      }
      break;
    case 'score':
      switch (target_col) {
        case 'name':
          sort_mode = 'name';
          sort_pref.order = 'asc';
          break;
        case 'lv':
          sort_mode = 'lv';
          sort_pref.difficulty = difficulty;
          sort_pref.order = 'asc';
          break;
        default:
          if (sort_pref.difficulty == difficulty && sort_pref.target == target_col) {
            sort_pref.order = reverseOrder(sort_pref.order);
          } else {
            sort_pref.difficulty = difficulty;
            sort_pref.target = target_col;
            sort_pref.order = 'asc';
          }
          break;
      }
      break;
  }
}

/***** events *****/
$(document).ready(function() {
  /* get player data */
  $.getJSON('/player/' + $("#player_id").text() + '.json',
    function(json) {
      score_data = json['scores'];
      refreshSort();
    });
  $('.sort_header').click(function(e) {
    var $target = $(e.target);
    changeMode($target.data('colname'), $target.data('difficulty'));
    $('#sort_target').removeAttr('id').removeClass('asc desc');
    $target.attr('id', 'sort_target').addClass(sort_pref.order);
    refreshSort();
  });
});
