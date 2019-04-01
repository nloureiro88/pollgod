//= require data-confirm-modal

import "bootstrap";

$(document).ready(function(){
    $('[data-toggle="tooltip-all"]').tooltip(
      {container:'body', trigger: 'hover', placement:"top"}
    );
  });

function isTouchDevice(){
    return true == ("ontouchstart" in window || window.DocumentTouch && document instanceof DocumentTouch);
};

if(isTouchDevice()===false) {
  $('[data-toggle="tooltip"]').tooltip({ trigger: "hover" });
  $('[data-toggle="tooltip-bottom"]').tooltip({ trigger: "hover" });
};
