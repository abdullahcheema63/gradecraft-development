<template>
  <div id="header" class="fancy">
    <a id="header_link" href="/overview" v-focus>
      <img class="small-hide" src="/assets/logo.svg" width="450" height="100" alt="Return to your GradeCraft dashboard" />
      <img class="small-show" src="/assets/logo-monogram.svg" width="110" height="100" alt="Return to your GradeCraft dashboard" />
    </a>
    <div class="header-actions" ref="clickAway">
      <p id="free_trial_user" v-if="!user.subscription" :class="{open:activeFreetrialMsg}" @click="toggleFreetrialMsg">
        <a class="small-hide">Free Trial Account</a>
        <a class="small-show">Free Trial</a>
      </p>
      <div v-if="user.subscription.length == false" :class="freetrialMsgClass" id="trial_msg">
        <p>
          With your
          <b>free trial account,</b>
          you can explore GradeCraft as much as you’d like! <br />
          The only things you can’t do are:
        </p>
        <ul>
          <li>Integrate with other tools (like Canvas or Moodle)</li>
          <li>Import or add other users (such as assistants and students)</li>
        </ul>
        <p>
          <a href="https://gradecraft.com/subscriptions/" target="_blank">Learn more about licensing options</a>
          to see what’s best for you! (MAKE SURE THIS LINK ON THE PUBLIC PAGES IS /subscriptions instead of /licenses)
        </p>
      </div>

      <a id="header_user" :class="{open:activeUsername}" @click="toggleUsername">{{ user.firstName + " " + user.lastName }}</a>
      <div :class="usernameClass">
        <ul>
          <li><a :href="user.accountURL">My Account</a></li>
          <li><a href="dashboard/#">View Tour</a></li>
          <li v-if="user.environment != 'production' "><a href="/subscriptions">My Subscription</a></li>
          <li><a href="/logout">Logout</a></li>
        </ul>
      </div>
    </div>
  </div>
</template>

<script lang='coffee'>`
module.exports = {
  name: 'header-component',
  props: {
    userId: String,
  },
  data() {
    return {
      prevScrollPos: null,
      activeUsername: false,
      activeFreetrialMsg: false,
    }
  },
  computed: {
    user(){
      return this.$store.getters.user
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
  },
  created: function() {
    this.$store.dispatch("getUser", this.userId)
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
        this.activeFreetrialMsg = false;
        this.activeUsername = false;
      } else {
        document.getElementById("header").style.top = "-70px";
        this.activeFreetrialMsg = false;
        this.activeUsername = false;
      }

      this.prevScrollPos = currentScrollPos;
    },
    toggleUsername(e) {
      this.activeUsername = !this.activeUsername;
      this.activeFreetrialMsg = false;
      if (this.activeUsername) {
        window.addEventListener('click', this.closeDropdowns);
      };
      e.stopPropagation();
    },
    toggleFreetrialMsg(e) {
      this.activeFreetrialMsg = !this.activeFreetrialMsg
      this.activeUsername = false;
      if (this.activeFreetrialMsg) {
        window.addEventListener('click', this.closeDropdowns);
      };
      e.stopPropagation();
    },
    closeDropdowns(e) {
      if(!this.$refs.clickAway.contains(e.target)){
        this.activeUsername = false;
        this.activeFreetrialMsg = false;
        window.removeEventListener('click', this.closeDropdowns);
      }
    }
  },
  directives: {
    focus: {
      bind: function(el){
        el.addEventListener('focus', function(e){
          e.target.offsetParent.style.top = "0";
        });
      }
    }
  }
}
`</script>
