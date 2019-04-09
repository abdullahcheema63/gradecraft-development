<template>
  <form @submit.prevent="submit" >
    <h3>Upgrade my account</h3>
    <div v-if="hasErrors" class="alert-box">
      {{errors}}
    </div>
    <h4>Choose Your Account License</h4>
    <p>
      Please select the license you would like. Not sure which one to get?
      <a href="https://gradecraft.com/licenses/" target="_blank">Learn more about our licensing options</a>
      to see what’s best for you!
    </p>

    <ul v-for="lt of licenseTypes" :key="lt.id">
      <licenses-type-radio-button
        :selected="licenseType"
        :on-selected="() => onLicenseTypeSelected(lt)"
        :license-type="lt" />
    </ul>

    <licenses-payment-inputs ref="paymentInputs" :stripePk="stripePk"/>
    <p v-if="this.licenseType">Your credit card will be charged ${{this.licenseType.price_usd}}.</p>
    <button type="submit" class="action">Upgrade my account!</button>
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
  getAPIHelper().dataItem(responseJson.data, responseJson, { include: [ "courses", "payments" ] });

module.exports = {
  name: "licenses-buy-form",
  components: {
    "licenses-type-radio-button": () => VComponents.get("vue/components/licenses/typeRadioButton"),
    "licenses-payment-inputs": () => VComponents.get("vue/components/licenses/paymentInputs"),
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
