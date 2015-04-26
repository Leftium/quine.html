saveContents = (contents) ->
  if window.mozillaSaveFile
    mozillaSaveFile path, contents
    inform "Saved to #{path}"
  else if window.localStorage isnt window.localData
      error 'No localStorage. Unable to save changes!', 'no-local-storage'
  else
    localData.value = contents
    warn 'Cannot write to local file system.
          Saved to browser local storage instead.<br>
          Changes will not be persisted outside this browser.'

constructHelpText = () ->
    msg = ''
    if not /firefox/i.test navigator.userAgent
      msg += '<li>Install <a target=_blank href=http://firefox.com>Firefox</a>'
    if not window.mozillaLoadFile
      msg += '<li>Install <a target=_blank href=http://addons.mozilla.org/
              en-us/firefox/addon/tiddlyfox />TiddlyFox</a>'
    if location.protocol isnt 'file:'
      msg += '<li>Open from your local computer'

    if msg then inform "Features may be missing or broken in this browser.<br>
                        (Did you know this file can save itself?)
                        To ensure full functionality:<br>
                        <ol class=table-list>#{msg}</ol>"

adjustSize = () ->
  codemirror?.setSize null, body.offsetHeight - noticeContainer.offsetHeight

hashcode = (s) ->
  hash = 5381
  for i in [0 ... s.length]
    cc = s.charCodeAt(i)
    hash = ((hash << 5) + hash) + cc
  hash

showMessage = (content, id, type = 'message') ->
  id ?= Math.abs(hashcode(content)).toString 16

  console.log "[#{type?.toUpperCase()}:#{id}] #{content}"
  if localData["message-suppressed:#{id}"] then return

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
    localData["message-suppressed:#{id}"] = true

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

# No localStorage in IE from file:/// protocol
if window.localStorage
    window.localData = window.localStorage
else
    window.localData = {}

loadFileReady = () ->
  constructHelpText()
  if localData isnt window.localStorage
    warn 'No localStorage. All changes will be lost!', 'no-local-storage'

  value = ''
  if window.mozillaLoadFile
    if localData.value
      inform "Found data to transfer from browser local storage..."
      saveContents localData.value
      value = localData.value
      delete localData.value
    else
      inform "Loaded from #{path}."
      value = window.mozillaLoadFile path
  else if localData.value
    warn 'Cannot read from local file system.
          Loaded from browser local storage instead.<br>
          The editor contents may differ from
          the actual file contents.'
    value = localData.value
    window.documentWritten ?= false
    if not window.documentWritten
      document.write value
      window.documentWritten = true
      return
  else
    warn 'Cannot read from local file system.
          Loaded from browser DOM instead.<br>
          The editor contents may slightly differ
          from the actual file contents.'
    value = document.documentElement.outerHTML
    value = value.replace /^<html>.*<body>/, ''  # Remove auto-inserted tags

  editor = document.getElementById 'editor'
  codemirror = CodeMirror editor, options =
    lineNumbers: true
    foldGutter:
      rangeFinder: CodeMirror.fold.indent
    gutters: ['CodeMirror-linenumbers', 'CodeMirror-foldgutter']
    value: value

  editor.appendChild noticeContainer
  adjustSize()
  codemirror.on 'changes', () -> saveContents codemirror.getValue()
  window.onresize = adjustSize

start = new Date().getTime()
timer = setInterval( () ->
  now = new Date().getTime()
  if window.mozillaLoadFile or now > (start + 80)
    clearInterval timer
    loadFileReady()
, 0)
