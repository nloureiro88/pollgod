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
