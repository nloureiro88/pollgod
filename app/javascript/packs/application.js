import "bootstrap";

//= require data-confirm-modal


$(document).ready(function(){
    $('[data-toggle="tooltip"]').tooltip(
      {container:'body', trigger: 'hover', placement:"top"}
    );
  });

$(document).ready(function(){
    $('[data-toggle="tooltip-bottom"]').tooltip(
      {container:'body', trigger: 'hover', placement:"bottom"}
    );
  });

// function isTouchDevice(){
//     return true == ("ontouchstart" in window || window.DocumentTouch && document instanceof DocumentTouch);
// };
