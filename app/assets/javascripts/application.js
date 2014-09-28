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
//= require jquery_ujs
//= require_tree .

$(document).ready(function(){
  FB.getLoginStatus(function(response) {
        if (response.status == 'connected') {
            var user_id = response.authResponse.userID;
            var page_id = "330123823834776"; //coca cola
            // var the_query = FB.Data.query(fql_query);

            FB.api('/me/likes/330123823834776', function(response) {
            // the_query.wait(function(rows) {

                if(response.data.length){
                  //the user already likes your page 
                  alert("Liked");
                }
                else{
                  //the user doesn'y like your page, or the user hasn't granted permission for you to access his likes. show him the like button
                  alert("Not Liked");
                  }
            });
        } else {
            alert("Not Logged in");
        }
    });
});