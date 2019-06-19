<template>
  <form @submit.prevent="submit" >
    <h2>Upgrade My Account</h2>
    <div v-if="hasErrors" class="alert-box">
      {{errors}}
    </div>
    <p>We’re thrilled that you like what GradeCraft has to offer, and want to upgrade your account by purchasing a license! </p>

    <h3>Choose Your Account License</h3>
    <div class="flex-3 selection_cards">
      <div class="form_options" v-for="lt of licenseTypeOptions" :key="lt.id">
        <licenses-type-radio-button
          :selected="licenseType"
          :on-selected="() => onLicenseTypeSelected(lt)"
          :license-type="lt" />
      </div>
    </div>

    <licenses-payment-inputs ref="paymentInputs" :stripePk="stripePk"/>
    <!-- <p v-if="this.licenseType">Your credit card will be charged ${{this.licenseType.price_usd}}.</p> -->
    <button type="submit" class="action">Upgrade my account!</button>
  </form>
</template>

<script lang="coffee">
```
const data = {
  licenseType: null,
  errors: [],
};

module.exports = {
  name: "licenses-buy-form",
  components: {
    "licenses-type-radio-button": () => VComponents.get("vue/components/licenses/typeRadioButton"),
    "licenses-payment-inputs": () => VComponents.get("vue/components/licenses/paymentInputs"),
  },
  data: function() { return data; },
  props: {
    licenseTypeOptions: Array,
    stripePk: String,
  },
  methods: {
    onLicenseTypeSelected: function(lt) {
      this.licenseType = lt;
    },
    submit: async function() {
      const payment = await this.$refs.paymentInputs.getPayment();
      const submission = {
        payment,
        license_type_id: this.licenseType.id,
      };
      this.$store.dispatch("newLicensePayment", submission)
    },
  },
  computed: {
    hasErrors: function() {
      console.log(this.$refs);
      return !!this.errors.length
        || (this.$refs.paymentInputs && this.$refs.paymentInputs.errors.length)
        || (this.$refs.paymentInputs && this.$refs.paymentInputs.cardError);
    },
  },
}
```
</script>
