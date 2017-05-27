$(document).ready(function(){
    applyFormListener();
    selectAllLevelsListener();
    selectAllLocationsListener();
    console.log("listening for form changes");
});

var applyFormListener = function() {
    $('#instructor_username').change(function(e){
      e.preventDefault();
      var first_name = $('#instructor_first_name').val();
      var last_name = $('#instructor_last_name').val();
      var email = $('#instructor_username').val();
      console.log("A user has entered their "+first_name+" "+last_name+" as their name and "+email+" as their email in the application form.");

      var request = $.ajax({
            url: "/notify_admin",
            type: "POST",
            data: {first_name: first_name, last_name: last_name, email: email}
      });
      request.done(function(data){
        console.log(data);
        console.log("successfully captured the email for "+data.email+" via ajax");
      });

  });
  }

  var selectAllLevelsListener = function() {
    $('#selectAllSkiLevels').click(function() {
    if (this.checked) {
       $('.ski-checkbox').each(function() {
           this.checked = true;
       });
    } else {
      $('.ski-checkbox').each(function() {
           this.checked = false;
       });
    }
    });

    $('#selectAllSnowboardLevels').click(function() {
    if (this.checked) {
       $('.snowboard-checkbox').each(function() {
           this.checked = true;
       });
    } else {
      $('.snowboard-checkbox').each(function() {
           this.checked = false;
       });
    }
    });
  }

    var selectAllLocationsListener = function() {
    $('#selectAll-NorthTahoe').click(function() {
    if (this.checked) {
       $('.NorthTahoe').each(function() {
           this.checked = true;
       });
    } else {
      $('.NorthTahoe').each(function() {
           this.checked = false;
       });
    }
    });

    $('#selectAll-SouthernCalifornia').click(function() {
    if (this.checked) {
       $('.SouthernCalifornia').each(function() {
           this.checked = true;
       });
    } else {
      $('.SouthernCalifornia').each(function() {
           this.checked = false;
       });
    }
    });

    $('#selectAll-NorthernCalifornia').click(function() {
    if (this.checked) {
       $('.NorthernCalifornia').each(function() {
           this.checked = true;
       });
    } else {
      $('.NorthernCalifornia').each(function() {
           this.checked = false;
       });
    }
    });

    $('#selectAll-CentralSierra').click(function() {
    if (this.checked) {
       $('.CentralSierra').each(function() {
           this.checked = true;
       });
    } else {
      $('.CentralSierra').each(function() {
           this.checked = false;
       });
    }
    });

    $('#selectAll-Nevada').click(function() {
    if (this.checked) {
       $('.Nevada').each(function() {
           this.checked = true;
       });
    } else {
      $('.Nevada').each(function() {
           this.checked = false;
       });
    }
    });

    $('#selectAll-SouthLakeTahoe').click(function() {
    if (this.checked) {
       $('.SouthLakeTahoe').each(function() {
           this.checked = true;
       });
    } else {
      $('.SouthLakeTahoe').each(function() {
           this.checked = false;
       });
    }
    });

    $('#selectAllLocations').click(function() {
    if (this.checked) {
       $('.location-checkbox').each(function() {
           this.checked = true;
       });
    } else {
      $('.location-checkbox').each(function() {
           this.checked = false;
       });
    }
    });
  }
