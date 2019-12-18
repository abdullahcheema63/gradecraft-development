<template>
  <div>
    <div v-if="1==0">
      <div :class="{open:active}">
        <p> saving this to remember how to bind a class to data / computed property if needed </p>
      </div>
    </div>

    <div v-if="this.successMessage && this.activeSuccess" class="success">
      <div class="alert_msg success" id="alert_msg_success">
        <p>{{this.successMessage}}</p>
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

    <div v-if="this.errorMessage && this.activeFailure" >
      <div class="alert_msg failure" id="alert_msg_fail">
        <p>{{this.errorMessage}}</p>
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
      options: {
        easing: 'ease-in',
      },
    }
  },
  methods: {
    closeFailureAlert(){
      this.activeFailure = false
      document.getElementById("alert_msg_fail").classList.add("closing")
      setTimeout(function() {
        document.getElementById("main_wrapper").classList.remove("has_alert")
      }, 200);
      this.$store.dispatch('removeErrorAlert')
    },
    closeSuccessAlert(){
      this.activeSuccess = false
      document.getElementById("alert_msg_success").classList.add("closing")
      setTimeout(function() {
        document.getElementById("main_wrapper").classList.remove("has_alert")
      }, 200);
      this.$store.dispatch('removeSuccessAlert')
    }
  },
  computed: {
    errorMessage(){
      return this.$store.state.errorAlertMessage
    },
    successMessage(){
      return this.$store.state.successAlertMessage
    }
  },
  watch: {
    errorMessage(newMessages, oldMessages){
      let wrapper = document.getElementById("main_wrapper")
      this.activeFailure = true
      wrapper.classList.add("has_alert")
      this.$scrollTo("#main_wrapper", 300, this.options)
      this.$root.$emit('closeAllModals')
      this.$root.$emit('revertToDefault')
    },
    successMessage(newMessages, oldMessages){
      this.activeSuccess = true
      let wrapper = document.getElementById("main_wrapper")
      wrapper.classList.add("has_alert")
      this.$scrollTo("#main_wrapper", 300, this.options)
      this.$root.$emit('closeAllModals')
      this.$root.$emit('revertToDefault')
    }
  }
}
`</script>
