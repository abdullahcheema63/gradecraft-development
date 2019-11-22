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
          <li v-if="user.environment != 'production' "><a href="/subscriptions">My Subscription</a></li>
          <li><a @click.prevent="toggleModalState">View Tour</a></li>
          <li><a href="/logout">Logout</a></li>
        </ul>
      </div>
    </div>

    <modalComponent :modalState="modalState" @close="toggleModalState" class="component_container onboarding">
      <template slot="heading">Welcome to GradeCraft!</template>
      <template slot="content">
        <!-- <p style="background: yellow">
          To E from S: This onboarding div is for instructors
        </p> -->
        <vue-slick class="onboarding_slides instructor">
          <div class="slides instructor_1">
            <div></div>
            <div>
              <h2>Hey there, {{user.firstName}}!</h2>
              <p>
                Welcome to GradeCraft! This quick tour will introduce you to GradeCraft, a learning management system that supports gameful courses.
              </p>
            </div>
          </div>
          <div class="slides instructor_2">
            <div></div>
            <div>
              <h2>What is GradeCraft?</h2>
              <p>
                GradeCraft is a learning management system that helps you build gameful courses.
              </p>
              <ul class="pink_dots">
                <li>Supports personalized learning through assessment choice</li>
                <li>The Grade Predictor promotes student agency by enabling them to make choices and set goals
                <li>Analytics displays help students keep track of how they’re doing</li>
              </ul>
            </div>
          </div>
          <div class="slides instructor_3">
            <div></div>
            <div>
              <h2>Cross-platform Integration</h2>
              <p>
                Easily import data from other platforms and tools, such as Canvas.
              </p>
            </div>
          </div>
          <div class="slides instructor_4">
            <div></div>
            <div>
              <h2>Extensive Customization</h2>
              <p>
                You have freedom to tailor and personalize features, course settings, and language based on your unique scenarios and needs.
              </p>
            </div>
          </div>
          <div class="slides instructor_5">
            <div></div>
            <div>
              <h2>Class Analytics</h2>
              <p>
                Course and assignment analytics help students make sense of their progress and plan for success.
              </p>
            </div>
          </div>
          <div class="slides instructor_6">
            <div></div>
            <div>
              <h2>Build Motivation</h2>
              <p>
                Employ special features to motivate students, such as unlocks, badges, and dynamic grading schemes.
              </p>
            </div>
          </div>
        </vue-slick>

        <!-- <p style="background: yellow">
          and this onboarding div is for students/GSIs/not-instructors
        </p> -->
        <!-- <div class="onboarding_slides student">
          <div>
            <h2>Hey there, {{user.firstName}}!</h2>
            <p>
              Welcome to GradeCraft! This quick tour will show you how GradeCraft works.
            </p>
          </div>
        </div> -->
      </template>
      <template slot="cancel-link"> &nbsp; </template>
    </modalComponent>
  </div>
</template>

<script lang='coffee'>`
module.exports = {
  name: 'header-component',
  components: {
    modalComponent: () => VComponents.get('vue/components/structure/modalComponent'),
    vueSlickCarousel
  },
  props: {
    userId: String,
  },
  data() {
    return {
      prevScrollPos: null,
      activeUsername: false,
      activeFreetrialMsg: false,
      modalState: false,
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
