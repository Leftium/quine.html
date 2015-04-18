function start() {
  displayedMessages = {};
  re = /^(<!doctype html>\n*<meta charset=utf-8>\n*<div id=editable contenteditable=true>)\n*([\s\S]*)(<\/div><!-- editable -->[\s\S]*)/m;
  path = location.href.split("#")[0];
  path = /^file\:\/\/\/[A-Z]\:\//i.test(path) ?
      path.substr(8).replace(/\//g,'\\') : path.replace(/^file:(\/)+/, '/');

  var body = document.getElementsByTagName('body')[0];
  noticeContainer = document.createElement('div');
  body.insertBefore(noticeContainer, body.firstChild);
  editable = document.getElementById('editable');
  editable.addEventListener('blur', saveContents);

  if (localStorage['contenteditable']) {
    editable.innerHTML = localStorage['contenteditable'];
    showMessage('Loaded from browser local storage.');
    setTimeout(function() {
      constructHelpText();
      if (window.mozillaLoadFile || false) {
        saveContents();
      }
    }, 100);
  }
}
start();


function saveContents() {
  if (loadFile = window.mozillaLoadFile || false) {
    if (contents = loadFile(path)) {
      contents = contents.replace(re,
                                  '$1\n' + editable.innerHTML.trim() + '\n$3');
      mozillaSaveFile(path, contents);
      delete localStorage['contenteditable'];
      showMessage('Saved to ' + path);
    } else { showMessage('Cannot load ' + path); }
  } else {
    localStorage['contenteditable'] = editable.innerHTML;
    showMessage('Saved to browser local storage.');
    constructHelpText();
  }
}


function constructHelpText() {
    var msg = '';

    if (!/firefox/i.test(navigator.userAgent)) {
      msg += '<li>Install <a target=_blank href=http://firefox.com>Firefox</a>';
    }
    if (!(window.mozillaLoadFile || false)) {
      msg += '<li>Install <a target=_blank href=http://addons.mozilla.org/en-us/firefox/addon/tiddlyfox />TiddlyFox</a>'
    }
    if (location.protocol !== 'file:') {
      msg += '<li>Open from your local computer';
    }

    if (msg != '') {
      showMessage('Did you know this file can edit itself? To enable:<br><ol class=table-list>' + msg + '</ol>');
    }
}


function showMessage(content, id) {
  id = id || content;
  console.log('[Message' + (id != content ? ':' + id : '') + '] ' + content);
  if (localStorage['message-suppressed:' + id]) {
    return;
  }

  if (displayedMessages[id]) {
    noticeContainer.removeChild(displayedMessages[id]);
    delete displayedMessages[id];
  }

  var noticeBar = document.createElement('div');
  noticeBar.className = 'notice-bar';

  noticeBar.innerHTML = '<span class=message>' + content + '</span>' +
                        '<span class=buttons>                      ' +
                        '  <button>OK</button>                     ' +
                        "  <button>Don't show again</button>       " +
                        '</span>                                   ' ;

  var okButton   = noticeBar.getElementsByTagName('button')[0];
  var dontButton = noticeBar.getElementsByTagName('button')[1];

  okButton.onclick = function () {
    noticeContainer.removeChild(noticeBar);
    delete displayedMessages[id];
  }

  dontButton.onclick = function () {
    noticeContainer.removeChild(noticeBar);
    delete displayedMessages[id];
    localStorage['message-suppressed:' + id] = true;
  }

  noticeContainer.appendChild(noticeBar);
  displayedMessages[id] = noticeBar;
}
