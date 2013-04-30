// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.
//
//= require jquery
//= require bootstrap.js
//= require_self

function fb_invite_friends() {
  FB.ui({
      method: 'apprequests',
      message: 'invites you to play hangman extreme and win airtime!',
    },
    function(response) {
      console.log('sendRequest response: ', response);
    });
}

$(document).ready(function () {
  if (!!window.EventSource) {
//    var source = new EventSource('/live_messages');
//    source.addEventListener('message', function(e) {
//      console.log(e.data);
//    }, false);
//
//    source.addEventListener('open', function(e) {
//      // Connection was opened.
//      console.log("open");
//    }, false);
//
//    source.addEventListener('error', function(e) {
//      if (e.readyState == EventSource.CLOSED) {
//        // Connection was closed.
//        console.log("close");
//      }
//    }, false);
  } else {
    // Result to xhr polling :(
  }
});

