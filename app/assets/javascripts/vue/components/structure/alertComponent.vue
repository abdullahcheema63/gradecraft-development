<template>
  <div>
    <div v-if="1==0">
      <div :class="{open:active}">
        <p> saving this to remember how to bind a class to data / computed property if needed </p>
      </div>
    </div>

    <div v-if="this.successMessages[0] && this.activeSuccess" class="success">
      <div class="success" id="alert_msg" v-for="message in this.successMessages">
        <p>{{message}} (E TO S: [Code] This and the failure_alert_msg id below will need to be v-bound and unique)</p>
        <svg @click="closeSuccessAlert()" version="1.1" class="close" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" x="0px" y="0px" width="25px"
        	 height="25px" viewBox="0 0 25 25" enable-background="new 0 0 25 25" xml:space="preserve">
        	<g>
      			<line fill="none" stroke-width="4" stroke-linecap="round" stroke-miterlimit="10"
              style="stroke: var(--strokeColor, #FFFFFF)"
              x1="2.5" y1="2.5" x2="22.5" y2="22.5"/>
      			<line fill="none" stroke-width="4" stroke-linecap="round" stroke-miterlimit="10"
              style="stroke: var(--strokeColor, #FFFFFF)"
              x1="2.5" y1="22.5" x2="22.5" y2="2.5"/>
        	</g>
        </svg>
      </div>
    </div>

    <div v-if="this.errorMessages[0] && this.activeFailure" >
      <div class="success" id="alert_msg" v-for="message in this.errorMessages">
        <p>{{message}} (E TO S: this is actually a failure message and needs to be styled TwT )</p>
        <svg @click="closeFailureAlert()" version="1.1" class="close" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" x="0px" y="0px" width="25px"
        	 height="25px" viewBox="0 0 25 25" enable-background="new 0 0 25 25" xml:space="preserve">
        	<g>
      			<line fill="none" stroke-width="4" stroke-linecap="round" stroke-miterlimit="10"
              style="stroke: var(--strokeColor, #FFFFFF)"
              x1="2.5" y1="2.5" x2="22.5" y2="22.5"/>
      			<line fill="none" stroke-width="4" stroke-linecap="round" stroke-miterlimit="10"
              style="stroke: var(--strokeColor, #FFFFFF)"
              x1="2.5" y1="22.5" x2="22.5" y2="2.5"/>
        	</g>
        </svg>
      </div>
    </div>
  </div>
</template>


<script lang='coffee'>`
module.exports = {
  name: 'alert-component',
  data() {
    return {
      activeSuccess: true,
      activeFailure: true,
    }
  },
  methods: {
    closeFailureAlert(){
      console.log("will need to pass in id for the svg to no which one to close")
      this.activeFailure = false
      document.getElementById("alert_msg").classList.add("closing")
      setTimeout(function() {
        document.getElementById("main_wrapper").classList.remove("has_alert")
      }, 400);
    },
    closeSuccessAlert(){
      console.log("will need to pass in id for the svg to no which one to close")
      this.activeFailure = false
      document.getElementById("alert_msg").classList.add("closing")
      setTimeout(function() {
        document.getElementById("main_wrapper").classList.remove("has_alert")
      }, 400);
    }

  },
  computed: {
    errorMessages(){
      return this.$store.state.errorAlertMessages
    },
    successMessages(){
      return this.$store.state.successAlertMessages
    }
  },
  watch: {
    errorMessages(newMessages, oldMessages){
      let wrapper = document.getElementById("main_wrapper")
      wrapper.classList.add("has_alert")
    },
    successMessages(newMessages, oldMessages){
      let wrapper = document.getElementById("main_wrapper")
      wrapper.classList.add("has_alert")
    }
  }
}
`</script>
