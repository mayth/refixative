$ ->
  hash, query = []
  hashes = window.location.href.slice(window.location.href.indexOf('?'))
  player = new Vue(
    el: '#player'
  )