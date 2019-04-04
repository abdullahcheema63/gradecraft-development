<template>
  <div id="header" class="fancy">
    <a id="header_link" href="#">
      <img class="small-hide" src="/assets/logo.svg" width="450" height="100" alt="Return to your GradeCraft dashboard" />
      <img class="small-show" src="/assets/logo-monogram.svg" width="110" height="100" alt="Return to your GradeCraft dashboard" />
    </a>
    <div class="header-actions">
      <p id="free_trial_user" v-if="userHasPaid == false" :class="{open:activeFreetrialMsg}" @click="toggleFreetrialMsg">
        <a class="small-hide">Free Trial</a>
        <a class="small-show">Free</a>
      </p>
      <div :class="freetrialMsgClass">
        blahhh
      </div>

      <a id="header_user" :class="{open:activeUsername}" @click="toggleUsername">{{ getUserName }}</a>
      <div :class="usernameClass">
        <ul>
          <li><a href="">My Account</a></li>
          <li><a href="">View Tour</a></li>
          <li><a href="">Log Out</a></li>
        </ul>
      </div>
    </div>
  </div>
</template>

<script lang='coffee'>`
module.exports = {
  name: 'header-component',
  props: ['username_class', 'freetrial_msg_class'],
  data() {
    return {
      prevScrollPos: null,
      activeUsername: false,
      activeFreetrialMsg: false,
    }
  },
  computed: {
    userHasPaid(){
      return this.$store.getters.userHasPaid;
    },
    usernameClass() {
      if (this.activeUsername) {
        return 'is-open';
      }
      return 'is-closed';
    },
    freetrialMsgClass() {
      if (this.activeFreetrialMsg) {
        return 'is-open';
      }
      return 'is-closed';
    },
    getUserName(){
      return this.$store.getters.userName;
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

      document.getElementById("header_link").focus(function() {
        document.getElementById("header").style.top = "0";
      });
    },
    toggleUsername() {
      this.activeUsername = !this.activeUsername
    },
    toggleFreetrialMsg() {
      this.activeFreetrialMsg = !this.activeFreetrialMsg
    }
  }
}
`</script>
