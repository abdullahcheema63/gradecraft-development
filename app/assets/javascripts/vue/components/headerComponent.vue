<template>
  <div id="header">
    <a id="header_link" href="#">
      <img src="/assets/logo.svg" width="450" height="100" alt="Return to your GradeCraft dashboard" />
    </a>
  </div>
</template>

<script lang='coffee'>`
module.exports = {
  name: 'header-component',
  data() {
    return {
      prevScrollPos: null
    }
  },
  created: function() {
    this.prevScrollPos = window.pageYOffset;
    window.addEventListener('scroll', this.fancyScroll);
  },
  destroyed: function() {
    window.removeEventListener('scroll', this.fancyScroll);
  },
  methods: {
    fancyScroll(e) {
      var currentScrollPos = window.pageYOffset;

      if (this.prevScrollPos > currentScrollPos) {
        document.getElementById("header").style.top = "0";
      } else {
        document.getElementById("header").style.top = "-70px";
      }

      this.prevScrollPos = currentScrollPos;

      if (window.pageYOffset > 20) {
        document.getElementById("header").classList.add("fancy");
      } else {
        document.getElementById("header").classList.remove("fancy")
      }

      document.getElementById("header_link").focus(function() {
        document.getElementById("header").style.top = "0";
      });
    }
  }
}
`</script>
