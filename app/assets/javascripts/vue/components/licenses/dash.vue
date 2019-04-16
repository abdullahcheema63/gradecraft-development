<template>
  <div>
    <h2>Account Status</h2>
    <licenses-details v-if="hasLicense" :license="license"/>
    <div v-else>
      <p>
        Your
        <b>free trial account,</b>
        allows you to explore GradeCraft as much as you’d like! <br />
        The only things you can’t do are:
      </p>
      <ul>
        <li>Integrate with other tools (like Canvas or Moodle)</li>
        <li>Import or add other users (such as assistants and students)</li>
      </ul>
      <p>
        If you like what you see, you can upgrade your account with a license of your choice!
        <a href="https://gradecraft.com/licenses/" target="_blank">Learn more about licensing options</a> to see what’s best for you; we have options for Higher Ed and K–12.
      </p>
    </div>

    <buttonModal button_class="action secondary" ref="buttonModal_license">
      <template slot="button-text" v-if="hasLicense">Renew my account license</template>
      <template slot="button-text" v-else>Upgrade my account!</template>

      <template slot="heading" v-if="hasLicense">Account license renewal</template>
      <template slot="heading" v-else>Account Upgrade</template>

      <template slot="content">
        <div>
          <licenses-renew-form @updated="onUpdated" v-if="hasLicense" :license="license" :license-type="licenseType" :stripePk="stripePk" />
          <licenses-buy-form @updated="onUpdated" v-if="!hasLicense" :license-types="licenseTypes" :stripePk="stripePk" />
        </div>
      </template>
    </buttonModal>
    <br />
    <p v-if="hasLicense">
      To change your license type or add additional licensed courses, please email us at
      <a href="mailto:help@gradecraft.com">help@gradecraft.com</a>. We’re more than happy to help!
    </p>
    <p v-else>
      If you need a license for an entire school or district, or a custom arrangement, please don’t hesitate to email us at
      <a href="mailto:help@gradecraft.com">help@gradecraft.com</a>. We’re more than happy to help!
    </p>

    <licenses-course-selector @updated="onUpdated" v-if="hasLicense" :license="license" :courses="courses" />
  </div>
</template>

<script lang="coffee">
```
const data = {
  license: undefined,
  courses: [],
  showRenew: false,
};

const api = "/api/licenses";

const getService = (serviceName) =>
  angular.element(document.body).injector().get(serviceName);

const getAPIHelper = () =>
  getService("GradeCraftAPI");

const apiResponseToData = (responseJson) =>
  getAPIHelper().dataItem(responseJson.data, responseJson, { include: [ "courses", "payments" ] });

const coursesFromResponse = (responseJson) => {
  const arr = [];
  getAPIHelper().loadFromIncluded(arr, "courses", responseJson)
  return arr;
}

const licenseTypesFromResponse = (responseJson) => {
  const arr = [];
  getAPIHelper().loadFromIncluded(arr, "license_types", responseJson)
  return arr;
}

module.exports = {
  name: "licenses-dash",
  components: {
    "licenses-buy-form": () => VComponents.get("vue/components/licenses/buyForm"),
    "licenses-renew-form": () => VComponents.get("vue/components/licenses/renewForm"),
    "licenses-course-selector": () => VComponents.get("vue/components/licenses/courseSelector"),
    "licenses-details": () => VComponents.get("vue/components/licenses/details"),
    buttonModal: () => VComponents.get('vue/components/buttonModal'),
  },
  data: function() { return data; },
  props: {
    licenseTypes: Array,
    stripePk: String,
  },
  computed: {
    hasLicense: function() {
      return !!this.license;
    },
    licenseType: function() {
      return (this.license && this.licenseTypes)
        ? this.licenseTypes.find(lt => lt.id === this.license.license_type_id)
        : undefined;
    },
  },
  methods: {
    getLicense: async function() {
      const resp = await fetch(api);
      if (resp.status === 404) {
        return undefined;
      }
      else if (!resp.ok) {
        throw resp;
      }
      const json = await resp.json();
      console.log(json);
      data.courses = coursesFromResponse(json);
      const final = apiResponseToData(json);
      return final;
    },
    toggleRenew: function() {
      this.showRenew = !this.showRenew;
    },
    onUpdated: function(license) {
      console.log("onUpdated");
      console.log(license);
      data.license = license;
    },
    updateLicense(){
      this.$refs.buttonModal_license.toggleModalState()
    }
  },
  created: async function() {
    data.license = await this.getLicense();
  },
}
```
</script>
