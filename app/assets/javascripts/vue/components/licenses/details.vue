<template>
  <div>
    <p>
      With your
      <b>{{license.license_type_name}}</b>
      licensed account, you can explore all GradeCraft has to offer and create <b>{{license.max_courses || "unlimited"}} licensed courses</b>, which have the ability to:
    </p>

    <ul>
      <li>Integrate with other tools (like Canvas or Moodle)</li>
      <li>Import or add other users (such as assistants and students)</li>
    </ul>

    <p>Your license: </p>
    <ul>
      <li>
        <b>Expires {{license.expires}} </b>
      </li>
      <li>
        Was created {{license.created_at}}
      </li>
      <li>
        Was last updated {{license.updated_at}}
      </li>
    </ul>

<!-- We may need to make v ifs for the expires/expired info
<p>Expired? {{license.is_expired ? "Yes" : "No"}}</p> -->
  </div>
</template>

<script lang="coffee">
```
module.exports = {
  name: "licenses-details",
  props: {
    license: Object,
  },
}
```
</script>
