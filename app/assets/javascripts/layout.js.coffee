configureFlashes = () ->
  # 'notice' will be closed automatically.
  setTimeout(() ->
    $('.flash .notice').slideUp('fast')
  , 3000)
  # 'alert' will be closed on being clicked.
  $('.flash .alert').click(() ->
    $(this).slideUp('fast')
  )
  # append instruction to close
  $('.flash .alert').append(
    $('<div>').addClass('closing-instruction').text('click to close')
  )

$(document).on('page:change', () ->
  configureFlashes()
)