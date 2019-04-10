<template>
  <div>
    <h2>Account Status</h2>
    <licenses-details v-if="hasLicense" :license="license"/>
    <div v-else>
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
      <p>If you like what you see, you can upgrade your account with a license of your choice! Purchasing a license will allow you to integrate GradeCraft with other tools, and add users to your courses. </p>
      <p>
        <a href="https://gradecraft.com/licenses/" target="_blank">Learn more about licensing options</a> to see what’s best for you. We have options for Higher Ed, K–12, and entire schools or districts; but if you need a custom arrangement, we’re more than happy to help!
      </p>
    </div>

    <licenses-course-selector @updated="onUpdated" v-if="hasLicense" :license="license" :courses="courses" />

    <buttonModal button_class="action secondary" ref="buttonModal_renew">
      <template slot="button-text" v-if="hasLicense">Renew my license</template>
      <template slot="button-text" v-else>Upgrade my account!</template>

      <template slot="heading" v-if="hasLicense">Account license extension</template>
      <template slot="heading" v-else>Account Upgrade</template>

      <template slot="content">
        <div>
          <licenses-renew-form @updated="onUpdated" v-if="hasLicense" :license="license" :license-type="licenseType" :stripePk="stripePk" />
          <licenses-buy-form @updated="onUpdated" v-if="!hasLicense" :license-types="licenseTypes" :stripePk="stripePk" />
        </div>
      </template>
    </buttonModal>
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
    renewLicense(){
      this.$refs.buttonModal_renew.toggleModalState()
    }
  },
  created: async function() {
    data.license = await this.getLicense();
  },
}
```
</script>
