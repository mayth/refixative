score_data = [];
difficulties = ['basic', 'medium', 'hard'];
current_sort = 0;
current_order = 'asc';

function changeSort() {
  current_sort = (current_sort + 1) % difficulties.length;
  refreshSort();
  $('#current_sort').text(difficulties[current_sort]);
}

function reverseOrder() {
  if (current_order == 'asc') {
    current_order = 'desc';
  } else {
    current_order = 'asc';
  }
  refreshSort();
  $('#current_order').text(current_order);
}

function scoreMakeRow(item) {
  var ps_row = $('<tr />').addClass('player_score');
  var av_row = $('<tr />').addClass('ave_diff');
  ps_row.append($('<td />').attr('rowspan', 2).text(item['name']));
  difficulties.forEach(function(diff) {
    ps_row.append(
      $('<td />').attr('rowspan', 2).text(item[diff]['lv'])
    );
    if (item[diff]['score']) {
      var s = item[diff]['score'];
      ps_row.append(
        $('<td />').text($.formatNumber(s['achieve'], {format: '0.0'}) + '%')
      ).append(
        $('<td />').text(s['miss']).addClass(s['miss'] == 0 ? 'fullcombo'
          : (s['miss'] == 1 ? 'miss1'
            : (s['miss'] == 2 ? 'miss2' : '')))
      ).append(
        $('<td />').attr('rowspan', 2).text(s['rank'])
      );
      av_row.append(
        $('<td />').text($.formatNumber(s['achieve_diff'], {format:'-0.00'}) + '%')
          .addClass(s['achieve_diff'] == 0.0 ? 'vs_ave_draw'
            : (s['achieve_diff'] < 0 ? 'vs_ave_lose' : 'vs_ave_win'))
      ).append(
        $('<td />').text($.formatNumber(s['miss_diff'], {format: '-0.0'}))
          .addClass(s['miss_diff'] == 0.0 ? 'vs_ave_draw'
            : (s['miss_diff'] < 0 ? 'vs_ave_win' : 'vs_ave_lose'))
      );
    } else {
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

function scoreSort() {
  if (current_order == 'desc') {
    return function(a,b) {
      var target_diff = difficulties[current_sort];
      if (a[target_diff]['lv'] < b[target_diff]['lv']) return 1;
      if (a[target_diff]['lv'] > b[target_diff]['lv']) return -1;
      return 0;
    }
  } else {
    return function(a,b) {
      var target_diff = difficulties[current_sort];
      if (a[target_diff]['lv'] < b[target_diff]['lv']) return -1;
      if (a[target_diff]['lv'] > b[target_diff]['lv']) return 1;
      return 0;
    }
  }
}

function refreshSort() {
  scores = score_data.slice(0);
  scores.sort(scoreSort());
  var table = $('table#jstest tbody');
  table.empty();
  $.each(scores, function(index, value) {
    var rows = scoreMakeRow(value);
    table.append(rows[0]);
    table.append(rows[1]);
  });
}

$(document).ready(function() {
  $.getJSON('/player/' + $("#player_id").text() + '.json',
    function(json) {
      score_data = json['scores'];
      $('#current_sort').text(difficulties[current_sort]);
      refreshSort();
    });
});
