$(document).on('page:change', () ->
  $('#players_upload').submit((e) =>
    formData = new FormData($('#players_upload form')[0])
    $.ajax({
      url: '/players/upload',
      type: 'post',
      data: formData,
      processData: false,
      contentType: false,
      dataType: 'html',
      success: (result) ->
        alert(result)
    })
    e.preventDefault()
  )
)