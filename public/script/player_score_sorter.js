$(document).ready(function() {
  var items = [];
  $.getJSON('/player/' + $("#player_id").text() + '.json',
    function(json) {
      $.each(json['scores'], function(key, value) {
        items.push('<li>' + key + '</li>');
      });
      $('<ul/>', {
        'class': 'js-test-list',
        html: items.join('')
      }).appendTo("#jstest");
    });
});
