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
      var s = item[diff]['score'];
      // Player Score
      ps_row.append(
        // AR column
        $('<td />').text($.formatNumber(s['achieve'], {format: '0.0'}) + '%'),
        // Miss column
        $('<td />').text(s['miss']).addClass(s['miss'] == 0 ? 'fullcombo'
          : (s['miss'] == 1 ? 'miss1'
            : (s['miss'] == 2 ? 'miss2' : ''))),
        // Rank column
        $('<td />').attr('rowspan', 2).text(s['rank']));
      // vs. Average
      av_row.append(
        // achievement
        $('<td />').text($.formatNumber(s['achieve_diff'], {format:'-0.00'}) + '%')
          .addClass(s['achieve_diff'] == 0.0 ? 'vs_ave_draw'
            : (s['achieve_diff'] < 0 ? 'vs_ave_lose' : 'vs_ave_win')),
        // miss
        $('<td />').text($.formatNumber(s['miss_diff'], {format: '-0.0'}))
          .addClass(s['miss_diff'] == 0.0 ? 'vs_ave_draw'
            : (s['miss_diff'] < 0 ? 'vs_ave_win' : 'vs_ave_lose')));
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
function updateStatusText() {
  var text = '';
  switch (sort_mode) {
    case 'default':
      text = 'default';
      break;
    case 'name':
      text = (sort_pref.order == 'asc' ? 'ascending' : 'descending') + ' sort by name';
      break;
    case 'score':
      text = (sort_pref.order == 'asc' ? 'ascending' : 'descending')
        + ' sort by ' + sort_pref.target + ' of ' + sort_pref.difficulty;
      break;
  }
  $('#current_sort').text(text);
}

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
  if (sort_mode == 'name') {
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
  } else {
    if (sort_pref.target == 'lv') {
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
    } else {
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
}

/***** events *****/
$(document).ready(function() {
  /* get player data */
  $.getJSON('/player/' + $("#player_id").text() + '.json',
    function(json) {
      score_data = json['scores'];
      refreshSort();
      updateStatusText();
    });
  $('.sort_header').click(function(e) {
    var $target = $(e.target);
    var d = $target.data('difficulty');
    var target_col = $target.data('colname');
    switch (sort_mode) {
      case 'default':
        if (target_col == 'name') {
          sort_mode = 'name';
        } else {
          sort_mode = 'score';
          sort_pref.difficulty = d;
          sort_pref.target = target_col;
          sort_pref.order = 'asc';
        }
        break;
      case 'name':
        if (target_col == 'name') {
          sort_pref.order = reverseOrder(sort_pref.order);
        } else {
          sort_mode = 'score';
          sort_pref.difficulty = d;
          sort_pref.target = target_col;
          sort_pref.order = 'asc';
        }
        break;
      case 'score':
        if (target_col == 'name') {
          sort_mode = 'name';
          sort_pref.order = 'asc';
        } else {
          if (sort_pref.difficulty == d && sort_pref.target == target_col) {
            sort_pref.order = reverseOrder(sort_pref.order);
          } else {
            sort_pref.difficulty = d;
            sort_pref.target = target_col;
            sort_pref.order = 'asc';
          }
        }
        break;
    }
    refreshSort();
    updateStatusText();
  });
});
