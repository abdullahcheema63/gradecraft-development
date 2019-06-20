<template>
  <form @submit.prevent="submit" >
    <h2>Renew My Account License</h2>
    <div v-if="hasErrors" class="alert-box">
      {{errors}}
    </div>

    <div class="license_summary">
      <h3 class="lining_figures">{{license.license_type_name}}</h3>
      <p>
        <b>${{licenseType.price_usd}}</b> for
        <b>{{licenseType.default_max_courses}} licensed course{{licenseType.default_max_courses > 1 ? "s" : ""}}</b>
      </p>
      <p>Up to {{licenseType.default_duration_months}} months </p>
      <p>Up to {{licenseType.default_max_students}} students </p>
    </div>

    <licenses-payment-inputs ref="paymentInputs" :stripePk="stripePk"/>
    <!-- <p v-if="this.licenseType">Your credit card will be charged ${{this.licenseType.price_usd}}.</p> -->
    <button type="submit" class="action">Renew my license</button>
  </form>
</template>

<script lang="coffee">
```
const data = {
  errors: [],
};

module.exports = {
  name: "licenses-renew-form",
  components: {
    "licenses-payment-inputs": () => VComponents.get("vue/components/licenses/paymentInputs"),
  },
  data: function() { return data; },
  props: {
    license: Object,
    licenseType: Object,
    stripePk: String,
  },
  methods: {
    submit: async function() {
      const payment = await this.$refs.paymentInputs.getPayment();
      const submission = {
        payment,
      };
      console.log("submission:", submission);
      this.$store.dispatch("updateLicensePayment", submission)
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
