saveContents = () ->
  if loadFile
    if contents = loadFile path
      if re.test contents
        contents = contents.replace re, "$1\n#{editor.innerHTML.trim()}\n$3"
        mozillaSaveFile path, contents
        delete localStorage.contenteditable
        showMessage 'Saved to ' + path
      else
        showMessage 'Uable to parse the file!'
        window.re = re
        window.contents = contents
    else
      showMessage 'Cannot load ' + path
  else
    localStorage.value = codemirror.doc.getValue()
    showMessage 'Saved to browser local storage.'
    constructHelpText()


constructHelpText = () ->
    msg = ''
    if not /firefox/i.test navigator.userAgent
      msg += '<li>Install <a target=_blank href=http://firefox.com>Firefox</a>'
    if not loadFile
      msg += '<li>Install <a target=_blank href=http://addons.mozilla.org/
              en-us/firefox/addon/tiddlyfox />TiddlyFox</a>'
    if location.protocol isnt 'file:'
      msg += '<li>Open from your local computer'

    if msg then showMessage 'Did you know this file can edit itself?
        To enable:<br><ol class=table-list>' + msg + '</ol>'


showMessage = (content, id) ->
  id ?= content
  console.log "[Message#{if id isnt content then ":#{id}" else ''}] #{content}"
  if localStorage["message-suppressed:#{id}"] then return

  if displayedMessages[id]
    noticeContainer.removeChild displayedMessages[id]
    delete displayedMessages[id]

  noticeBar = document.createElement 'div'
  noticeBar.className = 'notice-bar'

  noticeBar.innerHTML = "<span class=message>#{content}</span>
                         <span class=buttons>
                           <button>OK</button>
                           <button>Don't show again</button>
                         </span>"

  okButton   = noticeBar.getElementsByTagName('button')[0]
  dontButton = noticeBar.getElementsByTagName('button')[1]

  okButton.onclick = () ->
    noticeContainer.removeChild noticeBar
    delete displayedMessages[id]

  dontButton.onclick = () ->
    noticeContainer.removeChild noticeBar
    delete displayedMessages[id]
    localStorage["message-suppressed:{id}"] = true

  noticeContainer.appendChild noticeBar
  displayedMessages[id] = noticeBar

displayedMessages = {}
loadFile = ''
setTimeout( ()->
  loadFile = window.mozillaLoadFile
, 100)
re = ///^(<!doctype.html>\n*<meta.charset="?utf-8"?>\n*
        <div.id="?editable"?.contenteditable="?true"?>)\n*
        ([\s\S]*)
        (<\/div><!--.editable.-->[\s\S]*)
     ///m

path = location.href.split('#')[0]
path = if /^file\:\/\/\/[A-Z]\:\//i.test path
         path.substr(8).replace /\//g,'\\'
       else
         path.replace /^file:(\/)+/, '/'

body = document.getElementsByTagName('body')[0]
noticeContainer = document.createElement 'div'
body.insertBefore noticeContainer, body.firstChild

editor = document.getElementById 'editor'
editor.addEventListener 'blur', saveContents

codemirror = null

if localStorage.contenteditable
  editor.innerHTML = localStorage.contenteditable
  showMessage 'Loaded from browser local storage.'
  setTimeout( () ->
    constructHelpText()
    if loadFile then saveContents()
  , 110)

setTimeout( () ->
  constructHelpText()
  codemirror = CodeMirror editor, options =
    mode:  "markdown"
    lineNumbers: true
    foldGutter:
      rangeFinder: CodeMirror.fold.indent
    gutters: ['CodeMirror-linenumbers', 'CodeMirror-foldgutter']
    value: localStorage.value || "#{path}"

  codemirror.on 'blur', saveContents

, 110)







