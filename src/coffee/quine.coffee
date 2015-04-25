saveContents = (contents) ->
  if window.mozillaSaveFile
    mozillaSaveFile path, contents
    inform "Saved to #{path}"
  else
    localStorage.value = contents
    warn 'Cannot write to local file system.
          Saved to browser local storage instead.'

constructHelpText = () ->
    msg = ''
    if not /firefox/i.test navigator.userAgent
      msg += '<li>Install <a target=_blank href=http://firefox.com>Firefox</a>'
    if not window.mozillaLoadFile
      msg += '<li>Install <a target=_blank href=http://addons.mozilla.org/
              en-us/firefox/addon/tiddlyfox />TiddlyFox</a>'
    if location.protocol isnt 'file:'
      msg += '<li>Open from your local computer'

    if msg then warn "Some features may not be available.
                      (Did you know this file can save itself?)<br>
                      To ensure full functionality:<br>
                      <ol class=table-list>#{msg}</ol>"

adjustSize = () ->
  codemirror?.setSize null, body.offsetHeight - noticeContainer.offsetHeight


showMessage = (content, id = content, type) ->
  console.log "[Message#{if id isnt content then ":#{id}" else ''}] #{content}"
  if localStorage["message-suppressed:#{id}"] then return

  if displayedMessages[id]
    noticeContainer.removeChild displayedMessages[id]
    delete displayedMessages[id]

  noticeBar = document.createElement 'div'
  noticeBar.className = "notice-bar #{type}"

  noticeBar.innerHTML = "<span class=message>#{content}</span>
                         <span class=buttons>
                           <button>OK</button>
                           <button>Don't show again</button>
                         </span>"

  okButton   = noticeBar.getElementsByTagName('button')[0]
  dontButton = noticeBar.getElementsByTagName('button')[1]

  okButton.onclick = () ->
    noticeContainer.removeChild noticeBar
    adjustSize()
    delete displayedMessages[id]

  dontButton.onclick = () ->
    noticeContainer.removeChild noticeBar
    adjustSize()
    delete displayedMessages[id]
    localStorage["message-suppressed:#{id}"] = true

  noticeContainer.appendChild noticeBar
  adjustSize()

  displayedMessages[id] = noticeBar

inform = (content, id) ->
    showMessage content, id, 'info'

warn = (content, id) ->
    showMessage content, id, 'warn'

error = (content, id) ->
    showMessage content, id, 'error'



# Execution starts here

codemirror = null
displayedMessages = {}
path = location.href.split('#')[0]
path = if /^file\:\/\/\/[A-Z]\:\//i.test path
         path.substr(8).replace /\//g,'\\'
       else
         path.replace /^file:(\/)+/, '/'

body = document.body
noticeContainer = document.createElement 'div'
noticeContainer.className = 'notices'

setTimeout( () ->
  constructHelpText()

  value = ''
  if window.mozillaLoadFile
    if localStorage.value
      inform "Found data to transfer from browser local storage..."
      saveContents localStorage.value
      value = localStorage.value
      delete localStorage.value
    else
      inform "Loaded from #{path}."
      value = window.mozillaLoadFile path
  else if localStorage.value
    warn 'Cannot read from local file system.
          Loaded from browser local storage instead.'
    value = localStorage.value
    window.documentWritten ?= false
    if not window.documentWritten
      document.write value
      window.documentWritten = true
  else
    warn 'Cannot read from local file system.
          Loaded from browser DOM instead.'
    value = document.documentElement.outerHTML

  body.appendChild noticeContainer

  codemirror = CodeMirror document.getElementById('editor'), options =
    lineNumbers: true
    foldGutter:
      rangeFinder: CodeMirror.fold.indent
    gutters: ['CodeMirror-linenumbers', 'CodeMirror-foldgutter']
    value: value

  adjustSize()

  codemirror.on 'changes', () -> saveContents codemirror.getValue()
, 110)

