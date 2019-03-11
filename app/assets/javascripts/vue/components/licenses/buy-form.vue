<template>
  <form @submit.prevent="submit" >
    <label>License Type</label>
    <ul v-for="lt of licenseTypes" :key="lt.id">
      <licenses-type-radio-button 
        :selected="licenseType" 
        :on-selected="() => onLicenseTypeSelected(lt)" 
        :license-type="lt" />
    </ul>
    <licenses-payment-inputs ref="paymentInputs" :stripePk="stripePk"/>
    <button type="submit">Buy</button>
  </form>
</template>

<script lang="coffee">
```
const data = {
  licenseType: null,
};

const api = "/api/licenses";

module.exports = {
  components: {
    "licenses-type-radio-button": () => VComponents.get("vue/components/licenses/type-radio-button"),
    "licenses-payment-inputs": () => VComponents.get("vue/components/licenses/payment-inputs"),
  },
  data: function() { return data; },
  props: {
    licenseTypes: Array,
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
      console.log(submission);
      const resp = await fetch(api, {
        method: 'POST',
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json'
        },
        body: JSON.stringify(submission),
      });
      console.log(resp);
      const body = await resp.text();
      console.log(body);
      alert(body);
    },
  },
}
```
</script>