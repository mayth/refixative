Vue.filter('level', (value) ->
  if value?
    if value == 11
      '10+'
    else
      value
  else
    null
)
Vue.filter('achievement', (value) ->
  if value?
    "#{value}%"
  else
    null
)
Vue.filter('rank', (value) ->
  if value?
    if value >= 95.0
      'AAA+'
    else if value >= 90.0
      'AAA'
    else if value >= 80.0
      'AA'
    else if value >= 70.0
      'A'
    else if value >= 50.0
      'B'
    else
      'C'
  else
    null
)
Vue.filter('fullcombo', (value) ->
  if value?
    if value == 0
      'FC'
    else
      value
  else
    null
)
Vue.filter('datetime', (value) ->
  if value?
    t = new Date(value)
    pad = (val) -> ("00#{val}").slice(-2)
    offset = t.getTimezoneOffset()
    if offset < 0
      offsetHours = pad(-offset / 60)
    else
      offsetHours = pad(offset / 60)
    offsetMinutes = pad(offset % 60)
    result = "#{t.getFullYear()}-#{pad(t.getMonth() + 1)}-#{pad(t.getDate())}" +
      " #{pad(t.getHours())}:#{pad(t.getMinutes())}:#{pad(t.getSeconds())}"
    if offset == 0
      result + " UTC"
    else if offset > 0
      result + " -#{offsetHours}:#{offsetMinutes}"
    else
      result + " +#{offsetHours}:#{offsetMinutes}"
  else
    null
)

$ ->
  page_id = $('body').attr('id')
  if page_id == 'players_show'
    id = $.url(location.href).segment(2)
    $.getJSON('/players/' + id + '.json', (result) ->
      player = new Vue(
        el: '#players_show',
        data: result
      )
    )
