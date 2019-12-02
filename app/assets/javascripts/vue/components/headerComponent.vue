<template>
  <div id="header" class="fancy">
    <a id="header_link" href="/overview" v-focus>
      <img class="small-hide" src="/assets/logo.svg" width="450" height="100" alt="Return to your GradeCraft dashboard" />
      <img class="small-show" src="/assets/logo-monogram.svg" width="110" height="100" alt="Return to your GradeCraft dashboard" />
    </a>
    <div class="header-actions" ref="clickAway">
      <a id="header_user" :class="{open:activeUsername}" @click="toggleUsername">{{ user.firstName + " " + user.lastName }}</a>
      <div :class="usernameClass">
        <ul>
          <li><a :href="user.accountURL">My Account</a></li>
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
  components: {
    modalComponent: () => VComponents.get('vue/components/structure/modalComponent'),
  },
  props: {
    userId: String,
  },
  data() {
    return {
      prevScrollPos: null,
      activeUsername: false,
      modalState: false,
    }
  },
  computed: {
    user(){
      return this.$store.getters.user
    },
    userIsInstructor(){
      var courseRoles = this.$store.state.user.courseMembership.map( course => {
        return course.role
      })
      return courseRoles.includes('professor')
    },
    usernameClass() {
      if (this.activeUsername) {
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
        this.activeUsername = false;
      } else {
        document.getElementById("header").style.top = "-70px";
        this.activeUsername = false;
      }

      this.prevScrollPos = currentScrollPos;
    },
    toggleUsername(e) {
      this.activeUsername = !this.activeUsername;
      if (this.activeUsername) {
        window.addEventListener('click', this.closeDropdowns);
      };
      e.stopPropagation();
    },
    closeDropdowns(e) {
      if(!this.$refs.clickAway.contains(e.target)){
        this.activeUsername = false;
        window.removeEventListener('click', this.closeDropdowns);
      }
    },
    close() {
      this.toggleModalState()
    },
    toggleModalState(){
      this.modalState = !this.modalState
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
