// Magic
$(document).on("ready", function() {

  // MODAL - View/Hide modal
  $(".view_modal").on("click", function() {
    $(".wrapper").addClass("modal_on");
    $(".overlay").fadeIn(200);
    $(".modal").fadeIn(500);

    // Multiple modals
    if ( $(this).hasClass("modal_multiple") == true ){
      var modalId = $(this).attr("id");
      var modalHeading = $("#" + modalId + "_heading");
      var modalContent = $("#" + modalId + "_content");

      modalHeading.show();
      modalContent.show();
    } else {
    }
  })

  function closeModal() {
    $(".wrapper").removeClass("modal_on");
    $(".overlay").fadeOut(500);
    $(".modal").fadeOut(200);
    $(".modal .modal_multiple").fadeOut(200);
  }

  $(".modal .close, .overlay").on("click", closeModal)

  // HEADER - Change on scroll
  var prevScrollpos = window.pageYOffset;
  window.onscroll = function() {
    var currentScrollPos = window.pageYOffset;

    if (prevScrollpos > currentScrollPos) {
      document.getElementById("header").style.top = "0";
    } else {
      document.getElementById("header").style.top = "-70px";
    }
    prevScrollpos = currentScrollPos;

    if (window.pageYOffset > 20) {
      $("#header").addClass("fancy");
    } else {
      $("#header").removeClass("fancy")
    }

    $("#header a").focus(function() {
      document.getElementById("header").style.top = "0";
    });
  }

  // ACCORDIONS
  $(".accordion h3").on("click", function(){
    var aToggle = $(this);
    var aContent = aToggle.next("div");
    var aParent = aToggle.parent(".accordion");

    if ( aContent.is(":hidden") == true ){
      aToggle.addClass("open");
      aParent.addClass("active");
      aContent.slideDown(300);
    } else{
      aToggle.removeClass("open");
      aParent.removeClass("active");
      aContent.slideUp(300);
    }
  });
} );
