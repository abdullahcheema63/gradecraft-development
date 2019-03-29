<template>
  <form @submit.prevent="submit" >
    <h2>Renew License</h2>
    <div v-if="hasErrors" class="alert-box">
      {{errors}}
    </div>
    <span>License Type: {{license.license_type_name}}</span>
    <licenses-payment-inputs ref="paymentInputs" :stripePk="stripePk"/>
    <button type="submit">Renew</button>
  </form>
</template>

<script lang="coffee">
```
const data = {
  licenseType: null,
  errors: [],
};

const api = "/api/licenses";

const getService = (serviceName) =>
  angular.element(document.body).injector().get(serviceName);

const getAPIHelper = () =>
  getService("GradeCraftAPI");

const apiResponseToData = (responseJson) =>
  getAPIHelper().dataItem(responseJson.data, responseJson);

module.exports = {
  components: {
    "licenses-payment-inputs": () => VComponents.get("vue/components/licenses/payment-inputs"),
  },
  data: function() { return data; },
  props: {
    license: Object,
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
      };
      console.log(submission);
      const resp = await fetch(api, {
        method: 'PATCH',
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(submission),
      });
      const body = await resp.json();
      if (!resp.ok) {
        this.errors = (Array.isArray(body.errors) || typeof body.errors !== "object")
          ? body.errors 
          : Object.entries(body.errors); //Need polyfill
        console.error("resp not ok!");
        console.error(this);
        console.error(resp);
        console.error(body);
        return;
      }
      console.log(resp);
      console.log(body);
      alert(body);
      const data = apiResponseToData(body);
      console.log(data);
      this.$emit("updated", data);
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